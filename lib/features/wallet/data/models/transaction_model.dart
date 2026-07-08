// =============================================================================
// File: lib/features/wallet/data/models/transaction_model.dart
// Purpose: Data model extending WalletTransaction with JSON serialization.
//
// Architecture Note:
// - Extends the domain entity for zero-cost mapping.
// - Decimal amounts parsed from strings to maintain precision.
// - Enum parsing uses explicit mapping for type safety.
// =============================================================================

import 'package:decimal/decimal.dart';

import '../../domain/entities/transaction.dart';

/// Data model for [WalletTransaction] with JSON serialization.
class TransactionModel extends WalletTransaction {
  const TransactionModel({
    required super.id,
    required super.walletId,
    required super.amount,
    required super.type,
    required super.status,
    required super.description,
    required super.balanceAfter,
    required super.timestamp,
    super.referenceId,
  });

  /// Creates a [TransactionModel] from a JSON map (API response).
  ///
  /// Monetary fields ([amount], [balanceAfter]) are parsed from strings.
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      walletId: json['wallet_id'] as String,
      amount: Decimal.parse(json['amount'].toString()),
      type: _parseTransactionType(json['type'] as String),
      status: _parseTransactionStatus(json['status'] as String),
      description: json['description'] as String,
      balanceAfter: Decimal.parse(json['balance_after'].toString()),
      timestamp: DateTime.parse(json['timestamp'] as String),
      referenceId: json['reference_id'] as String?,
    );
  }

  /// Serializes this model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'wallet_id': walletId,
      'amount': amount.toString(),
      'type': type.name,
      'status': status.name,
      'description': description,
      'balance_after': balanceAfter.toString(),
      'timestamp': timestamp.toIso8601String(),
      'reference_id': referenceId,
    };
  }

  /// Parses a string into a [TransactionType] enum value.
  static TransactionType _parseTransactionType(String value) {
    return switch (value.toLowerCase()) {
      'credit' => TransactionType.credit,
      'debit' => TransactionType.debit,
      _ => TransactionType.debit,
    };
  }

  /// Parses a string into a [TransactionStatus] enum value.
  static TransactionStatus _parseTransactionStatus(String value) {
    return switch (value.toLowerCase()) {
      'pending' => TransactionStatus.pending,
      'completed' => TransactionStatus.completed,
      'failed' => TransactionStatus.failed,
      'reversed' => TransactionStatus.reversed,
      _ => TransactionStatus.pending,
    };
  }
}
