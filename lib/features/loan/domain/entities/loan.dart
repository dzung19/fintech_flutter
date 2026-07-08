// =============================================================================
// File: lib/features/loan/domain/entities/loan.dart
// Purpose: Core Loan entity.
//
// Architecture Notes:
// - Pure Dart: NO external dependencies other than Equatable/Decimal.
// - All balance/interest values use Decimal.
// =============================================================================

import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

enum LoanStatus { active, pendingApproval, paidOff, defaulted }

class Loan extends Equatable {
  final String id;
  final Decimal principalAmount;
  final Decimal annualInterestRate; // e.g. 5.75% is parsed as 5.75
  final int termMonths;
  final Decimal monthlyPayment;
  final DateTime startDate;
  final LoanStatus status;

  const Loan({
    required this.id,
    required this.principalAmount,
    required this.annualInterestRate,
    required this.termMonths,
    required this.monthlyPayment,
    required this.startDate,
    required this.status,
  });

  @override
  List<Object?> get props => [
    id,
    principalAmount,
    annualInterestRate,
    termMonths,
    monthlyPayment,
    startDate,
    status,
  ];
}
