// =============================================================================
// File: lib/features/card/presentation/bloc/card_bloc.dart
// Purpose: BLoC for credit card state management.
//
// Architecture Notes:
// - Uses flutter_bloc to manage credit card UI states.
// - Depends on GetCards and GetCardTransactions use cases.
// - No business logic in BLoC; delegates everything to use cases.
// =============================================================================

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/result.dart';
import '../../domain/entities/card_transaction.dart';
import '../../domain/entities/credit_card.dart';
import '../../domain/usecases/get_card_transactions.dart';
import '../../domain/usecases/get_cards.dart';

// =============================================================================
// Events
// =============================================================================

sealed class CardEvent extends Equatable {
  const CardEvent();

  @override
  List<Object?> get props => [];
}

class LoadCards extends CardEvent {
  const LoadCards();
}

class LoadCardTransactions extends CardEvent {
  final String cardId;
  final int page;

  const LoadCardTransactions({required this.cardId, this.page = 1});

  @override
  List<Object?> get props => [cardId, page];
}

// =============================================================================
// States
// =============================================================================

sealed class CardState extends Equatable {
  const CardState();

  @override
  List<Object?> get props => [];
}

class CardInitial extends CardState {
  const CardInitial();
}

class CardLoading extends CardState {
  const CardLoading();
}

class CardsLoaded extends CardState {
  final List<CreditCard> cards;
  final Map<String, List<CardTransaction>> transactionsByCard;

  const CardsLoaded({required this.cards, this.transactionsByCard = const {}});

  @override
  List<Object?> get props => [cards, transactionsByCard];

  CardsLoaded copyWith({
    List<CreditCard>? cards,
    Map<String, List<CardTransaction>>? transactionsByCard,
  }) {
    return CardsLoaded(
      cards: cards ?? this.cards,
      transactionsByCard: transactionsByCard ?? this.transactionsByCard,
    );
  }
}

class CardError extends CardState {
  final String message;

  const CardError({required this.message});

  @override
  List<Object?> get props => [message];
}

// =============================================================================
// BLoC
// =============================================================================

class CardBloc extends Bloc<CardEvent, CardState> {
  final GetCards _getCards;
  final GetCardTransactions _getCardTransactions;

  CardBloc({
    required GetCards this._getCards,
    required GetCardTransactions this._getCardTransactions,
  }) : super(const CardInitial()) {
    on<LoadCards>(_onLoadCards);
    on<LoadCardTransactions>(_onLoadCardTransactions);
  }

  Future<void> _onLoadCards(LoadCards event, Emitter<CardState> emit) async {
    emit(const CardLoading());
    final result = await _getCards();

    switch (result) {
      case Success(:final data):
        emit(CardsLoaded(cards: data));
      case Err(:final failure):
        emit(CardError(message: failure.message));
    }
  }

  Future<void> _onLoadCardTransactions(
    LoadCardTransactions event,
    Emitter<CardState> emit,
  ) async {
    final currentState = state;
    if (currentState is! CardsLoaded) return;

    final result = await _getCardTransactions(
      GetCardTransactionsParams(cardId: event.cardId, page: event.page),
    );

    switch (result) {
      case Success(:final data):
        final newTransactions = Map<String, List<CardTransaction>>.from(
          currentState.transactionsByCard,
        );
        newTransactions[event.cardId] = data;
        emit(currentState.copyWith(transactionsByCard: newTransactions));
      case Err(:final failure):
        emit(CardError(message: failure.message));
    }
  }
}
