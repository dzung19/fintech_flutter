// =============================================================================
// File: lib/features/card/data/repositories/card_repository_impl.dart
// Purpose: Concrete implementation of CardRepository.
// =============================================================================

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/card_transaction.dart';
import '../../domain/entities/credit_card.dart';
import '../../domain/repositories/card_repository.dart';
import '../datasources/card_remote_datasource.dart';

/// Implements [CardRepository] — catches data-layer exceptions and
/// returns [Result<T>] for the domain layer.
class CardRepositoryImpl implements CardRepository {
  final CardRemoteDataSource _remoteDataSource;

  const CardRepositoryImpl({required CardRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<Result<List<CreditCard>>> getCards() async {
    try {
      final List<CreditCard> cards = await _remoteDataSource.getCards();
      return Success(cards);
    } on AuthenticationException catch (e) {
      return Err(AuthenticationFailure(message: e.message));
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on Exception catch (e) {
      return Err(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Result<List<CardTransaction>>> getCardTransactions({
    required String cardId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final List<CardTransaction> transactions = await _remoteDataSource
          .getCardTransactions(cardId: cardId, page: page, limit: limit);
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
  Future<Result<CreditCard>> blockCard({required String cardId}) async {
    try {
      final CreditCard card = await _remoteDataSource.blockCard(cardId: cardId);
      return Success(card);
    } on AuthenticationException catch (e) {
      return Err(AuthenticationFailure(message: e.message));
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on Exception catch (e) {
      return Err(ServerFailure(message: 'Unexpected error: $e'));
    }
  }
}
