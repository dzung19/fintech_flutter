// =============================================================================
// File: lib/features/loan/data/repositories/loan_repository_impl.dart
// Purpose: Concrete implementation of LoanRepository.
// =============================================================================

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/loan.dart';
import '../../domain/repositories/loan_repository.dart';
import '../datasources/loan_remote_datasource.dart';

class LoanRepositoryImpl implements LoanRepository {
  final LoanRemoteDataSource _remoteDataSource;

  const LoanRepositoryImpl({required this._remoteDataSource});

  @override
  Future<Result<List<Loan>>> getLoans() async {
    try {
      final List<Loan> loans = await _remoteDataSource.getLoans();
      return Success(loans);
    } on AuthenticationException catch (e) {
      return Err(AuthenticationFailure(message: e.message));
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on Exception catch (e) {
      return Err(ServerFailure(message: 'Unexpected error: $e'));
    }
  }
}
