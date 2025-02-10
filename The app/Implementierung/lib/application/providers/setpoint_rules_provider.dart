/// Defines a ruleset with RegExp matchers for topics, a title, a unit,
/// a display grouping and default values for setpoint ranges. Allows reading
/// and writing setpoints.
///
/// Authors:
///   * Heye Hamadmad
///   * Cem Igci
///   * Arin Tanriverdi
library;

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/display_group.dart';
import '../../models/setpoint_rule.dart';

part 'setpoint_rules_provider.g.dart';

final Map<String, SetpointRule> _setpointRules = {
  "board_temperature": SetpointRule(
      topicMatcher: RegExp("^board[0-9]+/temp[0-9]+_am\$"),
      title: "Temperature",
      unit: "°C",
      setpointRanges: const SetpointRanges(
          rangeOk: (25, 32), rangeAbnormal: (18, 35), rangeCritical: (18, 36)),
      displayGroup: DisplayGroup.temp),
  "board_pressure": SetpointRule(
      topicMatcher: RegExp("^board[0-9]+/amb_press\$"),
      title: "Pressure",
      unit: "hPa",
      setpointRanges: const SetpointRanges(
          rangeOk: (950, 1040),
          rangeAbnormal: (920, 1080),
          rangeCritical: (900, 1100)),
      displayGroup: DisplayGroup.misc),
  "board_o2_concentration": SetpointRule(
      topicMatcher: RegExp("^board[0-9]+/o2\$"),
      title: "O₂",
      unit: "%",
      setpointRanges: const SetpointRanges(
          rangeOk: (21, 23), rangeAbnormal: (18, 25), rangeCritical: (0, 35)),
      displayGroup: DisplayGroup.misc),
  "board_co2_concentration": SetpointRule(
      topicMatcher: RegExp("^board[0-9]+/co2\$"),
      title: "CO₂",
      unit: "ppm",
      setpointRanges: const SetpointRanges(
          rangeOk: (300, 2900),
          rangeAbnormal: (0, 3000),
          rangeCritical: (0, 4000)),
      displayGroup: DisplayGroup.misc),
  "board_co_concentration": SetpointRule(
      topicMatcher: RegExp("^board[0-9]+/co\$"),
      title: "CO",
      unit: "ppm",
      setpointRanges: const SetpointRanges(
          rangeOk: (0, 5), rangeAbnormal: (0, 25), rangeCritical: (0, 30)),
      displayGroup: DisplayGroup.misc),
  "board_o3_concentration": SetpointRule(
      topicMatcher: RegExp("^board[0-9]+/o3\$"),
      title: "O₃",
      unit: "ppb",
      setpointRanges: const SetpointRanges(
          rangeOk: (0, 100), rangeAbnormal: (0, 150), rangeCritical: (0, 200)),
      displayGroup: DisplayGroup.misc),
  "board_humidity": SetpointRule(
      topicMatcher: RegExp("^board[0-9]+/humid[0-9]+_am\$"),
      title: "Humidity",
      unit: "%",
      setpointRanges: const SetpointRanges(
          rangeOk: (40, 95), rangeAbnormal: (0, 100), rangeCritical: (0, 100)),
      displayGroup: DisplayGroup.humid),
  "pbr_temperature_g_in": SetpointRule(
      topicMatcher: RegExp("^pbr[0-9]+/temp_g_1\$"),
      title: "Temperature (g, in)",
      unit: "°C",
      setpointRanges: const SetpointRanges(
          rangeOk: (25, 32), rangeAbnormal: (18, 35), rangeCritical: (18, 36)),
      displayGroup: DisplayGroup.inlet),
  "pbr_temperature_l": SetpointRule(
      topicMatcher: RegExp("^pbr[0-9]+/temp_1\$"),
      title: "Temperature (l)",
      unit: "°C",
      setpointRanges: const SetpointRanges(
          rangeOk: (25, 32), rangeAbnormal: (18, 35), rangeCritical: (18, 36)),
      displayGroup: DisplayGroup.liquid),
  "pbr_temperature_g_out": SetpointRule(
      topicMatcher: RegExp("^pbr[0-9]+/temp_g_2\$"),
      title: "Temperature (g, out)",
      unit: "°C",
      setpointRanges: const SetpointRanges(
          rangeOk: (25, 32), rangeAbnormal: (18, 35), rangeCritical: (18, 36)),
      displayGroup: DisplayGroup.outlet),
  "pbr_pressure_g_in": SetpointRule(
      topicMatcher: RegExp("^pbr[0-9]+/amb_press_1\$"),
      title: "Pressure (g, in)",
      unit: "hPa",
      setpointRanges: const SetpointRanges(
          rangeOk: (950, 1040),
          rangeAbnormal: (920, 1080),
          rangeCritical: (900, 1100)),
      displayGroup: DisplayGroup.inlet),
  "pbr_pressure_g_out": SetpointRule(
      topicMatcher: RegExp("^pbr[0-9]+/amb_press_2\$"),
      title: "Air pressure (Out, g)",
      unit: "hPa",
      setpointRanges: const SetpointRanges(
          rangeOk: (950, 1040),
          rangeAbnormal: (920, 1080),
          rangeCritical: (900, 1100)),
      displayGroup: DisplayGroup.outlet),
  "pbr_o2_concentration_g_in": SetpointRule(
      topicMatcher: RegExp("^pbr[0-9]+/o2_1\$"),
      title: "O₂ (g, in)",
      unit: "%",
      setpointRanges: const SetpointRanges(
          rangeOk: (21, 35), rangeAbnormal: (18, 35), rangeCritical: (0, 35)),
      displayGroup: DisplayGroup.inlet),
  "pbr_o2_dissolved_l": SetpointRule(
      topicMatcher: RegExp("^pbr[0-9]+/do\$"),
      title: "DO (l)",
      unit: "mg/l",
      setpointRanges: const SetpointRanges(
          rangeOk: (5, 15), rangeAbnormal: (3, 16), rangeCritical: (0, 20)),
      displayGroup: DisplayGroup.liquid),
  "pbr_o2_concentration_g_out": SetpointRule(
      topicMatcher: RegExp("^pbr[0-9]+/o2_2\$"),
      title: "O₂ (g, out)",
      unit: "%",
      setpointRanges: const SetpointRanges(
          rangeOk: (21, 35), rangeAbnormal: (18, 35), rangeCritical: (0, 35)),
      displayGroup: DisplayGroup.outlet),
  "pbr_co2_concentration_g_in": SetpointRule(
      topicMatcher: RegExp("^pbr[0-9]+/co2_1\$"),
      title: "CO₂ (g, in)",
      unit: "ppm",
      setpointRanges: const SetpointRanges(
          rangeOk: (0, 400),
          rangeAbnormal: (0, 1000),
          rangeCritical: (0, 3000)),
      displayGroup: DisplayGroup.inlet),
  "pbr_co2_concentration_g_out": SetpointRule(
      topicMatcher: RegExp("^pbr[0-9]+/co2_2\$"),
      title: "CO₂ (g, out)",
      unit: "ppm",
      setpointRanges: const SetpointRanges(
          rangeOk: (0, 400),
          rangeAbnormal: (0, 1000),
          rangeCritical: (0, 3000)),
      displayGroup: DisplayGroup.outlet),
  "pbr_humidity_g_in": SetpointRule(
      topicMatcher: RegExp("^pbr[0-9]+/rh_1\$"),
      title: "Humidity (g, in)",
      unit: "%",
      setpointRanges: const SetpointRanges(
          rangeOk: (21, 35), rangeAbnormal: (18, 35), rangeCritical: (0, 35)),
      displayGroup: DisplayGroup.inlet),
  "pbr_humidity_g_out": SetpointRule(
      topicMatcher: RegExp("^pbr[0-9]+/rh_2\$"),
      title: "Humidity (g, out)",
      unit: "%",
      setpointRanges: const SetpointRanges(
          rangeOk: (21, 35), rangeAbnormal: (18, 35), rangeCritical: (0, 35)),
      displayGroup: DisplayGroup.outlet),
  "pbr_ph_l": SetpointRule(
      topicMatcher: RegExp("^pbr[0-9]+/ph\$"),
      title: "pH (l)",
      setpointRanges: const SetpointRanges(
          rangeOk: (6, 11), rangeAbnormal: (5, 12), rangeCritical: (0, 14)),
      displayGroup: DisplayGroup.liquid),
  "pbr_optical_density_l": SetpointRule(
      topicMatcher: RegExp("^pbr[0-9]+/od\$"),
      title: "Optical density (l)",
      setpointRanges: const SetpointRanges(
          rangeOk: (0.1, 0.9), rangeAbnormal: (0, 1), rangeCritical: (0, 1)),
      displayGroup: DisplayGroup.liquid),
};

