/// Models settings key/value like with meta-information
///
/// Why this complicated? Once instantiated, the data type of a setting can't be
/// changed anymore. With [Setting] being an algebraic data type, type validity
/// is guaranteed during Instantiation. The setter for [Setting.dynamicValue]
/// enforces validity as do the different getter/setter pairs for value within
/// [Setting]'s subclasses.
///
/// Authors:
///   * Heye Hamadmad
library;

sealed class Setting {
  final bool secret;
  final String title;
  final String? category;

  Setting({required this.secret, required this.title, this.category});

  dynamic get dynamicValue {
    switch (this) {
      case SettingString(:String value):
        return value;
      case SettingInteger(:int value):
        return value;
    }
  }

  set dynamicValue(dynamic dynamicValue) {
    switch (this) {
      case SettingString():
        (this as SettingString).value = dynamicValue as String;
      case SettingInteger():
        (this as SettingInteger).value = dynamicValue as int;
    }
  }
}

class SettingString extends Setting {
  late String value;
  SettingString(
      {required super.secret, required super.title, required this.value});
}

class SettingInteger extends Setting {
  late int value;
  SettingInteger(
      {required super.secret, required super.title, required this.value});
}
