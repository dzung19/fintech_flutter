// =============================================================================
// File: lib/features/wallet/domain/repositories/wallet_repository.dart
// Purpose: Abstract repository interface for wallet operations.
//
// Architecture Note:
// - Pure Dart: This is a DOMAIN layer contract — no implementation details.
// - Returns Result<T> for functional error handling.
// - The Data layer provides the concrete implementation
//   (WalletRepositoryImpl) which talks to APIs and local storage.
// - Registered in the DI container against this abstract type so the
//   domain/presentation layers are decoupled from the data layer.
// =============================================================================

import 'package:decimal/decimal.dart';

import '../../../../core/utils/result.dart';
import '../entities/transaction.dart';
import '../entities/wallet.dart';

/// Contract for wallet data operations.
///
/// This abstract class defines WHAT the wallet feature can do,
/// not HOW it does it. The Data layer's [WalletRepositoryImpl]
/// provides the concrete implementation.
///
/// All methods return [Result<T>] — either a [Success] with data
/// or an [Err] with a [Failure] object. No exceptions leak to callers.
abstract class WalletRepository {
  /// Fetches the current user's primary wallet.
  ///
  /// Returns [Success<Wallet>] on success, [Err] with a failure otherwise.
  Future<Result<Wallet>> getWallet();

  /// Fetches the transaction history for the given [walletId].
  ///
  /// Supports pagination via [page] and [limit].
  /// Returns [Success<List<WalletTransaction>>] on success.
  Future<Result<List<WalletTransaction>>> getTransactions({
    required String walletId,
    int page = 1,
    int limit = 20,
  });

  /// Transfers [amount] from the user's wallet to [recipientWalletId].
  ///
  /// Validates locally that [amount] > 0 before making the API call.
  /// Returns [Success<WalletTransaction>] with the resulting transaction
  /// record on success.
  Future<Result<WalletTransaction>> transfer({
    required String recipientWalletId,
    required Decimal amount,
    required String description,
  });
}
