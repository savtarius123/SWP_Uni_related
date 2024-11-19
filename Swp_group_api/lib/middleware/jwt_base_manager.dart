import 'package:backend/config/config.dart';
import 'package:corsac_jwt/corsac_jwt.dart';

abstract class JwtBaseManager {
  late final Config config;
  late JWTHmacSha256Signer signer;

  JwtBaseManager(this.config) {
    signer = JWTHmacSha256Signer(config.JWT_SECRET);
  }

  /// Generate a JWT token with the given claim and expiration time.
  /// The claim is a map of key-value pairs that will be stored in the token.
  /// The expiration time is the duration after which the token will expire.
  /// The default expiration time is 15 minutes.
  String getToken(Map<String, dynamic> claim,
      {Duration expiresAfter = const Duration(minutes: 15)}) {
    claim['type'] = tokenType;
    final JWTBuilder builder = JWTBuilder()
      ..issuer = config.JWT_ISSUER
      ..setClaim('data', claim)
      ..expiresAt = DateTime.now().add(expiresAfter);

    return builder.getSignedToken(signer).toString();
  }

  /// Validate the token and return a boolean indicating whether the token is valid.
  /// Returns `true` if the token is valid, or `false` if the token is invalid.
  /// The token is considered valid if it is signed by the JWT signer and the
  /// issuer is correct.
  bool isValidToken(String token) {
    try {
      final JWT jwt = JWT.parse(token);
      final JWTValidator validator = JWTValidator()..issuer = config.JWT_ISSUER;

      if (!jwt.verify(signer)) {
        return false;
      }

      if (validator.validate(jwt).isNotEmpty) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  List<String> getClaimErrors(String token) {
    try {
      final JWT jwt = JWT.parse(token);
      final JWTValidator validator = JWTValidator()..issuer = config.JWT_ISSUER;

      if (!jwt.verify(signer)) {
        return ['The token signature is invalid'];
      }

      return validator.validate(jwt).toList();
    } catch (e) {
      return ['The token is invalid'];
    }
  }

  /// Retrieve the claim from the token. Returns a `Map<String, dynamic>` if the claim
  /// is valid, or an error if the claim is not valid.
  Future<Map<String, dynamic>> getClaim(String token) {
    try {
      final JWT jwt = JWT.parse(token);
      final JWTValidator validator = JWTValidator()..issuer = config.JWT_ISSUER;

      if (!jwt.verify(signer)) {
        throw JWTError('Invalid token: Signature verification failed');
      }

      Set<String> errors = validator.validate(jwt);
      if (validator.validate(jwt).isNotEmpty) {
        throw JWTError('Invalid token: ${errors.first}');
      }

      final data = jwt.getClaim('data');

      if (data is! Map<String, dynamic>) {
        throw JWTError('Invalid token: Claim data is not a map');
      }

      if (!data.containsKey('type') || data['type'] != tokenType) {
        throw JWTError('Invalid token: Claim type is not $tokenType');
      }

      return Future.value(data);
    } catch (e) {
      throw JWTError('Invalid token: $e');
    }
  }

  String get tokenType;
}
