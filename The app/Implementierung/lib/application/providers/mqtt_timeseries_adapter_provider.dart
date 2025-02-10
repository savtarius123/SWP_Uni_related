/// Listens for MQTT messages matching a specific pattern and updates the
/// corresponding time series data with the received measurements.
///
/// Authors:
///   * Heye Hamadmad
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/measurement.dart';
import '../util/current_time.dart';
import 'mqtt_messages_provider.dart';
import 'timeseries_notifier_provider.dart';

part 'mqtt_timeseries_adapter_provider.g.dart';

@Riverpod(keepAlive: true)
void mqttTimeseriesAdapter(Ref ref) {
  final log = Logger("MqttTimeSeriesAdapter");
  final latestMatchFuture =
      ref.watch(mqttMessagesProvider(RegExp(r'^(board|pbr)[0-9]+/.*$')).future);

  latestMatchFuture.then((message) {
    final topic = message.variableHeader!.topicName;
    final numericValue = double.tryParse(
        MqttPublishPayload.bytesToStringAsString(message.payload.message));
    if (numericValue == null) {
      log.warning(
          "Received non-float value ${MqttPublishPayload.bytesToStringAsString(message.payload.message)} for topic $topic");
      return; //This is probably fine
    }
    ref.read(timeSeriesNotifierProvider(topic).notifier).addMeasurement(
        Measurement(timestamp: currentTime(), value: numericValue));
  });
}
