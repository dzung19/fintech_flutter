// =============================================================================
// File: lib/features/wallet/data/models/wallet_model.dart
// Purpose: Data model extending the domain Wallet entity with JSON
//          serialization capabilities.
//
// Architecture Note:
// - Data layer model — may import Dio, JSON, etc.
// - Extends the domain entity so it IS-A Wallet and can be used
//   directly by use cases without mapping.
// - Decimal values are parsed from JSON strings to avoid double conversion.
//   The API must send amounts as strings (e.g., "1500.50") not numbers.
// =============================================================================

import 'package:decimal/decimal.dart';

import '../../domain/entities/wallet.dart';

/// Data model for [Wallet] with JSON serialization.
///
/// Extends the domain entity so it can pass through use cases
/// without an additional mapping step.
class WalletModel extends Wallet {
  const WalletModel({
    required super.id,
    required super.userId,
    required super.balance,
    required super.currency,
    required super.name,
    required super.createdAt,
    super.isActive,
  });

  /// Creates a [WalletModel] from a JSON map (API response).
  ///
  /// IMPORTANT: [balance] is parsed from a String to preserve
  /// Decimal precision. The API MUST send monetary values as strings.
  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      balance: Decimal.parse(json['balance'].toString()),
      currency: json['currency'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  /// Serializes this model to a JSON map for API requests.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'balance': balance.toString(),
      'currency': currency,
      'name': name,
      'created_at': createdAt.toIso8601String(),
      'is_active': isActive,
    };
  }
}
