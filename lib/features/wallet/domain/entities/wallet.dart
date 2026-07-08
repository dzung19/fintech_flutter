// =============================================================================
// File: lib/features/wallet/domain/entities/wallet.dart
// Purpose: Core Wallet entity — pure domain representation.
//
// Architecture Note:
// - Pure Dart: NO Flutter, Dio, or database imports.
// - Uses Decimal for the balance — never double for financial values.
// - Uses Equatable for value equality in BLoC state comparisons.
// - This entity is what BLoCs and Use Cases work with.
//   The Data layer has a corresponding WalletModel that extends this.
// =============================================================================

import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

/// Represents a user's digital wallet.
///
/// The [balance] field uses [Decimal] to ensure precision in financial
/// calculations — floating-point arithmetic (double) causes rounding
/// errors that are unacceptable in FinTech contexts.
class Wallet extends Equatable {
  /// Unique identifier for this wallet.
  final String id;

  /// ID of the wallet owner.
  final String userId;

  /// Current available balance in [Decimal] precision.
  ///
  /// IMPORTANT: This is ALWAYS a Decimal, never a double. All arithmetic
  /// on this value must use Decimal operations to maintain precision.
  final Decimal balance;

  /// ISO 4217 currency code (e.g., 'USD', 'VND', 'EUR').
  final String currency;

  /// Human-readable wallet name (e.g., 'Primary Wallet', 'Savings').
  final String name;

  /// Timestamp when the wallet was created.
  final DateTime createdAt;

  /// Whether the wallet is currently active and usable.
  final bool isActive;

  const Wallet({
    required this.id,
    required this.userId,
    required this.balance,
    required this.currency,
    required this.name,
    required this.createdAt,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        balance,
        currency,
        name,
        createdAt,
        isActive,
      ];
}
