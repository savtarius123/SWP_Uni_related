import 'package:backend/config/config.dart';
import 'package:backend/middleware/jwt_base_manager.dart';

class AuthManager extends JwtBaseManager {
  AuthManager(super.config);

  /// Generates a token for the user with the given [userId].
  /// The token will be valid for the duration specified by the Config value
  /// [Config.JWT_EXPIRATION_MINUTES]. The token will contain the userId as a claim
  /// in the 'data' field.
  String generateAuthToken(int userId) {
    final Duration duration = Duration(minutes: config.JWT_EXPIRATION_MINUTES);

    return super.getToken({'userId': userId}, expiresAfter: duration);
  }

  /// Generates a refresh token for the user with the given [userId].
  /// The token will be valid for the duration specified by the Config value
  /// [Config.JWT_REFRESH_EXPIRATION_DAYS]. The token will contain the userId as a
  /// claim in the 'data' field.
  String generateRefreshToken(int userId) {
    final Duration duration =
        Duration(days: config.JWT_REFRESH_EXPIRATION_DAYS);

    return super.getToken({'userId': userId}, expiresAfter: duration);
  }

  /// Retrieves the userId from the token. If the token is invalid, the method
  /// will return with an error.
  Future<int> getUserId(String token) {
    return super.getClaim(token).then((claim) {
      return claim['userId'];
    });
  }

  @override
  String get tokenType => 'auth';
}
