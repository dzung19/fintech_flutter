// =============================================================================
// File: lib/features/card/presentation/pages/card_page.dart
// Purpose: Credit Card dashboard UI page.
//
// Architecture Notes:
// - Strictly presentation code.
// - Connects with CardBloc to build states.
// - Zero business logic in widgets.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/card_transaction.dart';
import '../../domain/entities/credit_card.dart';
import '../bloc/card_bloc.dart';

class CardPage extends StatelessWidget {
  const CardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Cards')),
      body: BlocConsumer<CardBloc, CardState>(
        listener: (context, state) {
          if (state is CardError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return switch (state) {
            CardInitial() => const _InitialView(),
            CardLoading() => const Center(child: CircularProgressIndicator()),
            CardsLoaded(:final cards, :final transactionsByCard) =>
              _CardsContent(cards: cards, transactionsByCard: transactionsByCard),
            CardError(:final message) => _ErrorView(message: message),
          };
        },
      ),
    );
  }
}

class _InitialView extends StatelessWidget {
  const _InitialView();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CardBloc>().add(const LoadCards());
    });
    return const Center(child: CircularProgressIndicator());
  }
}

class _CardsContent extends StatefulWidget {
  final List<CreditCard> cards;
  final Map<String, List<CardTransaction>> transactionsByCard;

  const _CardsContent({
    required this.cards,
    required this.transactionsByCard,
  });

  @override
  State<_CardsContent> createState() => _CardsContentState();
}

class _CardsContentState extends State<_CardsContent> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    _loadTransactionsForIndex(0);
  }

  void _loadTransactionsForIndex(int index) {
    if (widget.cards.isEmpty) return;
    final cardId = widget.cards[index].id;
    context.read<CardBloc>().add(LoadCardTransactions(cardId: cardId));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (widget.cards.isEmpty) {
      return Center(
        child: Text(
          'No credit cards linked.',
          style: textTheme.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
        ),
      );
    }

    final currentCard = widget.cards[_currentIndex];
    final transactions = widget.transactionsByCard[currentCard.id] ?? const [];

    return Column(
      children: [
        const SizedBox(height: 16),
        // --- Card Carousel ---
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
              _loadTransactionsForIndex(index);
            },
            itemCount: widget.cards.length,
            itemBuilder: (context, index) {
              final card = widget.cards[index];
              return _CreditCardWidget(card: card);
            },
          ),
        ),
        const SizedBox(height: 24),
        // --- Card Details and Transactions ---
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              Text(
                'Card Details',
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _DetailRow(label: 'Limit', value: CurrencyFormatter.format(currentCard.creditLimit, 'USD')),
              _DetailRow(label: 'Used Balance', value: CurrencyFormatter.format(currentCard.currentBalance, 'USD')),
              _DetailRow(label: 'Available Credit', value: CurrencyFormatter.format(currentCard.availableCredit, 'USD')),
              const Divider(height: 32),
              Text(
                'Recent Card Transactions',
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (transactions.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'No transactions for this card',
                      style: textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
                    ),
                  ),
                )
              else
                ...transactions.map((tx) => _CardTransactionTile(transaction: tx)),
            ],
          ),
        ),
      ],
    );
  }
}

class _CreditCardWidget extends StatelessWidget {
  final CreditCard card;

  const _CreditCardWidget({required this.card});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.onSurfaceVariant, colors.inverseSurface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                card.brand.toUpperCase(),
                style: textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              Text(
                card.status.name.toUpperCase(),
                style: textTheme.labelSmall?.copyWith(
                  color: card.status == CardStatus.active ? Colors.greenAccent : Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Text(
            card.maskedNumber,
            style: textTheme.titleLarge?.copyWith(
              color: Colors.white,
              letterSpacing: 3,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'HOLDER NAME',
                    style: textTheme.labelSmall?.copyWith(color: Colors.white70),
                  ),
                  Text(
                    card.holderName.toUpperCase(),
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'EXPIRY',
                    style: textTheme.labelSmall?.copyWith(color: Colors.white70),
                  ),
                  Text(
                    '${card.expiryDate.month.toString().padLeft(2, '0')}/${card.expiryDate.year.toString().substring(2)}',
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant)),
          Text(value, style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _CardTransactionTile extends StatelessWidget {
  final CardTransaction transaction;

  const _CardTransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colors.surfaceContainerHighest,
          child: Icon(_getCategoryIcon(transaction.category), color: colors.primary),
        ),
        title: Text(
          transaction.merchant,
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          '${transaction.timestamp.day}/${transaction.timestamp.month}/${transaction.timestamp.year}',
          style: textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
        ),
        trailing: Text(
          '-${CurrencyFormatter.format(transaction.amount, 'USD')}',
          style: textTheme.bodyMedium?.copyWith(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(CardTransactionCategory category) {
    return switch (category) {
      CardTransactionCategory.food => Icons.restaurant,
      CardTransactionCategory.transport => Icons.directions_car,
      CardTransactionCategory.shopping => Icons.shopping_bag,
      CardTransactionCategory.entertainment => Icons.movie,
      CardTransactionCategory.utilities => Icons.electrical_services,
      CardTransactionCategory.health => Icons.medical_services,
      CardTransactionCategory.education => Icons.school,
      CardTransactionCategory.travel => Icons.flight,
      CardTransactionCategory.other => Icons.payment,
    };
  }
}

class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<CardBloc>().add(const LoadCards()),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
