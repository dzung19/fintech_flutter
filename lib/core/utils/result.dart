// =============================================================================
// File: lib/core/utils/result.dart
// Purpose: Functional error handling via a sealed Result type.
//
// Architecture Note:
// - This is the bridge between the Data and Domain layers.
// - Repositories return Result<T> instead of throwing exceptions.
// - BLoCs pattern-match on Success/Failure to emit the correct state.
// - Pure Dart — no Flutter imports.
//
// Usage:
// ```dart
// final Result<Wallet> result = await walletRepository.getWallet();
// switch (result) {
//   case Success(:final data):
//     emit(WalletLoaded(wallet: data));
//   case Err(:final failure):
//     emit(WalletError(failure: failure));
// }
// ```
// =============================================================================

import 'package:equatable/equatable.dart';

import '../errors/failures.dart';

/// A discriminated union representing either a successful value or a failure.
///
/// Dart 3 sealed classes enable exhaustive pattern matching — the compiler
/// ensures every switch statement handles both [Success] and [Err].
sealed class Result<T> extends Equatable {
  const Result();
}

/// Represents a successful operation carrying the resulting [data].
final class Success<T> extends Result<T> {
  final T data;

  const Success(this.data);

  @override
  List<Object?> get props => [data];
}

/// Represents a failed operation carrying a [Failure] describing what went wrong.
final class Err<T> extends Result<T> {
  final Failure failure;

  const Err(this.failure);

  @override
  List<Object?> get props => [failure];
}
