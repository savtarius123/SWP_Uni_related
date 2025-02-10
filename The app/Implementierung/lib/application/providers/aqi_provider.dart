/// Calculates and caches the Air Quality Index (AQI).
///
/// The AQI is calculated from the concentrations of O2 (oxygen) and
/// CO2 (carbon dioxide), CO (Carbon monoxide), water vapour and O3 (Ozone) in
/// the air, averaged over all available sensors. For water vapour and O3, their
/// concentration in % and ppm respectively is already the AQI, for the other
/// metrics a piecewise linear function is applied to get the AQI value.
/// The highest (worst) AQI value is now selected and represents the overall AQI.
///
/// Both current and historical AQI values will be calculated.
///
/// Authors:
///   * Heye Hamadmad
///   * Arin Tanriverdi
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../application/providers/timeseries_averages_provider.dart';
import '../../models/measurement.dart';
import '../../models/time_series.dart';
import 'setpoint_rules_provider.dart';

part 'aqi_provider.g.dart';

// Can't be final because it may be reassigned to signify changed historical values
TimeSeries? _aqis;

/// Provides historical Air Quality Data as a [TimeSeries].
/// For the interplay of [onlyNotifyOnChangedHistory] and [aqiCurrent] refer
/// to the documentation for [TimeSeriesAverages].
/// The keepAlive is necessary here because the recalculation of the AQI is
/// rather expensive and should be cached whenever possible.
@Riverpod(keepAlive: true)
TimeSeries? aqi(Ref ref, {final bool onlyNotifyOnChangedHistory = false}) {
  if (onlyNotifyOnChangedHistory == false) {
    // This is the shortcut variant to get the cached TimeSeries when either a
    // single value was added or the history was rebuilt

    ref.watch(aqiCurrentProvider); // Might add a new value to [_aqis], so it
    // needs to be watched

    ref.watch(aqiProvider(onlyNotifyOnChangedHistory: true)); // Also notify
    // when historical values are changed
    return _aqis;
  }

  // Get the matchers for the concentration averages from their respective
  // setpointRules. This avoids unnecessary averages calculations in the
  // timeSeriesAveragesProvider, because they will be calculated anyways.
  final o2SetpointRule =
      ref.watch(setpointRulesProvider("board_o2_concentration"));
  final co2SetpointRule =
      ref.watch(setpointRulesProvider("board_co2_concentration"));
  final coSetpointRule =
      ref.watch(setpointRulesProvider("board_co_concentration"));
  final humiditySetpointRule =
      ref.watch(setpointRulesProvider("board_humidity"));
  final o3SetpointRule =
      ref.watch(setpointRulesProvider("board_o3_concentration"));

  // Fetch historical values for the relevant metrics
  final o2a = ref.watch(timeSeriesAveragesProvider(o2SetpointRule!.topicMatcher,
      onlyNotifyOnChangedHistory: true));
  final co2a = ref.watch(timeSeriesAveragesProvider(
      co2SetpointRule!.topicMatcher,
      onlyNotifyOnChangedHistory: true));
  final coa = ref.watch(timeSeriesAveragesProvider(coSetpointRule!.topicMatcher,
      onlyNotifyOnChangedHistory: true));
  final humiditya = ref.watch(timeSeriesAveragesProvider(
      humiditySetpointRule!.topicMatcher,
      onlyNotifyOnChangedHistory: true));
  final o3a = ref.watch(timeSeriesAveragesProvider(o3SetpointRule!.topicMatcher,
      onlyNotifyOnChangedHistory: true));

  // Map the metrics to the functions that transform the metrics value ranges to
  // the uniform and comparable AQI value range. Each metric may be null at this
  // point.
  final List<(TimeSeries?, int Function(double))> aqiMapper = [
    (o2a, o2Aqi),
    (co2a, co2Aqi),
    (coa, coAqi),
    (humiditya, humidityAqi),
    (o3a, o3Aqi)
  ];

  // Same as above, but null values aren't possible anymore
  final Map<TimeSeries, int Function(double)> aqiMap = {
    for (var aqiMapperEntry
        in aqiMapper.where((aqiMapperEntry) => aqiMapperEntry.$1 != null))
      aqiMapperEntry.$1!: aqiMapperEntry.$2
  };

  if (aqiMap.keys.isEmpty) {
    // No sense in trying to calculate an AQI from noting
    return null;
  }

  // Now the general idea is to iterate through all TimeSeries dependencies at
  // once, always iterating the one with the next smallest timestamp.

  // Create iterators for all dependencies
  final Map<TimeSeries, Iterator<Measurement>?> iterators = {
    for (var tiSe in aqiMap.keys) tiSe: tiSe.iterator
  };

  // Preparations for implementing lookahead
  final Map<TimeSeries, Measurement?> nextValues = {};
  final Map<TimeSeries, Measurement?> currentValues = {};

  // Fetch the first value from each TimeSeries into nextValues to enable first
  // lookahead
  for (final tiSe in aqiMap.keys) {
    if (iterators[tiSe]?.moveNext() ?? false) {
      nextValues[tiSe] = iterators[tiSe]!.current;
    } else {
      nextValues[tiSe] = null;
      iterators[tiSe] = null;
    }
  }

  // Helper function for cleaner lookahead
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

  // This will be returned at the end, all the values will be inserted here
  final newAqisList = PlainTimeSeries();

  while (aqiMap.keys.any((maTiSe) => peek(maTiSe) != null)) {
    // Peek into the nextValues and pull the one with the smallest timestamp into the currentValues
    iterate(aqiMap.keys
        .map((maTiSe) => (maTiSe, peek(maTiSe)))
        .where((t) => t.$2 != null)
        .reduce((a, b) => a.$2!.timestamp < b.$2!.timestamp ? a : b)
        .$1);

    // Generate all AQIs
    final aqis = currentValues.entries
        .where((mapEntry) => mapEntry.value != null)
        .map((mapEntry) => aqiMap[mapEntry.key]!(mapEntry.value!.value));

    // Find the largest / worst AQI
    final worstAqi = aqis.reduce((a, b) => a > b ? a : b);

    // Find the largest time stamp (because at this time, the worst AQI is the one calculated above)
    final latestTimestamp = currentValues.values
        .reduce((a, b) => a!.timestamp > b!.timestamp ? a : b);

    // Create a measurement from the value and the timestamp
    final ms = Measurement(
        timestamp: latestTimestamp!.timestamp, value: worstAqi.toDouble());

    // Add the new measurement to the TimeSeries if significant
    _addAqi(newAqisList, ms);
  }

  // Overwrite the cache
  _aqis = newAqisList;
  return _aqis;
}

