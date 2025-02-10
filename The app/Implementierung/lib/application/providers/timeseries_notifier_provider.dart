/// Central cache and storage for TimeSeries data from sensors
///
/// When new data comes in, it always updates the relevant provider in this library.
/// In turn, all other functionality that depends on this data is implemented as
/// consumers of this provider.
///
/// Authors:
///   * Heye Hamadmad
///   * Cem Igci
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/measurement.dart';
import '../../models/time_series.dart';
import '../util/current_time.dart';
import 'setpoint_rules_provider.dart';
import 'topic_notifications_provider.dart';

part 'timeseries_notifier_provider.g.dart';

/// Central storage for timeseries data, categorized by topic
final Map<String, TimeSeries> _timeseries = {};

/// When an append-only update comes in (the usual case) only this provider will be updated.
@riverpod
Measurement? timeSeriesLatestMeasurement(Ref ref, String topic) {
  return _timeseries[topic]?.lastOrNull;
}

/// Providers current and historical data on time series. Enables Updating.
/// For an explanation of "onlyNotifyOnChangedHistory" see [TimeSeriesAverages].
@riverpod
class TimeSeriesNotifier extends _$TimeSeriesNotifier {
  @override
  TimeSeries? build(String topic,
      {final bool onlyNotifyOnChangedHistory = false}) {
    return _timeseries[topic];
  }

  /// Will be called before new data is added and initializes new [SensorTimeSeries]
  void _initializeNewData() {
    if (!_timeseries.containsKey(topic)) {
      // This topic hasn't been encountered before, initialize time series

      final setpointRule = ref.watch(setpointRuleByTopicProvider(topic));
      if (setpointRule != null) {
        int? hwInstance = int.tryParse(
            RegExp("^[^0-9/]+([0-9]+)").firstMatch(topic)?.group(1) ?? "");
        _timeseries[topic] = SensorTimeSeries(
            setpointRule: setpointRule, topic: topic, hwInstance: hwInstance);
      } else {
        _timeseries[topic] = SensorTimeSeries(topic: topic);
      }
      ref.invalidate(timeSeriesTopicsProvider);
    }
  }

  /// Handles necessary updates in the usual case that the updated value is also the latest value
  void _actualUpdate(Measurement measurement) {
    ref.invalidate(
        latestUpdateProvider); // Maybe this is also the most current value ever received?
    ref.invalidate(timeSeriesLatestMeasurementProvider(
        topic)); // Inform listeners that just want the current value
    ref.read(topicNotificationsProvider.notifier).dataUpdate(
        topic: topic,
        value: measurement.value); // Ensure the notification state is current
  }

  /// Due to a riverpod limitation, a provider can only invalidate itself using invalidateSelf. Handles both cases
  void _changedHistory() {
    if (onlyNotifyOnChangedHistory) {
      ref.invalidateSelf();
    } else {
      ref.invalidate(
          timeSeriesNotifierProvider(topic, onlyNotifyOnChangedHistory: true));
    }
  }

  /// Perform necessary updates after any data update
  void _finalizeNewData() {
    state ??= _timeseries[
        topic]; // If addMeasurement(s) is called before the provider is built, state will be null
    if (!onlyNotifyOnChangedHistory) {
      ref.notifyListeners();
    }
  }

  void addMeasurement(Measurement measurement) {
    _initializeNewData();
    _timeseries[topic]!.add(measurement);

    if (measurement == _timeseries[topic]!.last) {
      _actualUpdate(_timeseries[topic]!.last);
    } else {
      _changedHistory();
    }
    _finalizeNewData();
  }

  void addMeasurements(Iterable<Measurement> measurements) {
    _initializeNewData();
    final previousMeasurement = _timeseries[topic]!.lastOrNull;
    _timeseries[topic]!.addAll(measurements);
    if (previousMeasurement != _timeseries[topic]!.last) {
      _actualUpdate(_timeseries[topic]!.last);
    }
    _changedHistory();
    _finalizeNewData();
  }
}

/// Provides a list of available topics / TimeSeries
@riverpod
Iterable<String> timeSeriesTopics(Ref ref) {
  return _timeseries.keys;
}

/// Provides all time series (or alternatively only those matching a RegExp) as a map for better performance.
@riverpod
class AllTimeSeries extends _$AllTimeSeries {
  @override
  Map<String, TimeSeries> build(
      {RegExp? filter, bool onlyNotifyOnChangedHistory = false}) {
    final topics = filter == null
        ? ref.watch(timeSeriesTopicsProvider)
        : ref
            .watch(timeSeriesTopicsProvider)
            .where((topic) => filter.hasMatch(topic));
    if (stateOrNull != null &&
        setEquals(stateOrNull!.keys.toSet(), topics.toSet())) {
      // Crucial caching step
      return Map.from(stateOrNull!);
    }
    for (final topic in topics) {
      ref.watch(timeSeriesNotifierProvider(topic,
          onlyNotifyOnChangedHistory: onlyNotifyOnChangedHistory));
    }
    return {for (final topic in topics) topic: _timeseries[topic]!};
  }
}

/// Provides the timestamp of the newest known measurement
@riverpod
MartianTimeStamp? latestUpdate(Ref ref) {
  MartianTimeStamp? biggest;
  for (final ts in _timeseries.values) {
    if (ts.lastOrNull != null) {
      if (biggest == null) {
        biggest = ts.last.timestamp;
      } else if (ts.last.timestamp > biggest) {
        biggest = ts.last.timestamp;
      }
    }
  }
  return biggest;
}
