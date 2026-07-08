// =============================================================================
// File: lib/features/wallet/presentation/bloc/wallet_bloc.dart
// Purpose: BLoC for wallet state management.
//
// Architecture Notes:
// - Uses flutter_bloc for complex state transitions.
// - Depends on Use Cases (not repositories directly).
// - No business logic here — validation lives in use cases, data fetching
//   lives in repositories. BLoC only orchestrates: dispatch → call → emit.
// - All states extend Equatable for efficient rebuild detection.
// =============================================================================

import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/result.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/usecases/get_transactions.dart';
import '../../domain/usecases/get_wallet_balance.dart';
import '../../domain/usecases/transfer_funds.dart';

// =============================================================================
// Events
// =============================================================================

/// Base event for the Wallet BLoC.
sealed class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

/// Triggered to load the user's wallet (balance, details).
final class LoadWallet extends WalletEvent {
  const LoadWallet();
}

/// Triggered to load transaction history for the current wallet.
final class LoadTransactions extends WalletEvent {
  final String walletId;
  final int page;

  const LoadTransactions({required this.walletId, this.page = 1});

  @override
  List<Object?> get props => [walletId, page];
}

/// Triggered to submit a fund transfer.
final class SubmitTransfer extends WalletEvent {
  final String recipientWalletId;
  final Decimal amount;
  final String description;

  const SubmitTransfer({
    required this.recipientWalletId,
    required this.amount,
    required this.description,
  });

  @override
  List<Object?> get props => [recipientWalletId, amount, description];
}

// =============================================================================
// States
// =============================================================================

/// Base state for the Wallet BLoC.
sealed class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object?> get props => [];
}

/// Initial state — no data loaded yet.
final class WalletInitial extends WalletState {
  const WalletInitial();
}

/// Loading state — data is being fetched.
final class WalletLoading extends WalletState {
  const WalletLoading();
}

/// Successfully loaded wallet data.
final class WalletLoaded extends WalletState {
  final Wallet wallet;
  final List<WalletTransaction> transactions;

  const WalletLoaded({required this.wallet, this.transactions = const []});

  @override
  List<Object?> get props => [wallet, transactions];

  /// Creates a copy with updated fields — useful for partial state updates.
  WalletLoaded copyWith({
    Wallet? wallet,
    List<WalletTransaction>? transactions,
  }) {
    return WalletLoaded(
      wallet: wallet ?? this.wallet,
      transactions: transactions ?? this.transactions,
    );
  }
}

/// Transfer in progress.
final class WalletTransferring extends WalletState {
  const WalletTransferring();
}

/// Transfer completed successfully.
final class WalletTransferSuccess extends WalletState {
  final WalletTransaction transaction;

  const WalletTransferSuccess({required this.transaction});

  @override
  List<Object?> get props => [transaction];
}

/// Error state with a human-readable message.
final class WalletError extends WalletState {
  final String message;

  const WalletError({required this.message});

  @override
  List<Object?> get props => [message];
}

// =============================================================================
// BLoC
// =============================================================================

/// Manages wallet state: loading balance, fetching transactions, transfers.
///
/// Depends on three use cases injected via constructor.
/// Each event handler follows the pattern:
///   1. Emit loading state
///   2. Call use case
///   3. Pattern-match on Result<T> → emit success or error state
class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final GetWalletBalance _getWalletBalance;
  final GetTransactions _getTransactions;
  final TransferFunds _transferFunds;

  WalletBloc({
    required GetWalletBalance getWalletBalance,
    required GetTransactions getTransactions,
    required TransferFunds transferFunds,
  }) : _getWalletBalance = getWalletBalance,
       _getTransactions = getTransactions,
       _transferFunds = transferFunds,
       super(const WalletInitial()) {
    on<LoadWallet>(_onLoadWallet);
    on<LoadTransactions>(_onLoadTransactions);
    on<SubmitTransfer>(_onSubmitTransfer);
  }

  /// Handles [LoadWallet] — fetches the user's wallet.
  Future<void> _onLoadWallet(
    LoadWallet event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletLoading());

    final Result<Wallet> result = await _getWalletBalance.call();

    switch (result) {
      case Success(:final data):
        emit(WalletLoaded(wallet: data));
      case Err(:final failure):
        emit(WalletError(message: failure.message));
    }
  }

  /// Handles [LoadTransactions] — fetches transaction history.
  ///
  /// If the wallet is already loaded, preserves it and updates transactions.
  Future<void> _onLoadTransactions(
    LoadTransactions event,
    Emitter<WalletState> emit,
  ) async {
    final Result<List<WalletTransaction>> result = await _getTransactions.call(
      GetTransactionsParams(walletId: event.walletId, page: event.page),
    );

    switch (result) {
      case Success(:final data):
        final WalletState currentState = state;
        if (currentState is WalletLoaded) {
          emit(currentState.copyWith(transactions: data));
        }
      case Err(:final failure):
        emit(WalletError(message: failure.message));
    }
  }

  /// Handles [SubmitTransfer] — initiates a fund transfer.
  Future<void> _onSubmitTransfer(
    SubmitTransfer event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletTransferring());

    final Result<WalletTransaction> result = await _transferFunds.call(
      TransferParams(
        recipientWalletId: event.recipientWalletId,
        amount: event.amount,
        description: event.description,
      ),
    );

    switch (result) {
      case Success(:final data):
        emit(WalletTransferSuccess(transaction: data));
      case Err(:final failure):
        emit(WalletError(message: failure.message));
    }
  }
}
