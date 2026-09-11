import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'core/app_dependencies.dart';
import 'features/home/home.dart';

void main() {
  final dependencies = AppDependencies();
  runZonedGuarded(
    () {
      WidgetsFlutterBinding.ensureInitialized();
      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        dependencies.logger.error(
          'Unhandled Flutter framework error',
          error: details.exception,
          stackTrace: details.stack,
        );
      };
      PlatformDispatcher.instance.onError = (error, stackTrace) {
        dependencies.logger.error(
          'Unhandled platform error',
          error: error,
          stackTrace: stackTrace,
        );
        return true;
      };
      runApp(MyApp(dependencies: dependencies));
    },
    (error, stackTrace) => dependencies.logger.error(
      'Unhandled asynchronous error',
      error: error,
      stackTrace: stackTrace,
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void dispose() {
    widget.dependencies.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hope2',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Home(
        menuRepository: widget.dependencies.menuRepository,
        router: widget.dependencies.router,
      ),
    );
  }
}
