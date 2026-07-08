// =============================================================================
// File: lib/features/loan/domain/repositories/loan_repository.dart
// Purpose: Abstract repository contract for loans.
// =============================================================================

import '../../../../core/utils/result.dart';
import '../entities/loan.dart';

abstract class LoanRepository {
  Future<Result<List<Loan>>> getLoans();
}