/// The same as [aqi] but only for the latest measurements
@Riverpod(keepAlive: true)
Measurement? aqiCurrent(Ref ref) {
  final o2SetpointRule =
      ref.watch(setpointRulesProvider("board_o2_concentration"));
  final co2SetpointRule =
      ref.watch(setpointRulesProvider("board_co2_concentration"));
  final coSetpointRule =
      ref.watch(setpointRulesProvider("board_co_concentration"));
  final humiditySetpointRule =
      ref.watch(setpointRulesProvider("board_humidity"));
  final o3SetpointRule =
      ref.watch(setpointRulesProvider("board_o3_concentration"));

  final o2ac =
      ref.watch(timeSeriesAverageCurrentProvider(o2SetpointRule!.topicMatcher));
  final co2ac = ref
      .watch(timeSeriesAverageCurrentProvider(co2SetpointRule!.topicMatcher));
  final coac =
      ref.watch(timeSeriesAverageCurrentProvider(coSetpointRule!.topicMatcher));
  final humidityac = ref.watch(
      timeSeriesAverageCurrentProvider(humiditySetpointRule!.topicMatcher));
  final o3ac =
      ref.watch(timeSeriesAverageCurrentProvider(o3SetpointRule!.topicMatcher));

  final List<(Measurement?, int Function(double))> aqiMapper = [
    (o2ac, o2Aqi),
    (co2ac, co2Aqi),
    (coac, coAqi),
    (humidityac, humidityAqi),
    (o3ac, o3Aqi)
  ];

  // Calculate AQI for every time series and return null if time series is not available
  final aqis = aqiMapper
      .map((entry) => entry.$1 != null
          ? Measurement(
              value: entry.$2(entry.$1!.value).toDouble(),
              timestamp: entry.$1!.timestamp)
          : null)
      .nonNulls;

  if (aqis.isEmpty) {
    // No time series has data yet, so no AQI can be calculated
    return null;
  }

  // Return the biggest AQI encountered
  final aqi = aqis.reduce((a, b) => a.value > b.value ? a : b);
  _aqis ??= PlainTimeSeries(); // Initialize _aqis if necessary
  _addAqi(_aqis!,
      aqi); // Add new measurement to historical measurements if it is of sufficient significance.
  return aqi;
}

