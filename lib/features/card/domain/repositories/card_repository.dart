// =============================================================================
// File: lib/features/card/domain/repositories/card_repository.dart
// Purpose: Abstract repository interface for credit card operations.
//
// Architecture Note:
// - Pure Dart domain contract — no implementation details.
// - Returns Result<T> for functional error handling.
// =============================================================================

import '../../../../core/utils/result.dart';
import '../entities/card_transaction.dart';
import '../entities/credit_card.dart';

/// Contract for credit card data operations.
abstract class CardRepository {
  /// Fetches all credit cards for the current user.
  Future<Result<List<CreditCard>>> getCards();

  /// Fetches transactions for a specific card.
  Future<Result<List<CardTransaction>>> getCardTransactions({
    required String cardId,
    int page = 1,
    int limit = 20,
  });

  /// Blocks/freezes a card (user-initiated security action).
  Future<Result<CreditCard>> blockCard({required String cardId});
}
