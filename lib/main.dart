// =============================================================================
// File: lib/main.dart
// Purpose: Application entry point — initializes DI, theming, and multi-feature
//          navigation dashboard.
//
// Architecture Notes:
// - Initializes DI via configureDependencies() before runApp().
// - Uses MultiBlocProvider to supply feature BLoCs globally or at shell level.
// - Sets up Material 3 dark/light themes defined in AppTheme.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'features/card/presentation/bloc/card_bloc.dart';
import 'features/card/presentation/pages/card_page.dart';
import 'features/loan/presentation/bloc/loan_bloc.dart';
import 'features/loan/presentation/pages/loan_page.dart';
import 'features/wallet/presentation/bloc/wallet_bloc.dart';
import 'features/wallet/presentation/pages/wallet_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const FinTechApp());
}

class FinTechApp extends StatelessWidget {
  const FinTechApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<WalletBloc>(
          create: (_) => getIt<WalletBloc>(),
        ),
        BlocProvider<CardBloc>(
          create: (_) => getIt<CardBloc>(),
        ),
        BlocProvider<LoanBloc>(
          create: (_) => getIt<LoanBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'FinTech App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        home: const MainDashboard(),
      ),
    );
  }
}

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    WalletPage(),
    CardPage(),
    LoanPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card_outlined),
            activeIcon: Icon(Icons.credit_card),
            label: 'Cards',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.summarize_outlined),
            activeIcon: Icon(Icons.summarize),
            label: 'Loans',
          ),
        ],
      ),
    );
  }
}
