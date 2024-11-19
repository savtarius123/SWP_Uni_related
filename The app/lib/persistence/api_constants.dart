class ApiConstants {
  // Base URL for the API (replace with actual URL)
  static const String baseUrl = 'http://localhost:8080/api';

  // Authentication API endpoints
  static String getLoginUrl() => '$baseUrl/auth/login';
  static String getLogoutUrl() => '$baseUrl/auth/logout';
  static String getRegisterUrl() => '$baseUrl/auth/register';
  static String getRefreshTokenUrl() => '$baseUrl/auth/refresh';
}
