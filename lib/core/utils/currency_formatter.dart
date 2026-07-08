// =============================================================================
// File: lib/core/utils/currency_formatter.dart
// Purpose: Utilities for formatting Decimal currency values and masking
//          sensitive financial identifiers (card numbers, account numbers).
//
// Architecture Note:
// - Uses Decimal (not double) for all monetary values.
// - Pure Dart + intl — safe to import from any layer.
// - SECURITY: Card masking shows only last 4 digits by default.
// =============================================================================

import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';

/// Utility class for formatting currency values and masking financial data.
///
/// All monetary formatting uses [Decimal] to avoid floating-point errors.
///
/// Usage:
/// ```dart
/// CurrencyFormatter.formatVND(Decimal.parse('1500000'));   // '1.500.000 ₫'
/// CurrencyFormatter.formatUSD(Decimal.parse('1234.56'));   // '$1,234.56'
/// CurrencyFormatter.maskCardNumber('4111111111111111');     // '•••• •••• •••• 1111'
/// ```
abstract final class CurrencyFormatter {
  // ===========================================================================
  // Currency Formatting
  // ===========================================================================

  /// Formats a [Decimal] amount as Vietnamese Dong (VND).
  ///
  /// VND has no decimal places (smallest unit is 1 ₫).
  /// Example: `1500000` → `'1.500.000 ₫'`
  static String formatVND(Decimal amount) {
    final NumberFormat formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );
    return formatter.format(amount.toBigInt().toInt());
  }

  /// Formats a [Decimal] amount as US Dollars (USD).
  ///
  /// Example: `1234.56` → `'$1,234.56'`
  static String formatUSD(Decimal amount) {
    final NumberFormat formatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: r'$',
      decimalDigits: 2,
    );
    return formatter.format(amount.toDouble());
  }

  /// Formats a [Decimal] amount with a custom currency code.
  ///
  /// Falls back to ISO 4217 code display (e.g., `'EUR 1,234.56'`).
  static String format(Decimal amount, String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'VND':
        return formatVND(amount);
      case 'USD':
        return formatUSD(amount);
      default:
        final NumberFormat formatter = NumberFormat.currency(
          locale: 'en_US',
          symbol: '$currencyCode ',
          decimalDigits: 2,
        );
        return formatter.format(amount.toDouble());
    }
  }

  /// Formats a [Decimal] as a compact short form.
  ///
  /// Example: `1500000` → `'1.5M'`, `2500` → `'2.5K'`
  static String formatCompact(Decimal amount) {
    final NumberFormat formatter = NumberFormat.compact(locale: 'en_US');
    return formatter.format(amount.toDouble());
  }

  // ===========================================================================
  // Card Number Masking
  // ===========================================================================

  /// Masks a credit/debit card number, showing only the last [visibleDigits].
  ///
  /// SECURITY: Always use this for UI display — never show full card numbers.
  ///
  /// Example:
  /// ```dart
  /// maskCardNumber('4111111111111111');         // '•••• •••• •••• 1111'
  /// maskCardNumber('4111111111111111', visibleDigits: 6); // '•••• •• •••• 111111'
  /// ```
  static String maskCardNumber(String cardNumber, {int visibleDigits = 4}) {
    // Strip all non-digit characters.
    final String digits = cardNumber.replaceAll(RegExp(r'\D'), '');

    if (digits.length < visibleDigits) {
      return digits;
    }

    final int maskedLength = digits.length - visibleDigits;
    final String masked = '•' * maskedLength + digits.substring(maskedLength);

    // Format into groups of 4 for readability.
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < masked.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(masked[i]);
    }
    return buffer.toString();
  }

  /// Masks an account number, showing only the last [visibleDigits].
  ///
  /// Example: `maskAccountNumber('1234567890')` → `'******7890'`
  static String maskAccountNumber(
    String accountNumber, {
    int visibleDigits = 4,
  }) {
    if (accountNumber.length <= visibleDigits) {
      return accountNumber;
    }

    final int maskedLength = accountNumber.length - visibleDigits;
    return '*' * maskedLength + accountNumber.substring(maskedLength);
  }

  // ===========================================================================
  // Percentage Formatting
  // ===========================================================================

  /// Formats a [Decimal] as a percentage string.
  ///
  /// Example: `Decimal.parse('5.75')` → `'5.75%'`
  static String formatPercentage(Decimal rate, {int decimalDigits = 2}) {
    final NumberFormat formatter = NumberFormat.decimalPattern('en_US')
      ..minimumFractionDigits = decimalDigits
      ..maximumFractionDigits = decimalDigits;
    return '${formatter.format(rate.toDouble())}%';
  }
}
