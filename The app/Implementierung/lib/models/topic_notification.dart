/// Tracks out-of-ordinary states of topics / time series with some safeguards
///
/// Authors:
///   * Heye Hamadmad
library;

import '../application/util/current_time.dart';
import 'setpoint_rule.dart';
import 'ternary_status.dart';

class TopicNotification implements Comparable {
  late TernaryStatus _status;
  late final MartianTimeStamp _firstAppearance;
  MartianTimeStamp? _okSince;
  late final String _topic;
  late final SetpointRule _setpointRule;

  TopicNotification(
      {required TernaryStatus status,
      required String topic,
      required SetpointRule setpointRule}) {
    if (status == TernaryStatus.ok) {
      throw ArgumentError(
          "Notification can only be generated when status is not ok");
    }
    _status = status;
    _firstAppearance = currentTime();
    _topic = topic;
    _setpointRule = setpointRule;
  }

  set status(status) {
    if (status == TernaryStatus.ok) {
      if (_status != TernaryStatus.ok) {
        _okSince = currentTime();
      }
    } else {
      if (_status == TernaryStatus.ok) {
        throw ArgumentError(
            "Notification with OK status may not be reset to not OK status");
      }
    }
    _status = status;
  }

  TernaryStatus get status => _status;

  MartianTimeStamp? get okSince => _okSince;

  MartianTimeStamp get firstAppearance => _firstAppearance;

  SetpointRule get setpointRule => _setpointRule;

  String get topic => _topic;

  @override
  int compareTo(other) {
    return firstAppearance.compareTo(other.firstAppearance);
  }
}
