// =============================================================================
// File: lib/features/loan/presentation/bloc/loan_bloc.dart
// Purpose: BLoC for managing loan dashboard and calculations.
// =============================================================================

import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/result.dart';
import '../../domain/entities/amortization_entry.dart';
import '../../domain/entities/loan.dart';
import '../../domain/usecases/calculate_amortization.dart';
import '../../domain/usecases/get_loans.dart';

// =============================================================================
// Events
// =============================================================================

sealed class LoanEvent extends Equatable {
  const LoanEvent();

  @override
  List<Object?> get props => [];
}

class LoadLoans extends LoanEvent {
  const LoadLoans();
}

class RunAmortizationCalculation extends LoanEvent {
  final Decimal principal;
  final Decimal annualRate;
  final int termMonths;

  const RunAmortizationCalculation({
    required this.principal,
    required this.annualRate,
    required this.termMonths,
  });

  @override
  List<Object?> get props => [principal, annualRate, termMonths];
}

// =============================================================================
// States
// =============================================================================

sealed class LoanState extends Equatable {
  const LoanState();

  @override
  List<Object?> get props => [];
}

class LoanInitial extends LoanState {
  const LoanInitial();
}

class LoanLoading extends LoanState {
  const LoanLoading();
}

class LoansLoaded extends LoanState {
  final List<Loan> loans;
  final List<AmortizationEntry> calculatedSchedule;

  const LoansLoaded({required this.loans, this.calculatedSchedule = const []});

  @override
  List<Object?> get props => [loans, calculatedSchedule];

  LoansLoaded copyWith({
    List<Loan>? loans,
    List<AmortizationEntry>? calculatedSchedule,
  }) {
    return LoansLoaded(
      loans: loans ?? this.loans,
      calculatedSchedule: calculatedSchedule ?? this.calculatedSchedule,
    );
  }
}

class LoanError extends LoanState {
  final String message;

  const LoanError({required this.message});

  @override
  List<Object?> get props => [message];
}

// =============================================================================
// BLoC
// =============================================================================

class LoanBloc extends Bloc<LoanEvent, LoanState> {
  final GetLoans _getLoans;
  final CalculateAmortization _calculateAmortization;

  LoanBloc({
    required GetLoans this._getLoans,
    required CalculateAmortization this._calculateAmortization,
  }) : super(const LoanInitial()) {
    on<LoadLoans>(_onLoadLoans);
    on<RunAmortizationCalculation>(_onRunAmortizationCalculation);
  }

  Future<void> _onLoadLoans(LoadLoans event, Emitter<LoanState> emit) async {
    emit(const LoanLoading());
    final result = await _getLoans();

    switch (result) {
      case Success(:final data):
        emit(LoansLoaded(loans: data));
      case Err(:final failure):
        emit(LoanError(message: failure.message));
    }
  }

  void _onRunAmortizationCalculation(
    RunAmortizationCalculation event,
    Emitter<LoanState> emit,
  ) {
    final currentState = state;
    List<Loan> existingLoans = [];
    if (currentState is LoansLoaded) {
      existingLoans = currentState.loans;
    }

    final result = _calculateAmortization(
      principal: event.principal,
      annualRate: event.annualRate,
      termMonths: event.termMonths,
    );

    switch (result) {
      case Success(:final data):
        emit(LoansLoaded(loans: existingLoans, calculatedSchedule: data));
      case Err(:final failure):
        emit(LoanError(message: failure.message));
    }
  }
}
