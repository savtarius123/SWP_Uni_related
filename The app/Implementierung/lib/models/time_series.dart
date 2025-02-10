//// Models a time series as a list of always sorted measurements
///
/// Measurements consist of timestamps and measured values.
/// This is the simplest thing that could possibly work.
///
/// Authors:
///   * Heye Hamadmad
library;

import 'dart:collection';

import 'measurement.dart';

import 'setpoint_rule.dart';

sealed class TimeSeries extends ListBase<Measurement> {
  final List<Measurement> _tsData = [];

  @override
  int get length {
    return _tsData.length;
  }

  @override
  set length(int length) {
    _tsData.length = length;
  }

  @override
  Measurement operator [](int index) {
    return _tsData[index];
  }

  /// The time series supports no mutation other than addition
  @override
  void operator []=(int index, Measurement value) {
    throw Exception("Existing TimeSeries data can not be modified");
  }

  /// Appending one value is very cheap (amortized O(1)), otherwise it's O(n)
  @override
  void add(Measurement element) {
    if (_tsData.lastOrNull == null || element.compareTo(_tsData.last) > 0) {
      _tsData.add(element);
    } else {
      _tsData.add(element);
      _tsData.sort((a, b) => a.compareTo(b));
    }
  }

  /// Adding many values is best case O(n), O(n log n) worst case
  @override
  void addAll(Iterable<Measurement> iterable) {
    _tsData.addAll(iterable);
    _tsData.sort((a, b) => a.compareTo(b));
  }
}

/// To be used with data that comes directly from a sensor and can be assigned a topic and [SetpointRule]
class SensorTimeSeries extends TimeSeries {
  final String? topic;
  final SetpointRule? setpointRule;
  final int? hwInstance;

  SensorTimeSeries({this.topic, this.hwInstance, this.setpointRule});
}

/// To be used for time series data that was generated from other available data. It can't have a topic and thus no matching [SetpointRule]
class PlainTimeSeries extends TimeSeries {}
