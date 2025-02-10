/// A singular datapoint consisting of a double-precision value and a timestamp
///
/// Authors:
///   * Heye Hamadmad
///   * Arin Tanriverdi
library;

import '../application/util/current_time.dart';

class Measurement implements Comparable {
  final MartianTimeStamp timestamp; // Seconds since 01.01.1970 00:00 UTC
  final double value;

  Measurement({required this.timestamp, required this.value});

  @override
  int compareTo(other) {
    return timestamp.compareTo(other.timestamp);
  }
}
