// lib/core/logger/app_logger.dart

enum LogLevel { debug, info, error }

class AppLogger {
  static const String _reset  = '\x1B[0m';
  static const String _cyan   = '\x1B[36m';
  static const String _green  = '\x1B[32m';
  static const String _red    = '\x1B[31m';

  static void _log(LogLevel level, String message, {String? tag}) {
    final timestamp = DateTime.now().toIso8601String();
    final prefix = tag != null ? '[$tag] ' : '';
    switch (level) {
      case LogLevel.debug:
        // ignore: avoid_print
        print('$_cyan[DEBUG]$_reset $timestamp ${prefix}$message');
        break;
      case LogLevel.info:
        // ignore: avoid_print
        print('$_green[INFO]$_reset  $timestamp ${prefix}$message');
        break;
      case LogLevel.error:
        // ignore: avoid_print
        print('$_red[ERROR]$_reset $timestamp ${prefix}$message');
        break;
    }
  }

  static void debug(String message, {String? tag}) =>
      _log(LogLevel.debug, message, tag: tag);

  static void info(String message, {String? tag}) =>
      _log(LogLevel.info, message, tag: tag);

  static void error(String message, {String? tag}) =>
      _log(LogLevel.error, message, tag: tag);
}
