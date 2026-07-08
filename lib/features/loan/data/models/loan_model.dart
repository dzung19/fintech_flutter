// =============================================================================
// File: lib/features/loan/data/models/loan_model.dart
// Purpose: Data model for Loan with JSON serialization.
// =============================================================================

import 'package:decimal/decimal.dart';

import '../../domain/entities/loan.dart';

class LoanModel extends Loan {
  const LoanModel({
    required super.id,
    required super.principalAmount,
    required super.annualInterestRate,
    required super.termMonths,
    required super.monthlyPayment,
    required super.startDate,
    required super.status,
  });

  factory LoanModel.fromJson(Map<String, dynamic> json) {
    return LoanModel(
      id: json['id'] as String,
      principalAmount: Decimal.parse(json['principal_amount'].toString()),
      annualInterestRate: Decimal.parse(
        json['annual_interest_rate'].toString(),
      ),
      termMonths: json['term_months'] as int,
      monthlyPayment: Decimal.parse(json['monthly_payment'].toString()),
      startDate: DateTime.parse(json['start_date'] as String),
      status: _parseLoanStatus(json['status'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'principal_amount': principalAmount.toString(),
      'annual_interest_rate': annualInterestRate.toString(),
      'term_months': termMonths,
      'monthly_payment': monthlyPayment.toString(),
      'start_date': startDate.toIso8601String(),
      'status': status.name,
    };
  }

  static LoanStatus _parseLoanStatus(String value) {
    return switch (value.toLowerCase()) {
      'active' => LoanStatus.active,
      'pending_approval' => LoanStatus.pendingApproval,
      'paid_off' => LoanStatus.paidOff,
      'defaulted' => LoanStatus.defaulted,
      _ => LoanStatus.active,
    };
  }
}
