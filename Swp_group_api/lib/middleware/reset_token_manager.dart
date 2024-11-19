import 'package:backend/config/config.dart';
import 'package:backend/middleware/jwt_base_manager.dart';

class ResetTokenManager extends JwtBaseManager {
  ResetTokenManager(super.config);

  /// Generates a token for the user with the given [email].
  /// The token will contain the email as a claim in the 'data' field.
  /// The token will be valid for the duration specified in the Config value
  /// [Config.RESET_TOKEN_MINUTES].
  String generateToken(final String email) {
    final Duration duration = Duration(days: config.RESET_TOKEN_MINUTES);

    return super.getToken({'email': email}, expiresAfter: duration);
  }

  /// Retrieves the email from the token. If the token is invalid, the method
  /// will return with an error.
  Future<String> getEmail(String token) {
    return super.getClaim(token).then((claim) {
      return claim['email'];
    });
  }

  @override
  String get tokenType => 'reset';
}
