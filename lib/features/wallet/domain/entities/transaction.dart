// =============================================================================
// File: lib/features/wallet/domain/entities/transaction.dart
// Purpose: WalletTransaction entity — pure domain representation.
//
// Architecture Note:
// - Pure Dart: NO Flutter, Dio, or database imports.
// - Uses Decimal for monetary amounts.
// - Named WalletTransaction (not Transaction) to avoid collisions with
//   the built-in dart:developer Transaction class.
// =============================================================================

import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

/// The type of wallet transaction.
enum TransactionType {
  /// Money received / added to wallet.
  credit,

  /// Money sent / deducted from wallet.
  debit,
}

/// The status of a wallet transaction.
enum TransactionStatus {
  /// Transaction is being processed.
  pending,

  /// Transaction completed successfully.
  completed,

  /// Transaction failed.
  failed,

  /// Transaction was reversed/refunded.
  reversed,
}

/// Represents a single transaction on a wallet.
///
/// Each transaction records the [amount] moved, the resulting
/// [balanceAfter] the transaction, and metadata about the transfer.
class WalletTransaction extends Equatable {
  /// Unique identifier for this transaction.
  final String id;

  /// ID of the wallet this transaction belongs to.
  final String walletId;

  /// Transaction amount in [Decimal] precision.
  ///
  /// Always positive — the [type] field indicates direction.
  final Decimal amount;

  /// Whether this is a credit (incoming) or debit (outgoing).
  final TransactionType type;

  /// Current status of the transaction.
  final TransactionStatus status;

  /// Human-readable description (e.g., 'Transfer to John', 'Salary deposit').
  final String description;

  /// Wallet balance AFTER this transaction was applied.
  ///
  /// Stored for auditability — allows rebuilding balance history.
  final Decimal balanceAfter;

  /// When the transaction was created/initiated.
  final DateTime timestamp;

  /// Optional reference ID for the counterparty transaction.
  final String? referenceId;

  const WalletTransaction({
    required this.id,
    required this.walletId,
    required this.amount,
    required this.type,
    required this.status,
    required this.description,
    required this.balanceAfter,
    required this.timestamp,
    this.referenceId,
  });

  @override
  List<Object?> get props => [
    id,
    walletId,
    amount,
    type,
    status,
    description,
    balanceAfter,
    timestamp,
    referenceId,
  ];
}