/// When a new AQI value arrives, a decision is necessary on whether to take it
/// into the historical values or if it should be ignored for better performance.
/// For now, a value is deemed significant if it is the first value, or there
/// hasn't been a new value for a sufficiently long time or the value has
/// changed by a sufficient amount.
void _addAqi(TimeSeries aqis, Measurement aqi) {
  if (aqis.isEmpty) {
    aqis.add(aqi);
    return;
  }
  if (aqi.timestamp - aqis.last.timestamp > 20) {
    aqis.add(aqi);
    return;
  }
  if ((aqi.value - aqis.last.value).abs() > (aqis.last.value.abs() * 0.05)) {
    aqis.add(aqi);
    return;
  }
}

int o2Aqi(double o2Concentration) {
  final List<(double, int)> o2AqiValues = [
    (16, 300),
    (17.6, 200),
    (18.4, 150),
    (19.3, 100),
    (20.1, 50),
    ((20.1 + 21.7) / 2, 0),
    (21.7, 50),
    (22.5, 100),
    (23.4, 150),
    (24.2, 200),
    (25.8, 300)
  ];

  return aqiPiecewiseLinear(o2Concentration, o2AqiValues);
}

int co2Aqi(double co2Concentration) {
  final List<(double, int)> co2AqiValues = [
    (0, 0),
    (600, 50),
    (800, 100),
    (1000, 150),
    (1200, 200),
    (1500, 300)
  ];

  return aqiPiecewiseLinear(co2Concentration, co2AqiValues);
}

int coAqi(double coConcentration) {
  final List<(double, int)> coAqiValues = [
    (0, 0),
    (10, 50),
    (25, 100),
    (50, 150),
    (70, 200),
    (100, 300)
  ];

  return aqiPiecewiseLinear(coConcentration, coAqiValues);
}

int humidityAqi(double humidity) {
  return humidity.round();
}

int o3Aqi(double o3Concentration) {
  return o3Concentration.round();
}

/// Apply a piecewise linear function defined by the points from [aqiValues] to
/// the value from [measurement]
int aqiPiecewiseLinear(double measurement, List<(double, int)> aqiValues) {
  for (int i = 0; i < (aqiValues.length - 1); i++) {
    if (measurement < aqiValues[i].$1
            // The measured value is smaller than the minimum of the current
            // bracket. This can only happen in the very first iteration
            ||
            (i == aqiValues.length - 2 && measurement > aqiValues[i + 1].$1)
            // The measured value is possibly larger than the defined range.
            // Extend the last linear bracket.
            ||
            (measurement >= aqiValues[i].$1 &&
                measurement <= aqiValues[i + 1].$1)
        // The measurement is within the current bracket
        ) {
      return ((((aqiValues[i + 1].$2 - aqiValues[i].$2) /
                      (aqiValues[i + 1].$1 - aqiValues[i].$1)) *
                  (measurement - aqiValues[i].$1)) +
              aqiValues[i].$2)
          .round();
    }
  }
  // This part should never be reached, so a mistake must have been made somewhere
  throw Exception("Unexpected AQI calculation error");
}
