// =============================================================================
// File: lib/features/card/data/models/card_transaction_model.dart
// Purpose: Data model for CardTransaction with JSON serialization.
// =============================================================================

import 'package:decimal/decimal.dart';

import '../../domain/entities/card_transaction.dart';

/// Data model for [CardTransaction] with JSON serialization.
class CardTransactionModel extends CardTransaction {
  const CardTransactionModel({
    required super.id,
    required super.cardId,
    required super.amount,
    required super.merchant,
    required super.category,
    required super.timestamp,
    super.isPending,
  });

  factory CardTransactionModel.fromJson(Map<String, dynamic> json) {
    return CardTransactionModel(
      id: json['id'] as String,
      cardId: json['card_id'] as String,
      amount: Decimal.parse(json['amount'].toString()),
      merchant: json['merchant'] as String,
      category: _parseCategory(json['category'] as String),
      timestamp: DateTime.parse(json['timestamp'] as String),
      isPending: json['is_pending'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'card_id': cardId,
      'amount': amount.toString(),
      'merchant': merchant,
      'category': category.name,
      'timestamp': timestamp.toIso8601String(),
      'is_pending': isPending,
    };
  }

  static CardTransactionCategory _parseCategory(String value) {
    return switch (value.toLowerCase()) {
      'food' => CardTransactionCategory.food,
      'transport' => CardTransactionCategory.transport,
      'shopping' => CardTransactionCategory.shopping,
      'entertainment' => CardTransactionCategory.entertainment,
      'utilities' => CardTransactionCategory.utilities,
      'health' => CardTransactionCategory.health,
      'education' => CardTransactionCategory.education,
      'travel' => CardTransactionCategory.travel,
      _ => CardTransactionCategory.other,
    };
  }
}
