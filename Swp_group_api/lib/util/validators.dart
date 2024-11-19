import 'package:backend/config/config.dart';
import 'package:email_validator/email_validator.dart';
import 'package:backend/model/src/database.dart';

class Validators {
  late final Config config;

  Validators(this.config);

  bool isValidUserId(dynamic value) {
    return value != null && value is int && value > 0;
  }

  bool isValidName(dynamic value) {
    return value != null &&
        value is String &&
        value.isNotEmpty &&
        value.length >= config.USERNAME_MIN &&
        value.length <= config.USERNAME_MAX;
  }

  bool isValidEmail(dynamic value) {
    return value != null &&
        value is String &&
        value.isNotEmpty &&
        EmailValidator.validate(value) &&
        (config.RESTRICT_EMAIL_DOMAIN
            ? value.split('@')[1] == config.RESTRICTED_EMAIL_DOMAIN
            : true) &&
        value.length >= config.EMAIL_MIN &&
        value.length <= config.EMAIL_MAX;
  }

  bool isValidPassword(dynamic value) {
    return value != null &&
        value is String &&
        value.isNotEmpty &&
        value.length >= config.PASSWORD_MIN &&
        value.length <= config.PASSWORD_MAX;
  }

  bool isValidPlatform(dynamic value) {
    return value != null &&
        value is int &&
        value >= UserPlatform.minItem &&
        value <= UserPlatform.maxItem;
  }

  bool isValidRole(dynamic value) {
    return value != null &&
        value is int &&
        value >= Role.minItem &&
        value <= Role.maxItem;
  }

  bool isValidGroupId(dynamic value) {
    return value != null && value is int && value >= 0;
  }

  bool isValidGroupName(dynamic value) {
    return value != null &&
        value is String &&
        value.isNotEmpty &&
        value.length >= config.GROUP_NAME_MIN &&
        value.length <= config.GROUP_NAME_MAX;
  }

  bool isValidGroupDescription(dynamic value) {
    return value != null &&
        value is String &&
        value.isNotEmpty &&
        value.length >= config.GROUP_DESC_MIN &&
        value.length <= config.GROUP_DESC_MAX;
  }

  bool isValidDays(dynamic value) {
    return value != null &&
        value is int &&
        value >= config.API_TOKEN_MIN_DAYS &&
        value <= config.API_TOKEN_MAX_DAYS;
  }

  bool isValidPage(dynamic value) {
    return value != null && value is int && value >= 0;
  }

  bool isValidPageSize(dynamic value) {
    return value != null &&
        value is int &&
        value >= config.MIN_PAGE_SIZE &&
        value <= config.MAX_PAGE_SIZE;
  }
}
