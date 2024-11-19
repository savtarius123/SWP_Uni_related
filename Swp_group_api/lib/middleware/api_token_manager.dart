import 'package:backend/middleware/jwt_base_manager.dart';

class ApiTokenManger extends JwtBaseManager {
  ApiTokenManger(super.config);

  /// Generates a token for the user with the given [email].
  /// The token will contain the email as a claim in the 'data' field.
  /// The token will be valid for the duration specified by the [daysValid]
  /// parameter. If no value is provided, the token will be valid for 30 days.
  String generateToken(final String email, {final int daysValid = 30}) {
    return super
        .getToken({'email': email}, expiresAfter: Duration(days: daysValid));
  }

  /// Retrieves the email from the token. If the token is invalid, the method
  /// will return with an error.
  Future<String> getEmail(String token) {
    return super.getClaim(token).then((claim) {
      return claim['email'];
    });
  }

  @override
  String get tokenType => 'api';
}
