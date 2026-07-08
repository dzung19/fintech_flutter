// =============================================================================
// File: lib/features/loan/domain/usecases/get_loans.dart
// Purpose: Fetch all active loans.
// =============================================================================

import '../../../../core/utils/result.dart';
import '../entities/loan.dart';
import '../repositories/loan_repository.dart';

class GetLoans {
  final LoanRepository _repository;

  const GetLoans(this._repository);

  Future<Result<List<Loan>>> call() async {
    return _repository.getLoans();
  }
}
