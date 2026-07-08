// =============================================================================
// File: lib/features/wallet/domain/usecases/transfer_funds.dart
// Purpose: Use case for transferring funds between wallets.
//
// Architecture Note:
// - Contains domain-level validation (amount > 0).
// - Returns a ValidationFailure immediately for invalid input,
//   without hitting the network — fail fast.
// - Pure Dart — no Flutter imports.
// =============================================================================

import 'package:decimal/decimal.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/transaction.dart';
import '../repositories/wallet_repository.dart';

/// Transfers funds from the current user's wallet to a recipient.
///
/// This use case performs domain-level validation before delegating
/// to the repository:
/// - Amount must be greater than zero.
/// - Recipient wallet ID must not be empty.
class TransferFunds {
  final WalletRepository _repository;

  const TransferFunds(this._repository);

  /// Executes the transfer with the given [params].
  ///
  /// Returns [Err] with [ValidationFailure] if input is invalid.
  /// Returns [Result<WalletTransaction>] from the repository otherwise.
  Future<Result<WalletTransaction>> call(TransferParams params) async {
    // --- Domain validation (no network call needed) ---

    if (params.amount <= Decimal.zero) {
      return const Err(
        ValidationFailure(
          message: 'Transfer amount must be greater than zero.',
        ),
      );
    }

    if (params.recipientWalletId.trim().isEmpty) {
      return const Err(
        ValidationFailure(message: 'Recipient wallet ID is required.'),
      );
    }

    if (params.description.trim().isEmpty) {
      return const Err(
        ValidationFailure(message: 'Transfer description is required.'),
      );
    }

    // --- Delegate to repository ---

    return _repository.transfer(
      recipientWalletId: params.recipientWalletId,
      amount: params.amount,
      description: params.description,
    );
  }
}

/// Parameters for the [TransferFunds] use case.
class TransferParams {
  /// Target wallet to receive the funds.
  final String recipientWalletId;

  /// Amount to transfer in [Decimal] precision.
  final Decimal amount;

  /// Mandatory description for the transfer.
  final String description;

  const TransferParams({
    required this.recipientWalletId,
    required this.amount,
    required this.description,
  });
}
