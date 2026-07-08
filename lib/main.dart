// =============================================================================
// File: lib/main.dart
// Purpose: Application entry point — initializes DI and launches the app.
//
// Architecture Notes:
// - configureDependencies() MUST be awaited before runApp() to ensure
//   all singletons (SecureStorageService, DioClient) are available.
// - WidgetsFlutterBinding.ensureInitialized() is required before any
//   async work in main() (secure storage needs platform channels).
// =============================================================================

import 'package:flutter/material.dart';

import 'core/di/injection_container.dart';

Future<void> main() async {
  // Required before any async calls or platform channel usage in main().
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the dependency injection container.
  // All core services (SecureStorageService, DioClient) are registered here.
  await configureDependencies();

  runApp(const FinTechApp());
}

/// Root widget for the FinTech application.
///
/// This widget configures the global MaterialApp with theming and routing.
/// Feature-level BLoC providers will be added at the router/page level,
/// not here, to keep the root widget lean.
class FinTechApp extends StatelessWidget {
  const FinTechApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinTech App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text(
            'FinTech App — Core Initialized',
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }
}
