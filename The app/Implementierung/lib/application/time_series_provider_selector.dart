/// A hacky way to use dynamically pass different providers
/// providing structurally similar [TimeSeries] data.
/// Solves the fundamental problem that for example averages and AQI are
/// calculated within different providers but need to be consumed by the same
/// Widgets.
///
/// Authors:
///   * Heye Hamadmad
library;

import '../models/setpoint_rule.dart';
import 'providers/aqi_provider.dart';
import 'providers/timeseries_averages_provider.dart';
import 'providers/timeseries_notifier_provider.dart';

sealed class TimeSeriesProviderSelector {
  dynamic get currentMeasurementProvider;
  dynamic get historicalMeasurementsProvider;
}

class SensorTimeSeriesSelected extends TimeSeriesProviderSelector {
  final String topic;

  SensorTimeSeriesSelected({required this.topic});

  @override
  get currentMeasurementProvider => timeSeriesLatestMeasurementProvider(topic);

  @override
  get historicalMeasurementsProvider =>
      timeSeriesNotifierProvider(topic, onlyNotifyOnChangedHistory: false);
}

class AveragedTimeSeriesSelected extends TimeSeriesProviderSelector {
  final RegExp topics;
  final SetpointRule setpointRule;

  AveragedTimeSeriesSelected(
      {required this.topics, required this.setpointRule});

  @override
  get currentMeasurementProvider => timeSeriesAverageCurrentProvider(topics);

  @override
  get historicalMeasurementsProvider =>
      timeSeriesAveragesProvider(topics, onlyNotifyOnChangedHistory: false);
}

class AqiTimeSeriesSelected extends TimeSeriesProviderSelector {
  AqiTimeSeriesSelected();

  @override
  get currentMeasurementProvider => aqiCurrentProvider;

  @override
  get historicalMeasurementsProvider =>
      aqiProvider(onlyNotifyOnChangedHistory: false);
}
