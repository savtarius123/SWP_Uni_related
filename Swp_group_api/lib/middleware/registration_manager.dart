import 'package:backend/config/config.dart';
import 'package:backend/middleware/jwt_base_manager.dart';
import 'package:corsac_jwt/corsac_jwt.dart';

class RegistrationManager extends JwtBaseManager {
  RegistrationManager(super.config);

  /// Generates a token for the user with the given [userId].
  /// The token will contain the userId as a claim in the 'data' field.
  /// The token will be valid for the duration specified by the Config value
  /// [Config.REG_TOKEN_MINUTES].
  String generateToken(final int userId, final String email) {
    final Duration duration = Duration(minutes: config.REG_TOKEN_MINUTES);

    return super
        .getToken({'userId': userId, 'email': email}, expiresAfter: duration);
  }

  /// Retrieves the userId from the token. If the token is invalid, the method
  /// will return with an error.
  Future<int> getUserId(final String token) {
    return super.getClaim(token).then((claim) {
      if (!claim.containsKey('userId')) {
        throw JWTError('Invalid token: missing userId');
      }

      return claim['userId'];
    });
  }

  @override
  String get tokenType => 'registration';
}
