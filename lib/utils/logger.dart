import 'package:flutter/foundation.dart';

/// Level keparahan untuk pencatatan log.
enum LogLevel { debug, info, warning, error }

/// Class utilitas untuk menampilkan log secara terstruktur dan aman.
///
/// Log hanya dicetak ketika aplikasi berjalan dalam mode debug ([kDebugMode])
/// dan secara otomatis menyensor pola data sensitif.
class Logger {
  /// Mencatat pesan dengan [LogLevel.debug].
  static void debug(String message) {
    _log(LogLevel.debug, message);
  }

  /// Mencatat pesan dengan [LogLevel.info].
  static void info(String message) {
    _log(LogLevel.info, message);
  }

  /// Mencatat pesan dengan [LogLevel.warning].
  static void warning(String message) {
    _log(LogLevel.warning, message);
  }

  /// Mencatat pesan dengan [LogLevel.error].
  static void error(String message, [Object? errorObj]) {
    final fullMessage = errorObj != null ? '$message | Error: $errorObj' : message;
    _log(LogLevel.error, fullMessage);
  }

  /// Method internal untuk mencetak log jika dalam [kDebugMode].
  static void _log(LogLevel level, String message) {
    if (!kDebugMode) return;

    final timestamp = DateTime.now().toIso8601String();
    final label = level.name.toUpperCase();
    final safeMessage = _maskSensitive(message);

    debugPrint('[$timestamp] [$label] $safeMessage');
  }

  /// Menyensor nilai sensitif seperti API key, token, atau password
  /// agar tidak tercatat di log.
  static String _maskSensitive(String input) {
    return input.replaceAllMapped(
      RegExp(
        r'(api[_-]?key|token|password|secret)\s*[:=]\s*\S+',
        caseSensitive: false,
      ),
      (match) => '${match.group(1)}=***REDACTED***',
    );
  }
}