SharedPreferences? _prefs;

@riverpod
class SetpointRules extends _$SetpointRules {
  @override
  SetpointRule? build(String ruleId) {
    _loadAndNotify();
    return _setpointRules[ruleId];
  }

  Future<void> _loadAndNotify() async {
    _prefs ??= await SharedPreferences.getInstance();
    final readJson = _prefs!.getString("sr_$ruleId");
    if (readJson == null) {
      return;
    }
    final setpointRanges = SetpointRanges.fromJson(jsonDecode(readJson));
    if (_setpointRules[ruleId] != null &&
        setpointRanges != _setpointRules[ruleId]!.setpointRanges) {
      _setpointRules[ruleId]!.setpointRanges = setpointRanges;
      ref.notifyListeners();
    }
  }

  Future<void> setSetpointRanges(SetpointRanges setpointRanges) async {
    _setpointRules[ruleId]!.setpointRanges = setpointRanges;
    ref.notifyListeners();
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString("sr_$ruleId", jsonEncode(setpointRanges));
  }
}

@riverpod
Iterable<String> setpointRuleIds(Ref ref) {
  return _setpointRules.keys;
}

@riverpod
SetpointRule? setpointRuleByTopic(Ref ref, String topic) {
  final matches = _setpointRules.entries
      .where((entry) => entry.value.topicMatcher.hasMatch(topic));
  if (matches.length > 1) {
    throw Exception("More than one rule matcher matches topic");
  }
  return matches.firstOrNull?.value;
}
