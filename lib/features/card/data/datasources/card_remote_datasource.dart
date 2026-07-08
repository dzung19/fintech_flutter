// =============================================================================
// File: lib/features/card/data/datasources/card_remote_datasource.dart
// Purpose: Remote data source for credit card API calls.
// =============================================================================

import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/card_transaction_model.dart';
import '../models/credit_card_model.dart';

/// Abstract interface for card remote data operations.
abstract class CardRemoteDataSource {
  Future<List<CreditCardModel>> getCards();

  Future<List<CardTransactionModel>> getCardTransactions({
    required String cardId,
    required int page,
    required int limit,
  });

  Future<CreditCardModel> blockCard({required String cardId});
}

/// Implementation using [DioClient].
class CardRemoteDataSourceImpl implements CardRemoteDataSource {
  final DioClient _dioClient;

  const CardRemoteDataSourceImpl({required DioClient dioClient})
      : _dioClient = dioClient;

  @override
  Future<List<CreditCardModel>> getCards() async {
    try {
      final Response<dynamic> response = await _dioClient.get(
        ApiEndpoints.cards,
      );

      final List<dynamic> dataList = response.data as List<dynamic>;
      return dataList
          .map((dynamic item) =>
              CreditCardModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on ServerException {
      rethrow;
    } on Exception catch (e) {
      throw ServerException(message: 'Failed to fetch cards: $e');
    }
  }

  @override
  Future<List<CardTransactionModel>> getCardTransactions({
    required String cardId,
    required int page,
    required int limit,
  }) async {
    try {
      final Response<dynamic> response = await _dioClient.get(
        ApiEndpoints.cardTransactions(cardId),
        queryParameters: {'page': page, 'limit': limit},
      );

      final List<dynamic> dataList = response.data as List<dynamic>;
      return dataList
          .map((dynamic item) =>
              CardTransactionModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on ServerException {
      rethrow;
    } on Exception catch (e) {
      throw ServerException(message: 'Failed to fetch card transactions: $e');
    }
  }

  @override
  Future<CreditCardModel> blockCard({required String cardId}) async {
    try {
      final Response<dynamic> response = await _dioClient.post(
        ApiEndpoints.blockCard(cardId),
      );

      final Map<String, dynamic> data = response.data as Map<String, dynamic>;
      return CreditCardModel.fromJson(data);
    } on ServerException {
      rethrow;
    } on Exception catch (e) {
      throw ServerException(message: 'Failed to block card: $e');
    }
  }
}
