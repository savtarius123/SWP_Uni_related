/// TimeSeries Initialization logic and InfluxDB connection
/// Simple and encapsulated enough to be in its own file
///
/// Authors:
///   * Heye Hamadmad
library;

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/measurement.dart';
import '../util/current_time.dart';
import 'settings_provider.dart';
import 'timeseries_notifier_provider.dart';

part 'influx_init_provider.g.dart';

@riverpod
class InfluxInit extends _$InfluxInit {
  final log = Logger("InfluxInitProvider");

  @override
  Future<void> build() async {
    // ref.read instead of ref.watch, don't rebuild when settings change
    final url = (await ref.read(settingsProvider("influx_uri").future))
        ?.dynamicValue as String;
    String dbName = (await ref.read(settingsProvider("influx_dbname").future))
        ?.dynamicValue as String;
    String username =
        (await ref.read(settingsProvider("influx_username").future))
            ?.dynamicValue as String;
    String password =
        (await ref.read(settingsProvider("influx_password").future))
            ?.dynamicValue as String;

    // Define the query
    String query = 'SELECT * FROM /./ ORDER BY time DESC LIMIT 1000';

    // Set up the parameters
    Map<String, String> queryParams = {
      'q': query,
      'db': dbName,
    };

    // Encode credentials to base64
    String basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    // Send the HTTP GET request with Basic Authentication
    final response = await http.get(
      Uri.parse(url).replace(queryParameters: queryParams),
      headers: {
        'Authorization': basicAuth,
      },
    );

    // Check the response status
    if (response.statusCode == 200) {
      // Tthe request is successful, parse the response
      final data = jsonDecode(response.body);
      final allSeries = data["results"][0]["series"];
      for (final series in allSeries) {
        final topicOut = (series["name"] as String)
            .replaceFirst("_", "/"); // This is horrible, but necessary
        final List<Measurement> measurements = [];
        int timeIndex = -1;
        int valueIndex = -1;
        for (int i = 0; i < series["columns"].length; i++) {
          if (series["columns"][i] == "time") {
            timeIndex = i;
          } else if (series["columns"][i] == "value") {
            valueIndex = i;
          }
        }
        if (timeIndex < 0 || valueIndex < 0) {
          throw Exception("Either time or value column doesn't exist");
        }
        for (final entry in series["values"]) {
          measurements.add(Measurement(
              timestamp: timeFromISO8601(entry[timeIndex] as String),
              value: (entry[valueIndex] as num).toDouble()));
        }
        ref
            .read(timeSeriesNotifierProvider(topicOut).notifier)
            .addMeasurements(measurements);
      }
    }
  }
}
