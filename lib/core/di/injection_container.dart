// =============================================================================
// File: lib/core/di/injection_container.dart
// Purpose: Central Dependency Injection configuration using get_it.
//
// Architecture Notes:
// - ALL injectable services are registered here — this is the single source
//   of truth for the object graph.
// - Use LazySingleton for services that should be created on first access
//   and reused across the app lifetime (e.g., DioClient, SecureStorageService).
// - Use Factory for objects that need a fresh instance each time (e.g., BLoCs).
// - Registration order matters: register dependencies BEFORE dependents.
// - This file imports from the data and core layers only — the domain layer
//   remains pure and unaware of DI.
//
// Call [configureDependencies()] once in main() before runApp().
// =============================================================================

import 'package:get_it/get_it.dart';

import '../network/dio_client.dart';
import '../security/secure_storage_service.dart';

/// Global service locator instance.
///
/// Access services anywhere via: `getIt<ServiceType>()`
///
/// Example:
/// ```dart
/// final storage = getIt<SecureStorageService>();
/// final client = getIt<DioClient>();
/// ```
final GetIt getIt = GetIt.instance;

/// Initializes all dependency registrations.
///
/// MUST be called once and awaited in `main()` before `runApp()`.
///
/// ```dart
/// Future<void> main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await configureDependencies();
///   runApp(const FinTechApp());
/// }
/// ```
///
/// Registration is organized by architectural layer:
/// 1. Core Services (security, networking)
/// 2. Data Sources (remote/local) — added per feature
/// 3. Repositories — added per feature
/// 4. Use Cases — added per feature
/// 5. BLoCs/Cubits — added per feature
Future<void> configureDependencies() async {
  // =========================================================================
  // Core Services
  // =========================================================================
  _registerCoreServices();

  // =========================================================================
  // Feature: Wallet
  // =========================================================================
  // TODO: _registerWalletFeature();

  // =========================================================================
  // Feature: Card
  // =========================================================================
  // TODO: _registerCardFeature();

  // =========================================================================
  // Feature: Loan
  // =========================================================================
  // TODO: _registerLoanFeature();
}

/// Registers core infrastructure services (security, networking).
///
/// These services are shared across all features and have no feature-specific
/// dependencies.
void _registerCoreServices() {
  // ---------------------------------------------------------------------------
  // SecureStorageService — LazySingleton
  //
  // Why LazySingleton:
  // - Only one instance should exist to avoid inconsistent reads/writes.
  // - Lazy so the encrypted storage is initialized only when first needed,
  //   not at app startup (slightly faster cold start).
  // ---------------------------------------------------------------------------
  getIt.registerLazySingleton<SecureStorageService>(
    () => SecureStorageService(),
  );

  // ---------------------------------------------------------------------------
  // DioClient — LazySingleton
  //
  // Why LazySingleton:
  // - HTTP client with interceptors should be reused to leverage connection
  //   pooling and consistent configuration across all API calls.
  // - Depends on SecureStorageService (must be registered above).
  // ---------------------------------------------------------------------------
  getIt.registerLazySingleton<DioClient>(
    () => DioClient.withInterceptors(
      secureStorageService: getIt<SecureStorageService>(),
    ),
  );
}

// =============================================================================
// Feature Registration Templates
//
// Each feature follows the same pattern:
// 1. Data Sources (Remote/Local) → LazySingleton
// 2. Repository (implements domain interface) → LazySingleton
// 3. Use Cases → LazySingleton (stateless) or Factory (stateful)
// 4. BLoCs/Cubits → Factory (each screen gets its own instance)
//
// Example:
// void _registerWalletFeature() {
//   // Data Sources
//   getIt.registerLazySingleton<WalletRemoteDataSource>(
//     () => WalletRemoteDataSourceImpl(dioClient: getIt()),
//   );
//
//   // Repositories (register against the abstract interface)
//   getIt.registerLazySingleton<WalletRepository>(
//     () => WalletRepositoryImpl(
//       remoteDataSource: getIt(),
//     ),
//   );
//
//   // Use Cases
//   getIt.registerLazySingleton(() => GetWalletBalance(getIt()));
//   getIt.registerLazySingleton(() => TransferFunds(getIt()));
//
//   // BLoC — Factory so each screen gets a fresh instance with
//   // its own state lifecycle.
//   getIt.registerFactory(
//     () => WalletBloc(
//       getWalletBalance: getIt(),
//       transferFunds: getIt(),
//     ),
//   );
// }
// =============================================================================
