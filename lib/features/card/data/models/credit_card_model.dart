// =============================================================================
// File: lib/features/card/data/models/credit_card_model.dart
// Purpose: Data model for CreditCard with JSON serialization.
// =============================================================================

import 'package:decimal/decimal.dart';

import '../../domain/entities/credit_card.dart';

/// Data model for [CreditCard] with JSON serialization.
class CreditCardModel extends CreditCard {
  const CreditCardModel({
    required super.id,
    required super.maskedNumber,
    required super.holderName,
    required super.expiryDate,
    required super.creditLimit,
    required super.currentBalance,
    required super.brand,
    required super.status,
  });

  /// Creates a [CreditCardModel] from a JSON map.
  ///
  /// SECURITY: The API should ONLY send the masked card number.
  /// The full PAN must never appear in API responses.
  factory CreditCardModel.fromJson(Map<String, dynamic> json) {
    return CreditCardModel(
      id: json['id'] as String,
      maskedNumber: json['masked_number'] as String,
      holderName: json['holder_name'] as String,
      expiryDate: DateTime.parse(json['expiry_date'] as String),
      creditLimit: Decimal.parse(json['credit_limit'].toString()),
      currentBalance: Decimal.parse(json['current_balance'].toString()),
      brand: json['brand'] as String,
      status: _parseCardStatus(json['status'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'masked_number': maskedNumber,
      'holder_name': holderName,
      'expiry_date': expiryDate.toIso8601String(),
      'credit_limit': creditLimit.toString(),
      'current_balance': currentBalance.toString(),
      'brand': brand,
      'status': status.name,
    };
  }

  static CardStatus _parseCardStatus(String value) {
    return switch (value.toLowerCase()) {
      'active' => CardStatus.active,
      'blocked' => CardStatus.blocked,
      'expired' => CardStatus.expired,
      'pending_activation' => CardStatus.pendingActivation,
      _ => CardStatus.active,
    };
  }
}
