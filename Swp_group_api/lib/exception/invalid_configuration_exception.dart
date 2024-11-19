class InvalidConfigurationException implements Exception {
  final String message;
  final String key;

  InvalidConfigurationException(this.message, this.key);

  @override
  String toString() {
    return 'InvalidConfigurationException: $message (key: $key)';
  }
}
