// =============================================================================
// File: lib/features/card/domain/usecases/add_card_via_nfc.dart
// Purpose: Use case to read an NFC tag and simulate adding a credit card.
// =============================================================================

import 'package:decimal/decimal.dart';
import '../../../../core/hardware/nfc_service.dart';
import '../../../../core/utils/result.dart';
import '../entities/credit_card.dart';
import 'dart:math';

class AddCardViaNfcUseCase {
  final NfcService _nfcService;

  const AddCardViaNfcUseCase(this._nfcService);

  Future<Result<CreditCard>> call() async {
    final result = await _nfcService.readSingleTag(
      message: 'Hold your card or tag near the device to add it.',
    );

    switch (result) {
      case Success():
        // Here we simulate parsing the NFC tag/card data.
        // In a real EMV scenario, you'd extract the PAN and expiry.
        // Since we are also supporting standard tags ("flashcards"),
        // we'll just generate a mock card when any tag is detected.



        final mockCard = CreditCard(
          id: 'card-${DateTime.now().millisecondsSinceEpoch}',
          maskedNumber: '****-****-****-${Random().nextInt(9000) + 1000}',
          holderName: 'NFC Card User',
          expiryDate: DateTime.now().add(const Duration(days: 365 * 3)),
          creditLimit: Decimal.parse('5000.00'),
          currentBalance: Decimal.parse('0.00'),
          brand: 'NFC-Linked',
          status: CardStatus.active,
        );
        return Success(mockCard);
      case Err(:final failure):
        return Err(failure);
    }
  }
}
