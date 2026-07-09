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

import '../../features/card/data/datasources/card_remote_datasource.dart';
import '../../features/card/data/repositories/card_repository_impl.dart';
import '../../features/card/domain/repositories/card_repository.dart';
import '../../features/card/domain/usecases/get_card_transactions.dart';
import '../../features/card/domain/usecases/get_cards.dart';
import '../../features/card/domain/usecases/add_card_via_nfc.dart';
import '../../features/card/presentation/bloc/card_bloc.dart';
import '../../features/loan/data/datasources/loan_remote_datasource.dart';
import '../../features/loan/data/repositories/loan_repository_impl.dart';
import '../../features/loan/domain/repositories/loan_repository.dart';
import '../../features/loan/domain/usecases/calculate_amortization.dart';
import '../../features/loan/domain/usecases/get_loans.dart';
import '../../features/loan/presentation/bloc/loan_bloc.dart';
import '../../features/wallet/data/datasources/wallet_remote_datasource.dart';
import '../../features/wallet/data/repositories/wallet_repository_impl.dart';
import '../../features/wallet/domain/repositories/wallet_repository.dart';
import '../../features/wallet/domain/usecases/get_transactions.dart';
import '../../features/wallet/domain/usecases/get_wallet_balance.dart';
import '../../features/wallet/domain/usecases/transfer_funds.dart';
import '../../features/wallet/presentation/bloc/wallet_bloc.dart';
import '../network/dio_client.dart';
import '../security/secure_storage_service.dart';
import '../hardware/nfc_service.dart';

/// Global service locator instance.
final GetIt getIt = GetIt.instance;

/// Initializes all dependency registrations.
Future<void> configureDependencies() async {
  // Core infrastructure
  _registerCoreServices();

  // Features
  _registerWalletFeature();
  _registerCardFeature();
  _registerLoanFeature();
}

/// Registers core infrastructure services (security, networking).
void _registerCoreServices() {
  getIt.registerLazySingleton<SecureStorageService>(
    () => SecureStorageService(),
  );

  getIt.registerLazySingleton<DioClient>(
    () => DioClient.withInterceptors(
      secureStorageService: getIt<SecureStorageService>(),
    ),
  );

  getIt.registerLazySingleton<NfcService>(() => NfcServiceImpl());
}

/// Registers Wallet feature layers in the DI container.
void _registerWalletFeature() {
  // Data Sources
  getIt.registerLazySingleton<WalletRemoteDataSource>(
    () => WalletRemoteDataSourceImpl(dioClient: getIt()),
  );

  // Repositories
  getIt.registerLazySingleton<WalletRepository>(
    () => WalletRepositoryImpl(remoteDataSource: getIt()),
  );

  // Use Cases
  getIt.registerLazySingleton(() => GetWalletBalance(getIt()));
  getIt.registerLazySingleton(() => GetTransactions(getIt()));
  getIt.registerLazySingleton(() => TransferFunds(getIt()));

  // BLoC
  getIt.registerFactory(
    () => WalletBloc(
      getWalletBalance: getIt(),
      getTransactions: getIt(),
      transferFunds: getIt(),
    ),
  );
}

/// Registers Credit Card feature layers in the DI container.
void _registerCardFeature() {
  // Data Sources
  getIt.registerLazySingleton<CardRemoteDataSource>(
    () => CardRemoteDataSourceImpl(dioClient: getIt()),
  );

  // Repositories
  getIt.registerLazySingleton<CardRepository>(
    () => CardRepositoryImpl(remoteDataSource: getIt()),
  );

  // Use Cases
  getIt.registerLazySingleton(() => GetCards(getIt()));
  getIt.registerLazySingleton(() => GetCardTransactions(getIt()));
  getIt.registerLazySingleton(() => AddCardViaNfcUseCase(getIt()));

  // BLoC
  getIt.registerFactory(
    () => CardBloc(
      getCards: getIt(),
      getCardTransactions: getIt(),
      addCardViaNfc: getIt(),
    ),
  );
}

/// Registers Loan feature layers in the DI container.
void _registerLoanFeature() {
  // Data Sources
  getIt.registerLazySingleton<LoanRemoteDataSource>(
    () => LoanRemoteDataSourceImpl(dioClient: getIt()),
  );

  // Repositories
  getIt.registerLazySingleton<LoanRepository>(
    () => LoanRepositoryImpl(remoteDataSource: getIt()),
  );

  // Use Cases
  getIt.registerLazySingleton(() => GetLoans(getIt()));
  getIt.registerLazySingleton(() => const CalculateAmortization());

  // BLoC
  getIt.registerFactory(
    () => LoanBloc(getLoans: getIt(), calculateAmortization: getIt()),
  );
}
