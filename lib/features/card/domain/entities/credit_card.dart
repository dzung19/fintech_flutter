// =============================================================================
// File: lib/features/card/domain/entities/credit_card.dart
// Purpose: CreditCard domain entity — pure Dart representation.
//
// Architecture Note:
// - Pure Dart: NO Flutter, Dio, or database imports.
// - Uses Decimal for credit limit and current balance.
// - Card number is ALWAYS stored masked — full number never persists
//   on-device. The API must send only the last 4 digits.
// =============================================================================

import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

/// Status of a credit card.
enum CardStatus {
  /// Card is active and usable.
  active,

  /// Card has been temporarily blocked by user or bank.
  blocked,

  /// Card has expired and can no longer be used.
  expired,

  /// Card is pending activation.
  pendingActivation,
}

/// Represents a user's credit card.
///
/// SECURITY: The [maskedNumber] field contains only the last 4 digits
/// (e.g., '•••• •••• •••• 1234'). The full card number is NEVER stored
/// on-device or available through this entity.
class CreditCard extends Equatable {
  /// Unique identifier for this card.
  final String id;

  /// Masked card number — only last 4 digits visible.
  ///
  /// SECURITY: Full PAN (Primary Account Number) is never available
  /// client-side. The server only returns the masked version.
  final String maskedNumber;

  /// Cardholder name as printed on the card.
  final String holderName;

  /// Card expiry date (month/year).
  final DateTime expiryDate;

  /// Maximum credit limit in [Decimal] precision.
  final Decimal creditLimit;

  /// Current outstanding balance on the card in [Decimal] precision.
  final Decimal currentBalance;

  /// Available credit = creditLimit - currentBalance.
  Decimal get availableCredit => creditLimit - currentBalance;

  /// Card network brand (e.g., Visa, Mastercard).
  final String brand;

  /// Current status of the card.
  final CardStatus status;

  const CreditCard({
    required this.id,
    required this.maskedNumber,
    required this.holderName,
    required this.expiryDate,
    required this.creditLimit,
    required this.currentBalance,
    required this.brand,
    required this.status,
  });

  @override
  List<Object?> get props => [
    id,
    maskedNumber,
    holderName,
    expiryDate,
    creditLimit,
    currentBalance,
    brand,
    status,
  ];
}
