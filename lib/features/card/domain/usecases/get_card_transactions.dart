// =============================================================================
// File: lib/features/card/domain/usecases/get_card_transactions.dart
// Purpose: Use case for fetching transactions of a specific credit card.
// =============================================================================

import '../../../../core/utils/result.dart';
import '../entities/card_transaction.dart';
import '../repositories/card_repository.dart';

/// Fetches transactions for a specific credit card.
class GetCardTransactions {
  final CardRepository _repository;

  const GetCardTransactions(this._repository);

  Future<Result<List<CardTransaction>>> call(
    GetCardTransactionsParams params,
  ) async {
    return _repository.getCardTransactions(
      cardId: params.cardId,
      page: params.page,
      limit: params.limit,
    );
  }
}

/// Parameters for [GetCardTransactions].
class GetCardTransactionsParams {
  final String cardId;
  final int page;
  final int limit;

  const GetCardTransactionsParams({
    required this.cardId,
    this.page = 1,
    this.limit = 20,
  });
}
