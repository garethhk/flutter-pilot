import 'dart:developer' as developer;

abstract interface class AppLogger {
  void error(String message, {Object? error, StackTrace? stackTrace});

  void warning(String message, {Object? error, StackTrace? stackTrace});
}

final class DeveloperAppLogger implements AppLogger {
  const DeveloperAppLogger();

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: 'flutter_pilot',
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  void warning(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: 'flutter_pilot',
      level: 900,
      error: error,
      stackTrace: stackTrace,
    );
  }
}

final class NoopAppLogger implements AppLogger {
  const NoopAppLogger();

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {}

  @override
  void warning(String message, {Object? error, StackTrace? stackTrace}) {}
}
