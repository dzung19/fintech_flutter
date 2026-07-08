// =============================================================================
// File: lib/features/card/domain/entities/card_transaction.dart
// Purpose: CardTransaction domain entity — pure Dart representation.
//
// Architecture Note:
// - Pure Dart: NO Flutter, Dio, or database imports.
// - Named CardTransaction (not Transaction) to avoid naming collisions.
// - Uses Decimal for the transaction amount.
// =============================================================================

import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

/// Category of a card transaction.
enum CardTransactionCategory {
  food,
  transport,
  shopping,
  entertainment,
  utilities,
  health,
  education,
  travel,
  other,
}

/// Represents a single transaction on a credit card.
class CardTransaction extends Equatable {
  /// Unique identifier for this transaction.
  final String id;

  /// ID of the card this transaction belongs to.
  final String cardId;

  /// Transaction amount in [Decimal] precision.
  final Decimal amount;

  /// Name of the merchant/vendor.
  final String merchant;

  /// Transaction category for expense tracking.
  final CardTransactionCategory category;

  /// When the transaction occurred.
  final DateTime timestamp;

  /// Whether the transaction is still pending settlement.
  final bool isPending;

  const CardTransaction({
    required this.id,
    required this.cardId,
    required this.amount,
    required this.merchant,
    required this.category,
    required this.timestamp,
    this.isPending = false,
  });

  @override
  List<Object?> get props => [
    id,
    cardId,
    amount,
    merchant,
    category,
    timestamp,
    isPending,
  ];
}
