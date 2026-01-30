import 'dart:math';

/// Utility class for security-related operations.
class SecurityUtils {
  static const String _defaultCharset = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

  /// Generates a cryptographically secure random string.
  ///
  /// [length] The length of the generated string. Defaults to 6.
  /// [charset] The characters to use for generation. Defaults to alphanumeric.
  static String generateSecureString({
    int length = 6,
    String charset = _defaultCharset,
  }) {
    final random = Random.secure();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => charset.codeUnitAt(random.nextInt(charset.length)),
      ),
    );
  }
}
