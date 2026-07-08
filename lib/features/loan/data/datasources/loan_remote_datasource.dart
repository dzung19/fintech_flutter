// =============================================================================
// File: lib/features/loan/data/datasources/loan_remote_datasource.dart
// Purpose: Remote data source for loan API calls.
// =============================================================================

import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/loan_model.dart';

abstract class LoanRemoteDataSource {
  Future<List<LoanModel>> getLoans();
}

class LoanRemoteDataSourceImpl implements LoanRemoteDataSource {
  final DioClient _dioClient;

  const LoanRemoteDataSourceImpl({required DioClient dioClient})
      : _dioClient = dioClient;

  @override
  Future<List<LoanModel>> getLoans() async {
    try {
      final Response<dynamic> response = await _dioClient.get(
        ApiEndpoints.loans,
      );

      final List<dynamic> dataList = response.data as List<dynamic>;
      return dataList
          .map((dynamic item) =>
              LoanModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on ServerException {
      rethrow;
    } on Exception catch (e) {
      throw ServerException(message: 'Failed to fetch loans: $e');
    }
  }
}
