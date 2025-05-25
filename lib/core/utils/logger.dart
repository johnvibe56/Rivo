import 'dart:developer' as developer;

class Logger {
  static bool _debug = false;

  static void setDebug(bool value) {
    _debug = value;
  }

  static void d(String message, {String? tag}) {
    if (_debug) {
      developer.log(
        message,
        name: tag ?? 'Rivo',
        level: 900, // Just a level to make it show up in the console
      );
    }
  }

  static void e(dynamic error, StackTrace stackTrace, {String? tag}) {
    if (_debug) {
      developer.log(
        error.toString(),
        name: tag ?? 'Rivo',
        error: error is Error ? error : null,
        stackTrace: stackTrace,
        level: 1000, // Error level
      );
    }
  }
}
