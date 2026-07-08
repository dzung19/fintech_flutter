// =============================================================================
// File: lib/features/loan/domain/usecases/calculate_amortization.dart
// Purpose: Calculate the loan amortization schedule.
//
// Architecture Notes:
// - Strictly uses the decimal package for all calculations.
// - No floating point/double errors.
// =============================================================================

import 'package:decimal/decimal.dart';
import 'package:rational/rational.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/amortization_entry.dart';

class CalculateAmortization {
  const CalculateAmortization();

  /// Calculates the monthly payment and builds the full amortization schedule.
  Result<List<AmortizationEntry>> call({
    required Decimal principal,
    required Decimal annualRate,
    required int termMonths,
  }) {
    if (principal <= Decimal.zero) {
      return const Err(
        ValidationFailure(message: 'Principal must be greater than zero.'),
      );
    }
    if (annualRate < Decimal.zero) {
      return const Err(
        ValidationFailure(message: 'Interest rate cannot be negative.'),
      );
    }
    if (termMonths <= 0) {
      return const Err(
        ValidationFailure(message: 'Term must be greater than zero.'),
      );
    }

    try {
      final List<AmortizationEntry> schedule = [];

      // Monthly interest rate = Annual Rate / 12 / 100 = Annual Rate / 1200
      final Rational monthlyRate =
          annualRate.toRational() / Rational.fromInt(1200);

      Rational monthlyPaymentRational;

      if (monthlyRate == Rational.zero) {
        monthlyPaymentRational =
            principal.toRational() / Rational.fromInt(termMonths);
      } else {
        // Formula: M = P * [r(1+r)^n] / [(1+r)^n - 1]
        final Rational onePlusR = Rational.one + monthlyRate;
        final Rational onePlusRToN = _rationalPow(onePlusR, termMonths);

        final Rational numerator = monthlyRate * onePlusRToN;
        final Rational denominator = onePlusRToN - Rational.one;

        monthlyPaymentRational =
            principal.toRational() * (numerator / denominator);
      }

      final Decimal monthlyPayment = monthlyPaymentRational.toDecimal(
        scaleOnInfinitePrecision: 2,
      );

      Rational remainingBalance = principal.toRational();

      for (int month = 1; month <= termMonths; month++) {
        final Rational interestPaid = remainingBalance * monthlyRate;
        Rational principalPaid = monthlyPaymentRational - interestPaid;

        if (month == termMonths) {
          // Adjust last payment to account for rounding and clean out remaining balance
          principalPaid = remainingBalance;
        }

        remainingBalance = remainingBalance - principalPaid;

        schedule.add(
          AmortizationEntry(
            month: month,
            payment: monthlyPayment,
            principal: principalPaid.toDecimal(scaleOnInfinitePrecision: 2),
            interest: interestPaid.toDecimal(scaleOnInfinitePrecision: 2),
            remainingBalance: remainingBalance.toDecimal(
              scaleOnInfinitePrecision: 2,
            ),
          ),
        );
      }

      return Success(schedule);
    } catch (e) {
      return Err(
        ValidationFailure(message: 'Failed to calculate amortization: $e'),
      );
    }
  }

  Rational _rationalPow(Rational base, int exponent) {
    Rational result = Rational.one;
    for (int i = 0; i < exponent; i++) {
      result = result * base;
    }
    return result;
  }
}
