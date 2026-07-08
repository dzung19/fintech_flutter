// =============================================================================
// File: lib/features/wallet/presentation/pages/wallet_page.dart
// Purpose: Main wallet screen — displays balance and transaction history.
//
// Architecture Notes:
// - NO business logic in this widget. It only:
//   1. Dispatches events to WalletBloc.
//   2. Listens to WalletState via BlocBuilder/BlocListener.
//   3. Renders UI based on state.
// - Formatting (currency display) is delegated to CurrencyFormatter utility.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/wallet.dart';
import '../bloc/wallet_bloc.dart';

/// Wallet page displaying balance card and transaction history.
///
/// This widget is provided a [WalletBloc] via `BlocProvider` from the
/// parent route/navigation setup.
class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Wallet')),
      body: BlocConsumer<WalletBloc, WalletState>(
        listener: (BuildContext context, WalletState state) {
          if (state is WalletTransferSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Transfer successful: ${CurrencyFormatter.format(
                    state.transaction.amount,
                    'USD',
                  )}',
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            );
          }
          if (state is WalletError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        builder: (BuildContext context, WalletState state) {
          return switch (state) {
            WalletInitial() => const _InitialView(),
            WalletLoading() || WalletTransferring() => const Center(
                child: CircularProgressIndicator(),
              ),
            WalletLoaded(:final wallet, :final transactions) =>
              _WalletContent(wallet: wallet, transactions: transactions),
            WalletTransferSuccess() => const _InitialView(),
            WalletError(:final message) => _ErrorView(message: message),
          };
        },
      ),
    );
  }
}

/// Shown on first load — prompts the BLoC to fetch wallet data.
class _InitialView extends StatelessWidget {
  const _InitialView();

  @override
  Widget build(BuildContext context) {
    // Auto-trigger wallet load on first build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletBloc>().add(const LoadWallet());
    });
    return const Center(child: CircularProgressIndicator());
  }
}

/// Main content: balance card + transaction list.
class _WalletContent extends StatelessWidget {
  final Wallet wallet;
  final List<WalletTransaction> transactions;

  const _WalletContent({
    required this.wallet,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<WalletBloc>().add(const LoadWallet());
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- Balance Card ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colors.primary, colors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withAlpha(77),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  wallet.name,
                  style: textTheme.titleMedium?.copyWith(
                    color: colors.onPrimary.withAlpha(204),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  CurrencyFormatter.format(wallet.balance, wallet.currency),
                  style: textTheme.headlineLarge?.copyWith(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.onPrimary.withAlpha(38),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    wallet.isActive ? '● Active' : '○ Inactive',
                    style: TextStyle(
                      color: colors.onPrimary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // --- Transactions Header ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Transactions',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () {
                  context.read<WalletBloc>().add(
                        LoadTransactions(walletId: wallet.id),
                      );
                },
                child: const Text('See All'),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // --- Transaction List ---
          if (transactions.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.receipt_long,
                        size: 48, color: colors.onSurfaceVariant),
                    const SizedBox(height: 12),
                    Text(
                      'No transactions yet',
                      style: textTheme.bodyLarge?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...transactions.map(
              (WalletTransaction tx) => _TransactionTile(transaction: tx),
            ),
        ],
      ),
    );
  }
}

/// Individual transaction list tile.
class _TransactionTile extends StatelessWidget {
  final WalletTransaction transaction;

  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final bool isCredit = transaction.type == TransactionType.credit;
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              isCredit ? Colors.green.withAlpha(31) : Colors.red.withAlpha(31),
          child: Icon(
            isCredit ? Icons.arrow_downward : Icons.arrow_upward,
            color: isCredit ? Colors.green : Colors.red,
            size: 20,
          ),
        ),
        title: Text(
          transaction.description,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          _formatDate(transaction.timestamp),
          style: textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        trailing: Text(
          '${isCredit ? '+' : '-'}${CurrencyFormatter.format(
            transaction.amount,
            'USD',
          )}',
          style: textTheme.bodyMedium?.copyWith(
            color: isCredit ? Colors.green : Colors.red,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Formats a DateTime for display — no business logic, just presentation.
  String _formatDate(DateTime date) {
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

/// Error view with retry button.
class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<WalletBloc>().add(const LoadWallet());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
