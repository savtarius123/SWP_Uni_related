import 'package:backend/config/config.dart';
import 'package:backend/model/src/database.dart';

class ProductionConfig implements Config {
  static final instance = ProductionConfig._internal();

  factory ProductionConfig() {
    return instance;
  }

  ProductionConfig._internal() {
    API_HOST = '0.0.0.0';
    API_PORT = 8090;
    DEFAULT_ADMIN_EMAIL = 'admin@something.com';
    DEFAULT_ADMIN_PASSWORD = 'adminpassword';
    DEFAULT_ADMIN_NAME = 'Admin User';
    DATABASE_PATH = '/tmp/swp_database.db';
    MAX_GROUP_MEMBERS = 6;
    MAX_GROUP_PER_USER = 1;
    API_TOKEN_MIN_DAYS = 1;
    API_TOKEN_MAX_DAYS = 365;
    RESTRICT_EMAIL_DOMAIN = false;
    RESTRICTED_EMAIL_DOMAIN = 'something.com';
    SMTP_USERNAME = 'test';
    SMTP_PASSWORD = 'password';
    SMTP_FROM = 'swp@something.com';
    SMTP_HOST = 'localhost';
    SMTP_PORT = 1025;
    SMTP_SECURE_CONNECTION = false;
    INVITATION_EXPIRATION_DAYS = 7;
    REG_TOKEN_MINUTES = 15;
    INACTIVE_USER_MINUTES = 15;
    TENTATIVE_MEMBER_MINUTES = 15;
    JWT_EXPIRATION_MINUTES = 15;
    JWT_REFRESH_EXPIRATION_DAYS = 7;
    RESET_TOKEN_MINUTES = 1;
    SEC_DEFAULT_MAC_ALGORITHM = 'sha256';
    SEC_SALT_LENGTH = 32;
    SEC_DEFAULT_ITERATIONS = 100000;
    SEC_DEFAULT_BITS = 256;
    SEC_PASSWORD_PEPPER = '';
    JWT_SECRET = 'some_secret';
    JWT_ISSUER = 'localhost';
    MIN_PAGE_SIZE = 1;
    MAX_PAGE_SIZE = 64;
    RESET_PASSWORD_SUBJECT = 'SWP Group Tool Password Reset';
    RESET_PASSWORD_BODY = 'You have $RESET_TOKEN_MINUTES '
        'minutes to reset your password. Please follow the instructions in the '
        'application to reset your password.\n\nToken: ';
    API_TOKEN_SUBJECT = 'SWP Group Tool API Token';
    API_TOKEN_BODY = 'Attached is your API token for the SWP '
        'Group Tool service. This token must be included in the header of all '
        'requests to the service that require API authorization, using the '
        'ApiToken header.\n\nToken: ';
    GROUP_INVITATION_SUBJECT = 'SWP Group Tool Invitation';
    GROUP_INVITATION_BODY = 'You have been invited to join a '
        'group on the SWP Group Tool service. Please follow the instructions in '
        'the application to accept the invitation.\n\nToken: ';
    REGISTRATION_SUBJECT = 'SWP Group Tool Registration';
    REGISTRATION_BODY = 'You have ${REG_TOKEN_MINUTES} '
        'minutes to verify your email address. Please open the following link to '
        'complete your registration:\n\n'
        'https://$API_HOST:$API_PORT/api/auth/verify_registration/';
  }

  // API configuration
  @override
  @override
  late final String API_HOST;
  @override
  late final int API_PORT;

  // Database configuration
  @override
  late final String DEFAULT_ADMIN_EMAIL;
  @override
  late final String DEFAULT_ADMIN_PASSWORD;
  @override
  late final String DEFAULT_ADMIN_NAME;

  @override
  late final String DATABASE_PATH;

  // Validation configuration
  late final int MAX_GROUP_MEMBERS;
  @override
  late final int MAX_GROUP_PER_USER;
  @override
  late final int API_TOKEN_MIN_DAYS;
  @override
  late final int API_TOKEN_MAX_DAYS;

  // Email configuration
  @override
  late final bool RESTRICT_EMAIL_DOMAIN;
  @override
  late final String RESTRICTED_EMAIL_DOMAIN;
  @override
  late final String SMTP_USERNAME;
  @override
  late final String SMTP_PASSWORD;
  @override
  late final String SMTP_FROM;
  @override
  late final String SMTP_HOST;
  @override
  late final int SMTP_PORT;
  @override
  late final bool SMTP_SECURE_CONNECTION;

  // Token configuration
  @override
  late final int INVITATION_EXPIRATION_DAYS;
  @override
  late final int REG_TOKEN_MINUTES;
  @override
  late final int INACTIVE_USER_MINUTES;
  @override
  late final int TENTATIVE_MEMBER_MINUTES;
  @override
  late final int JWT_EXPIRATION_MINUTES;
  @override
  late final int JWT_REFRESH_EXPIRATION_DAYS;
  @override
  late final int RESET_TOKEN_MINUTES;

  // Security configuration
  @override
  late final String SEC_DEFAULT_MAC_ALGORITHM;
  @override
  late final int SEC_SALT_LENGTH;
  @override
  late final int SEC_DEFAULT_ITERATIONS;
  @override
  late final int SEC_DEFAULT_BITS;
  @override
  late final String SEC_PASSWORD_PEPPER;
  @override
  late final String JWT_SECRET;
  @override
  late final String JWT_ISSUER;

  // Pagination configuration
  @override
  late final int MIN_PAGE_SIZE;
  @override
  late final int MAX_PAGE_SIZE;

  @override
  late final String RESET_PASSWORD_SUBJECT;
  @override
  late final String RESET_PASSWORD_BODY;

  @override
  late final String API_TOKEN_SUBJECT;
  @override
  late final String API_TOKEN_BODY;

  @override
  late final String GROUP_INVITATION_SUBJECT;
  @override
  late final String GROUP_INVITATION_BODY;

  @override
  late final String REGISTRATION_SUBJECT;
  @override
  late final String REGISTRATION_BODY;

  @override
  int get EMAIL_MAX => DbConfig.EMAIL_MAX;
  @override
  int get EMAIL_MIN => DbConfig.EMAIL_MIN;
  @override
  int get GROUP_DESC_MAX => DbConfig.GROUP_DESC_MAX;
  @override
  int get GROUP_DESC_MIN => DbConfig.GROUP_DESC_MIN;
  @override
  int get GROUP_NAME_MAX => DbConfig.GROUP_NAME_MAX;
  @override
  int get GROUP_NAME_MIN => DbConfig.GROUP_NAME_MIN;
  @override
  int get PASSWORD_MAX => DbConfig.PASSWORD_MAX;
  @override
  int get PASSWORD_MIN => DbConfig.PASSWORD_MIN;
  @override
  int get USERNAME_MAX => DbConfig.USERNAME_MAX;
  @override
  int get USERNAME_MIN => DbConfig.USERNAME_MIN;
}
