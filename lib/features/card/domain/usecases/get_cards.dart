// =============================================================================
// File: lib/features/card/domain/usecases/get_cards.dart
// Purpose: Use case for fetching the user's credit cards.
// =============================================================================

import '../../../../core/utils/result.dart';
import '../entities/credit_card.dart';
import '../repositories/card_repository.dart';

/// Fetches all credit cards belonging to the current user.
class GetCards {
  final CardRepository _repository;

  const GetCards(this._repository);

  Future<Result<List<CreditCard>>> call() async {
    return _repository.getCards();
  }
}
