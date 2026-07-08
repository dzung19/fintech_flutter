// =============================================================================
// File: lib/features/loan/domain/entities/amortization_entry.dart
// Purpose: Repesents one row in a loan amortization schedule.
//
// Architecture Notes:
// - Pure Dart.
// - All balance, principal, interest calculations use Decimal.
// =============================================================================

import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

class AmortizationEntry extends Equatable {
  final int month;
  final Decimal payment;
  final Decimal principal;
  final Decimal interest;
  final Decimal remainingBalance;

  const AmortizationEntry({
    required this.month,
    required this.payment,
    required this.principal,
    required this.interest,
    required this.remainingBalance,
  });

  @override
  List<Object?> get props => [
    month,
    payment,
    principal,
    interest,
    remainingBalance,
  ];
}
