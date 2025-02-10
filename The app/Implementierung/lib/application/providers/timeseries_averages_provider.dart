/// Matches, aggregates and averages time series data
///
/// The basic idea is that Time Series data from all topics matched by a regular
/// expression will be aggregated by this provider, which then calculates their
/// average value. This is not only implemented for current but also for
/// historical data.
///
/// Application note: At the current state of this library, the passed matchers
/// MUST NOT be dynamically generated and instead be generated once and reused.
///
/// Authors:
///   * Heye Hamadmad
///   * Cem Igci
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/measurement.dart';
import '../../models/time_series.dart';
import 'timeseries_notifier_provider.dart';

part 'timeseries_averages_provider.g.dart';

final Map<RegExp, TimeSeries> _timeSeriesAverages = {};

/// Provides historical averaged data as a [TimeSeries].
/// The boolean variable [onlyNotifyOnChangedHistory] effectively separates two
/// completely different providers. One (with the variable set to true) only
/// notifies its listeners when for some reason (for example an InfluxDB import)
/// the historical time series data changes. It then recalculates the averages
/// over all matching topics/time series and notifies its listeners. Other than
/// the convenience function with [onlyNotifyOnChangedHistory] set to false
/// (which listens to the former and also timeSeriesAverageCurrentProvider),
/// this will only be used by other providers that need historical averaged
/// values.
/// The keepAlive is necessary here because the recalculation of the AQI is
/// rather expensive and should be cached whenever possible.
@Riverpod(keepAlive: true)
class TimeSeriesAverages extends _$TimeSeriesAverages {
  @override
  TimeSeries? build(RegExp topics,
      {final bool onlyNotifyOnChangedHistory = false}) {
    if (onlyNotifyOnChangedHistory == false) {
      // This is the shortcut variant to get the cached variant when either a
      // single value is added or the history is rebuilt
      ref.watch(timeSeriesAverageCurrentProvider(topics));
      ref.watch(
          timeSeriesAveragesProvider(topics, onlyNotifyOnChangedHistory: true));
      return _timeSeriesAverages[topics];
    }

    // Historical average ts data was invalidated, so the history of averages
    // has to be rebuilt

    final newAvgsTimeSeries =
        PlainTimeSeries(); // TimeSeries without topic and setpoint rule

    final matchingTimeSeries = ref
        .watch(allTimeSeriesProvider(
            filter: topics, onlyNotifyOnChangedHistory: true))
        .values;

    if (matchingTimeSeries.isEmpty) {
      return null;
    }

    // Now the general idea is to iterate through all TimeSeries dependencies at
    // once, always iterating the one with the next smallest timestamp.

    // Create iterators for all dependencies
    final Map<TimeSeries, Iterator<Measurement>?> iterators = {
      for (var tiSe in matchingTimeSeries) tiSe: tiSe.iterator
    };

    // Preparations for implementing lookahead
    final Map<TimeSeries, Measurement?> nextValues = {};
    final Map<TimeSeries, Measurement?> currentValues = {};

    // Fetch the first value from each TimeSeries into nextValues to enable first
    // lookahead
    for (final tiSe in matchingTimeSeries) {
      if (iterators[tiSe]?.moveNext() ?? false) {
        nextValues[tiSe] = iterators[tiSe]!.current;
      } else {
        nextValues[tiSe] = null;
        iterators[tiSe] = null;
      }
    }

    // Helper functions for cleaner lookahead
    Measurement? peek(TimeSeries tiSe) {
      return nextValues[tiSe];
    }

    // The other helper function
    void iterate(TimeSeries tiSe) {
      currentValues[tiSe] = nextValues[tiSe];
      if (iterators[tiSe]?.moveNext() ?? false) {
        nextValues[tiSe] = iterators[tiSe]!.current;
      } else {
        nextValues[tiSe] = null;
        iterators[tiSe] = null;
      }
    }

    while (matchingTimeSeries.any((maTiSe) => peek(maTiSe) != null)) {
      // Peek into the nextValues and pull the one with the smallest timestamp into the currentValues
      iterate(matchingTimeSeries
          .map((maTiSe) => (maTiSe, peek(maTiSe)))
          .where((t) => t.$2 != null)
          .reduce((a, b) => a.$2!.timestamp < b.$2!.timestamp ? a : b)
          .$1);
      _addAverage(newAvgsTimeSeries,
          _getAverageFromMeasurements(currentValues.values.nonNulls));
    }

    _timeSeriesAverages[topics] = newAvgsTimeSeries;
    return _timeSeriesAverages[topics];
  }
}

/// Provides the latest averaged values of the time series for all topics matching the RegExp
@Riverpod(keepAlive: true)
Measurement? timeSeriesAverageCurrent(Ref ref, RegExp topics) {
  final matchingTopics = ref
      .watch(allTimeSeriesProvider(
          filter: topics, onlyNotifyOnChangedHistory: true))
      .keys;
  final matchingMeasurements = matchingTopics
      .map((topic) => ref.watch(timeSeriesLatestMeasurementProvider(topic)))
      .nonNulls;
  if (matchingMeasurements.isEmpty) {
    return null;
  }

  final avg = _getAverageFromMeasurements(matchingMeasurements);
  _timeSeriesAverages[topics] ??= PlainTimeSeries();
  _addAverage(_timeSeriesAverages[topics]!, avg);
  return avg;
}

Measurement _getAverageFromMeasurements(
    Iterable<Measurement> matchingMeasurements) {
  final value =
      matchingMeasurements.map((ms) => ms.value).reduce((a, b) => a + b) /
          matchingMeasurements.length;
  final ts = matchingMeasurements
      .map((ms) => ms.timestamp)
      .reduce((a, b) => a > b ? a : b);
  return Measurement(timestamp: ts, value: value);
}

void _addAverage(TimeSeries avgs, Measurement avg) {
  // Performance might be improved with better heuristics here to filter out more values
  if (avgs.isEmpty) {
    avgs.add(avg);
    return;
  }
  if (avg.timestamp - avgs.last.timestamp > 20) {
    avgs.add(avg);
    return;
  }
  if ((avg.value - avgs.last.value).abs() > (avgs.last.value.abs() * 0.05)) {
    avgs.add(avg);
    return;
  }
}
