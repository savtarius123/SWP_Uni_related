import 'dart:convert';
import 'dart:math';

import 'package:backend/config/config.dart';
import 'package:cryptography/cryptography.dart';

final class PasswordUtils {
  late final Config config;
  late final String _pepper;
  late final int _saltLength;
  late final Random _random;
  late final Pbkdf2 _pbkdf2;

  PasswordUtils(this.config) {
    _pepper = config.SEC_PASSWORD_PEPPER;
    _saltLength = config.SEC_SALT_LENGTH;
    _random = Random.secure();
    _pbkdf2 = Pbkdf2(
      macAlgorithm: _getMacAlgorithm(config.SEC_DEFAULT_MAC_ALGORITHM),
      iterations: config.SEC_DEFAULT_ITERATIONS,
      bits: config.SEC_DEFAULT_BITS,
    );
  }

  MacAlgorithm _getMacAlgorithm(final String macAlgorithm) {
    switch (macAlgorithm) {
      case 'sha256':
        return Hmac.sha256();
      case 'sha512':
        return Hmac.sha512();
      default:
        return Hmac.sha256();
    }
  }

  Future<String> hashPassword(final String password, final String salt) async {
    final List<int> nonce = utf8.encode('$salt$_pepper');

    final SecretKey key =
        await _pbkdf2.deriveKeyFromPassword(password: password, nonce: nonce);
    final List<int> keyBytes = await key.extractBytes();

    return base64.encode(keyBytes);
  }

  Future<bool> verifyPassword(
          final String password, final String salt, final String hash) async =>
      hash == await hashPassword(password, salt);

  Future<String> generateSalt() async {
    return base64
        .encode(List<int>.generate(_saltLength, (_) => _random.nextInt(256)));
  }
}
