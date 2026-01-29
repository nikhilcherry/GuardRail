import 'dart:math';

class SecurityUtils {
  static final Random _secureRandom = Random.secure();

  static const String alphanumeric = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  static const String uppercaseAlphanumeric = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  static const String digits = '0123456789';

  /// Generates a cryptographically secure random ID
  static String generateId({
    int length = 6,
    String chars = alphanumeric,
    String prefix = '',
  }) {
    final buffer = StringBuffer(prefix);
    for (int i = 0; i < length; i++) {
      buffer.write(chars[_secureRandom.nextInt(chars.length)]);
    }
    return buffer.toString();
  }
}
