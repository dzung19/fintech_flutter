// =============================================================================
// File: lib/features/wallet/data/repositories/wallet_repository_impl.dart
// Purpose: Concrete implementation of the domain WalletRepository.
//
// Architecture Note:
// - This is the bridge between Data and Domain layers.
// - Catches all exceptions from the data source and converts them to
//   Result<T> (Success or Err with Failure) — no exceptions leak upstream.
// - Registered in the DI container against the abstract WalletRepository
//   type, so use cases depend on the interface, not this implementation.
// =============================================================================

import 'package:decimal/decimal.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/wallet_remote_datasource.dart';

/// Concrete implementation of [WalletRepository].
///
/// Converts data-layer exceptions into domain-layer [Failure] objects
/// wrapped in [Result<T>]. This ensures the domain and presentation
/// layers never deal with raw exceptions.
class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource _remoteDataSource;

  const WalletRepositoryImpl({required WalletRemoteDataSource this._remoteDataSource});

  @override
  Future<Result<Wallet>> getWallet() async {
    try {
      final Wallet wallet = await _remoteDataSource.getWallet();
      return Success(wallet);
    } on AuthenticationException catch (e) {
      return Err(AuthenticationFailure(message: e.message));
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on Exception catch (e) {
      return Err(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Result<List<WalletTransaction>>> getTransactions({
    required String walletId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final List<WalletTransaction> transactions = await _remoteDataSource
          .getTransactions(walletId: walletId, page: page, limit: limit);
      return Success(transactions);
    } on AuthenticationException catch (e) {
      return Err(AuthenticationFailure(message: e.message));
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on Exception catch (e) {
      return Err(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Result<WalletTransaction>> transfer({
    required String recipientWalletId,
    required Decimal amount,
    required String description,
  }) async {
    try {
      final WalletTransaction transaction = await _remoteDataSource.transfer(
        recipientWalletId: recipientWalletId,
        amount: amount,
        description: description,
      );
      return Success(transaction);
    } on AuthenticationException catch (e) {
      return Err(AuthenticationFailure(message: e.message));
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on Exception catch (e) {
      return Err(ServerFailure(message: 'Unexpected error: $e'));
    }
  }
}
