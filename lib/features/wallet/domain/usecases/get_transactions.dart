// =============================================================================
// File: lib/features/wallet/domain/usecases/get_transactions.dart
// Purpose: Use case for fetching wallet transaction history.
//
// Architecture Note:
// - Pure Dart use case — depends only on abstract repository.
// - Encapsulates pagination parameters as a typed Params class.
// =============================================================================

import '../../../../core/utils/result.dart';
import '../entities/transaction.dart';
import '../repositories/wallet_repository.dart';

/// Fetches the transaction history for a specific wallet.
///
/// Supports pagination through [GetTransactionsParams].
class GetTransactions {
  final WalletRepository _repository;

  const GetTransactions(this._repository);

  /// Executes the use case with the given [params].
  ///
  /// Returns [Result<List<WalletTransaction>>] — the list of transactions
  /// or a failure.
  Future<Result<List<WalletTransaction>>> call(
    GetTransactionsParams params,
  ) async {
    return _repository.getTransactions(
      walletId: params.walletId,
      page: params.page,
      limit: params.limit,
    );
  }
}

/// Parameters for the [GetTransactions] use case.
class GetTransactionsParams {
  final String walletId;
  final int page;
  final int limit;

  const GetTransactionsParams({
    required this.walletId,
    this.page = 1,
    this.limit = 20,
  });
}
