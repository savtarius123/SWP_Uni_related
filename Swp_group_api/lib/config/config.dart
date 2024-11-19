import 'package:backend/model/src/database.dart';

abstract class Config {
  // Basic API configuration //

  // Host and port for the API
  late final String API_HOST;
  late final int API_PORT;

  // Database configuration //

  // Default admin user information
  late final String DEFAULT_ADMIN_EMAIL;
  late final String DEFAULT_ADMIN_PASSWORD;
  late final String DEFAULT_ADMIN_NAME;

  // Path to the database file, must be absolute
  late final String DATABASE_PATH;

  // Database configuration: These values need to be known during compile time
  // and are found in the database.dart file. They are used to set the
  // constraints on the database tables and to generate the database schema.
  // They are also used in the API to validate user input. Should these values
  // change, the database schema will need to be updated and the API will need
  // to be recompiled.
  final int USERNAME_MIN = DbConfig.USERNAME_MIN;
  final int USERNAME_MAX = DbConfig.USERNAME_MAX;
  final int EMAIL_MIN = DbConfig.EMAIL_MIN;
  final int EMAIL_MAX = DbConfig.EMAIL_MAX;
  final int PASSWORD_MIN = DbConfig.PASSWORD_MIN;
  final int PASSWORD_MAX = DbConfig.PASSWORD_MAX;
  final int GROUP_NAME_MIN = DbConfig.GROUP_NAME_MIN;
  final int GROUP_NAME_MAX = DbConfig.GROUP_NAME_MAX;
  final int GROUP_DESC_MIN = DbConfig.GROUP_DESC_MIN;
  final int GROUP_DESC_MAX = DbConfig.GROUP_DESC_MAX;

  // Miscellaneous validation configuration. These values are enforced during
  // runtime and are not used to generate the database schema. They can be
  // changed without recompiling the API and have no effect on the database.
  // These values determine the maximum number of members in a group and the
  // maximum number of groups a user can own.
  late final int MAX_GROUP_MEMBERS;
  late final int MAX_GROUP_PER_USER;

  // Email configuration
  late final bool RESTRICT_EMAIL_DOMAIN;
  late final String RESTRICTED_EMAIL_DOMAIN;
  late final String SMTP_USERNAME;
  late final String SMTP_PASSWORD;
  late final String SMTP_FROM;
  late final String SMTP_HOST;
  late final int SMTP_PORT;
  late final bool SMTP_SECURE_CONNECTION;

  // Token configuration //

  // Days until a group invitation expires
  late final int INVITATION_EXPIRATION_DAYS;

  // Minutes until a registration token expires
  late final int REG_TOKEN_MINUTES;

  // Minutes until an inactive user is deleted
  late final int INACTIVE_USER_MINUTES;

  // Minutes until a tentative member is removed from a group
  late final int TENTATIVE_MEMBER_MINUTES;

  // Minutes until a JWT token expires
  late final int JWT_EXPIRATION_MINUTES;

  // Days until a JWT refresh token expires
  late final int JWT_REFRESH_EXPIRATION_DAYS;

  // Minutes until a reset token expires
  late final int RESET_TOKEN_MINUTES;

  // Minimum days until an API token expires
  late final int API_TOKEN_MIN_DAYS;

  // Maximum days until an API token expires
  late final int API_TOKEN_MAX_DAYS;

  // Security configuration //

  // Default MAC algorithm for password hashing, either 'SHA256' or 'SHA512'
  late final String SEC_DEFAULT_MAC_ALGORITHM;

  // Length of the salt used for password hashing
  late final int SEC_SALT_LENGTH;

  // Default number of iterations for password hashing
  late final int SEC_DEFAULT_ITERATIONS;

  // Default number of bits for password hashing
  late final int SEC_DEFAULT_BITS;

  // Pepper used for password hashing
  late final String SEC_PASSWORD_PEPPER;

  // JWT configuration for authentication
  late final String JWT_SECRET;
  late final String JWT_ISSUER;

  // Pagination configuration for API responses
  late final int MIN_PAGE_SIZE;
  late final int MAX_PAGE_SIZE;

  // Email templates //

  // Subject and body for a password reset email
  late final String RESET_PASSWORD_SUBJECT;
  late final String RESET_PASSWORD_BODY;

  // Subject and body for an API token email
  late final String API_TOKEN_SUBJECT;
  late final String API_TOKEN_BODY;

  // Subject and body for a group invitation email
  late final String GROUP_INVITATION_SUBJECT;
  late final String GROUP_INVITATION_BODY;

  // Subject and body for a registration email
  late final String REGISTRATION_SUBJECT;
  late final String REGISTRATION_BODY;
}
