/// DateTime is at this point not suitable for use on Mars. This library
/// abstracts all time handling so it can later be swapped out for a more
/// general implementation
///
/// Authors:
///   * Heye Hamadmad
///   * Arin Tanriverdi
library;

import 'package:intl/intl.dart';

/// Time in seconds since some defined epoch for our time domain. Time on mars
/// will likely not share an epoch with earth due to significant drift caused by
/// time dilation.
typedef MartianTimeStamp = double;

/// Gets the current time as required by MartianTimeStamp
MartianTimeStamp currentTime() {
  return DateTime.now().microsecondsSinceEpoch / 1000000;
}

/// ISO 8601 might be used on Mars as well but probably shouldn't be.
MartianTimeStamp timeFromISO8601(String isoTimestamp) {
  return DateTime.parse(isoTimestamp).microsecondsSinceEpoch / 1000000;
}

/// This extension exists under the assumption that the application will only
/// be used in contexts where the concept of a "Day" exists. Even during transit
/// between Earth and Mars it will make sense to have some Day/Night cycle
extension Display on MartianTimeStamp {
  /// Make obvious to an intelligent human during in which day this timestamp
  /// occurs in their current location.
  String toDate() {
    return DateFormat('yyyy-MM-DD')
        .format(DateTime.fromMicrosecondsSinceEpoch((this * 1000000).toInt()));
  }

  /// Make obvious to an intelligent human at which part of a given day this
  /// timestamp occurs in their current location with sufficient precision.
  String toTimeOfDay() {
    return DateFormat('HH:mm')
        .format(DateTime.fromMicrosecondsSinceEpoch((this * 1000000).toInt()));
  }
}
