/// Generate a nice and harmless random string without cryptographic security
///
/// Authors:
///   * Probably only ChatGPT
library;

import 'dart:math';

/// Generate a nice and harmless random string without cryptographic security
String randomString(int length) {
  const characters =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  Random random = Random();

  return List.generate(
      length, (index) => characters[random.nextInt(characters.length)]).join();
}
