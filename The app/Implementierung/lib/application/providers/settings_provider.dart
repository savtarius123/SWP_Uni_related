/// Manages application settings, including retrieving and updating settings
/// Includes persistence support
///
/// Authors:
///   * Heye Hamadmad
///   * Arin Tanriverdi
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/setting.dart';
import '../util/random_string.dart';

part 'settings_provider.g.dart';

/// Default values for settings
final Map<String, Setting> _settings = {
  "mqtt_ws_uri": SettingString(
      value: "ws://127.0.0.1", title: "MQTT WebSocket URI", secret: false),
  "mqtt_client_id": SettingString(
      value: "C&B:${randomString(8)}",
      title: "MQTT Client ID",
      secret: false), // Client ID should be unique but persistent per instance
  "mqtt_user":
      SettingString(value: "mqtt", title: "MQTT Username", secret: false),
  "mqtt_pass":
      SettingString(value: "mqtt", title: "MQTT Password", secret: true),
  "influx_uri": SettingString(
      value: "http://localhost:8086/query",
      title: "InfluxDB URI",
      secret: false),
  "influx_dbname": SettingString(
      value: "openhab_db", title: "InfluxDB DB Name", secret: false),
  "influx_username": SettingString(
      value: "openhab", title: "InfluxDB Username", secret: false),
  "influx_password": SettingString(
      value: "passwort", title: "InfluxDB Password", secret: true),
};

SharedPreferences? _prefs;

@riverpod
class Settings extends _$Settings {
  @override
  Future<Setting?> build(String settingId) async {
    _prefs ??= await SharedPreferences.getInstance();
    switch (_settings[settingId]) {
      case null:
        return null;
      case SettingString():
        late final String? readValue;
        readValue = _prefs!.getString(settingId);
        if (readValue != null) {
          _settings[settingId]?.dynamicValue = readValue;
        }
      case SettingInteger():
        late final int? readValue;
        readValue = _prefs!.getInt(settingId);
        if (readValue != null) {
          _settings[settingId]?.dynamicValue = readValue;
        }
        if (readValue != null) {
          _settings[settingId]?.dynamicValue = readValue;
        }
    }
    return _settings[settingId];
  }

  Future<void> setData(dynamic data) async {
    _prefs ??= await SharedPreferences.getInstance();
    switch (_settings[settingId]) {
      case null:
        throw Exception("Setting ID must be predefined");
      case SettingString():
        await _prefs!.setString(settingId, data);
      case SettingInteger():
        await _prefs!.setInt(settingId, data);
    }

    _settings[settingId]?.dynamicValue = data;

    ref.invalidateSelf();
  }
}

@riverpod
Iterable<String> settingIds(Ref ref) {
  return _settings.keys;
}
