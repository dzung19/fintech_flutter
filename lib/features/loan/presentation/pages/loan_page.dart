// =============================================================================
// File: lib/features/loan/presentation/pages/loan_page.dart
// Purpose: Loan summary and amortization calculator UI screen.
//
// Architecture Notes:
// - Strictly UI widgets that dispatch to LoanBloc.
// - Performs input parsing to Decimal before dispatching event.
// =============================================================================

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/amortization_entry.dart';
import '../../domain/entities/loan.dart';
import '../bloc/loan_bloc.dart';

class LoanPage extends StatefulWidget {
  const LoanPage({super.key});

  @override
  State<LoanPage> createState() => _LoanPageState();
}

class _LoanPageState extends State<LoanPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  final _principalController = TextEditingController();
  final _rateController = TextEditingController();
  final _termController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _principalController.dispose();
    _rateController.dispose();
    _termController.dispose();
    super.dispose();
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    final principal =
        Decimal.tryParse(_principalController.text) ?? Decimal.zero;
    final rate = Decimal.tryParse(_rateController.text) ?? Decimal.zero;
    final term = int.tryParse(_termController.text) ?? 0;

    context.read<LoanBloc>().add(
      RunAmortizationCalculation(
        principal: principal,
        annualRate: rate,
        termMonths: term,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loans & Amortization'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active Loans'),
            Tab(text: 'Calculator'),
          ],
        ),
      ),
      body: BlocConsumer<LoanBloc, LoanState>(
        listener: (context, state) {
          if (state is LoanError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildActiveLoansTab(context, state),
              _buildCalculatorTab(context, state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActiveLoansTab(BuildContext context, LoanState state) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return switch (state) {
      LoanInitial() => const _InitialView(),
      LoanLoading() => const Center(child: CircularProgressIndicator()),
      LoanError(:final message) => _ErrorView(message: message),
      LoansLoaded(:final loans) =>
        loans.isEmpty
            ? Center(
                child: Text(
                  'No active loans found.',
                  style: textTheme.bodyLarge?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: loans.length,
                itemBuilder: (context, index) {
                  final loan = loans[index];
                  return _LoanCard(loan: loan);
                },
              ),
    };
  }

  Widget _buildCalculatorTab(BuildContext context, LoanState state) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    List<AmortizationEntry> schedule = const [];
    if (state is LoansLoaded) {
      schedule = state.calculatedSchedule;
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _principalController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Principal Amount (USD)',
                hintText: 'e.g. 10000',
              ),
              validator: (val) {
                if (val == null || val.isEmpty) return 'Please enter principal';
                if (Decimal.tryParse(val) == null) return 'Invalid number';
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _rateController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Annual Interest Rate (%)',
                      hintText: 'e.g. 5.5',
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Enter rate';
                      if (Decimal.tryParse(val) == null) return 'Invalid';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _termController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Term (Months)',
                      hintText: 'e.g. 24',
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Enter term';
                      if (int.tryParse(val) == null) return 'Invalid';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _calculate,
                child: const Text('Calculate Schedule'),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: schedule.isEmpty
                  ? Center(
                      child: Text(
                        'Calculate a schedule to see monthly breakdown.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Amortization Schedule',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columns: const [
                                  DataColumn(label: Text('Month')),
                                  DataColumn(label: Text('Payment')),
                                  DataColumn(label: Text('Principal')),
                                  DataColumn(label: Text('Interest')),
                                  DataColumn(label: Text('Remaining')),
                                ],
                                rows: schedule.map((entry) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(entry.month.toString())),
                                      DataCell(
                                        Text(
                                          CurrencyFormatter.format(
                                            entry.payment,
                                            'USD',
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          CurrencyFormatter.format(
                                            entry.principal,
                                            'USD',
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          CurrencyFormatter.format(
                                            entry.interest,
                                            'USD',
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          CurrencyFormatter.format(
                                            entry.remainingBalance,
                                            'USD',
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InitialView extends StatelessWidget {
  const _InitialView();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LoanBloc>().add(const LoadLoans());
    });
    return const Center(child: CircularProgressIndicator());
  }
}

class _LoanCard extends StatelessWidget {
  final Loan loan;

  const _LoanCard({required this.loan});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Loan ID: ${loan.id.substring(0, 8)}',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: loan.status == LoanStatus.active
                        ? Colors.green.withAlpha(30)
                        : colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    loan.status.name.toUpperCase(),
                    style: textTheme.labelSmall?.copyWith(
                      color: loan.status == LoanStatus.active
                          ? Colors.green
                          : colors.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatsItem(
                  context,
                  'Principal',
                  CurrencyFormatter.format(loan.principalAmount, 'USD'),
                ),
                _buildStatsItem(
                  context,
                  'Rate',
                  CurrencyFormatter.formatPercentage(loan.annualInterestRate),
                ),
                _buildStatsItem(context, 'Term', '${loan.termMonths} mos'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatsItem(
                  context,
                  'Monthly Payment',
                  CurrencyFormatter.format(loan.monthlyPayment, 'USD'),
                ),
                _buildStatsItem(
                  context,
                  'Start Date',
                  '${loan.startDate.day}/${loan.startDate.month}/${loan.startDate.year}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsItem(BuildContext context, String label, String value) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
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
          Icon(
            Icons.error_outline,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<LoanBloc>().add(const LoadLoans()),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
