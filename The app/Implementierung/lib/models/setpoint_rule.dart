/// Model for a rule that can be applied to a set of timeseries identified by topics
///
/// Authors:
///   * Heye Hamadmad
///   * Cem Igci
library;

import 'package:freezed_annotation/freezed_annotation.dart';

import 'display_group.dart';
import 'ternary_status.dart';

part 'setpoint_rule.freezed.dart';
part 'setpoint_rule.g.dart';

@freezed
class SetpointRanges with _$SetpointRanges {
  const factory SetpointRanges(
      {required (double, double) rangeOk,
      required (double, double) rangeAbnormal,
      required (double, double) rangeCritical}) = _SetpointRanges;

  factory SetpointRanges.fromJson(Map<String, Object?> json) =>
      _$SetpointRangesFromJson(json);
}

class SetpointRule {
  final RegExp topicMatcher;
  final String title;
  final String? unit;
  final DisplayGroup displayGroup;
  SetpointRanges setpointRanges;

  SetpointRule(
      {required this.topicMatcher,
      required this.title,
      this.unit,
      required this.setpointRanges,
      required this.displayGroup});

  TernaryStatus checkStatus(double value) {
    if (value >= setpointRanges.rangeOk.$1 &&
        value <= setpointRanges.rangeOk.$2) {
      return TernaryStatus.ok;
    } else if (value >= setpointRanges.rangeAbnormal.$1 &&
        value <= setpointRanges.rangeAbnormal.$2) {
      return TernaryStatus.abnormal;
    } else {
      return TernaryStatus.critical;
    }
  }
}
