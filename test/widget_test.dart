// =============================================================================
// File: test/widget_test.dart
// Purpose: Widget rendering smoke tests and utility unit tests.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:decimal/decimal.dart';
import 'package:fintech_app/core/utils/result.dart';
import 'package:fintech_app/core/utils/currency_formatter.dart';
import 'package:fintech_app/core/errors/failures.dart';

void main() {
  group('Widget and UI Smoke Tests', () {
    testWidgets('Basic widget rendering test', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: Text('FinTech App Welcome'))),
        ),
      );

      expect(find.text('FinTech App Welcome'), findsOneWidget);
    });
  });

  group('CurrencyFormatter Unit Tests', () {
    test('Formats USD correctly', () {
      final val = Decimal.parse('1234.56');
      expect(CurrencyFormatter.formatUSD(val), r'$1,234.56');
    });

    test('Formats VND correctly', () {
      final val = Decimal.parse('1500000');
      final result = CurrencyFormatter.formatVND(val);
      expect(result.contains('1'), true);
      expect(result.contains('500'), true);
    });

    test('Masks credit cards correctly', () {
      expect(
        CurrencyFormatter.maskCardNumber('4111111111111111'),
        '•••• •••• •••• 1111',
      );
    });

    test('Masks account numbers correctly', () {
      expect(CurrencyFormatter.maskAccountNumber('1234567890'), '******7890');
    });

    test('Formats percentages correctly', () {
      expect(
        CurrencyFormatter.formatPercentage(Decimal.parse('5.75')),
        '5.75%',
      );
    });
  });

  group('Result Sealed Class Unit Tests', () {
    test('Success returns correct data', () {
      const result = Success('success_data');
      expect(result.data, 'success_data');
      expect(result.props, ['success_data']);
    });

    test('Err returns correct failure', () {
      const failure = ServerFailure(message: 'Server Error');
      const result = Err(failure);
      expect(result.failure, failure);
      expect(result.props, [failure]);
    });
  });
}
