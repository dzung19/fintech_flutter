// =============================================================================
// File: lib/features/wallet/data/datasources/wallet_remote_datasource.dart
// Purpose: Remote data source for wallet API calls.
//
// Architecture Note:
// - Data layer only — may import Dio, models, etc.
// - Throws ServerException on API errors — the repository catches these
//   and converts them to Failure objects.
// - Uses DioClient (which auto-injects Bearer token via AuthInterceptor).
// - Uses centralized ApiEndpoints for path constants.
// =============================================================================

import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/transaction_model.dart';
import '../models/wallet_model.dart';

/// Abstract interface for wallet remote data operations.
///
/// Separated from the implementation to allow mocking in tests.
abstract class WalletRemoteDataSource {
  /// Fetches the current user's wallet from the API.
  ///
  /// Throws [ServerException] if the API call fails.
  Future<WalletModel> getWallet();

  /// Fetches transaction history for the given [walletId].
  ///
  /// Throws [ServerException] if the API call fails.
  Future<List<TransactionModel>> getTransactions({
    required String walletId,
    required int page,
    required int limit,
  });

  /// Initiates a fund transfer to [recipientWalletId].
  ///
  /// Throws [ServerException] if the API call fails.
  Future<TransactionModel> transfer({
    required String recipientWalletId,
    required Decimal amount,
    required String description,
  });
}

/// Implementation of [WalletRemoteDataSource] using [DioClient].
class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final DioClient _dioClient;

  const WalletRemoteDataSourceImpl({required DioClient dioClient})
      : _dioClient = dioClient;

  @override
  Future<WalletModel> getWallet() async {
    try {
      final Response<dynamic> response = await _dioClient.get(
        ApiEndpoints.wallets,
      );

      final Map<String, dynamic> data = response.data as Map<String, dynamic>;
      return WalletModel.fromJson(data);
    } on ServerException {
      rethrow;
    } on Exception catch (e) {
      throw ServerException(message: 'Failed to fetch wallet: $e');
    }
  }

  @override
  Future<List<TransactionModel>> getTransactions({
    required String walletId,
    required int page,
    required int limit,
  }) async {
    try {
      final Response<dynamic> response = await _dioClient.get(
        ApiEndpoints.walletTransactions(walletId),
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      final List<dynamic> dataList = response.data as List<dynamic>;
      return dataList
          .map((dynamic item) =>
              TransactionModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on ServerException {
      rethrow;
    } on Exception catch (e) {
      throw ServerException(message: 'Failed to fetch transactions: $e');
    }
  }

  @override
  Future<TransactionModel> transfer({
    required String recipientWalletId,
    required Decimal amount,
    required String description,
  }) async {
    try {
      final Response<dynamic> response = await _dioClient.post(
        ApiEndpoints.walletTransfer,
        data: {
          'recipient_wallet_id': recipientWalletId,
          // SECURITY: Send amount as string to preserve Decimal precision.
          'amount': amount.toString(),
          'description': description,
        },
      );

      final Map<String, dynamic> data = response.data as Map<String, dynamic>;
      return TransactionModel.fromJson(data);
    } on ServerException {
      rethrow;
    } on Exception catch (e) {
      throw ServerException(message: 'Failed to transfer funds: $e');
    }
  }
}
