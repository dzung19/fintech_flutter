// =============================================================================
// File: lib/features/wallet/domain/usecases/get_wallet_balance.dart
// Purpose: Use case for fetching the current wallet and its balance.
//
// Architecture Note:
// - Use cases encapsulate a single business action.
// - They depend on the abstract WalletRepository (not the implementation).
// - Pure Dart — no Flutter imports.
// =============================================================================

import '../../../../core/utils/result.dart';
import '../entities/wallet.dart';
import '../repositories/wallet_repository.dart';

/// Fetches the current user's wallet including its balance.
///
/// This use case is intentionally thin — it delegates directly to the
/// repository. Its value is as a named, injectable unit that BLoCs
/// depend on (rather than depending on the full repository interface).
class GetWalletBalance {
  final WalletRepository _repository;

  const GetWalletBalance(this._repository);

  /// Executes the use case.
  ///
  /// Returns [Result<Wallet>] — either [Success] with the wallet data
  /// or [Err] with a failure.
  Future<Result<Wallet>> call() async {
    return _repository.getWallet();
  }
}
