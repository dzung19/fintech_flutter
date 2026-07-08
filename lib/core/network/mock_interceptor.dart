// =============================================================================
// File: lib/core/network/mock_interceptor.dart
// Purpose: Intercepts network requests and returns mock JSON data locally.
// =============================================================================

import 'package:dio/dio.dart';

/// Dio [Interceptor] that mocks server responses for local-only testing
/// when no real backend service is running.
class MockInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Simulate a small network latency (300ms) for realistic loading states
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final path = options.path;
    final method = options.method.toUpperCase();

    // 1. Wallets
    if (path == '/wallets') {
      handler.resolve(
        Response<dynamic>(
          requestOptions: options,
          statusCode: 200,
          data: {
            'id': 'wallet_123',
            'user_id': 'user_abc',
            'balance': '5820.50',
            'currency': 'USD',
            'name': 'Main Checking Wallet',
            'created_at': '2026-01-01T12:00:00Z',
            'is_active': true,
          },
        ),
      );
      return;
    }

    // 2. Wallet Transactions
    if (path.startsWith('/wallets/') && path.endsWith('/transactions')) {
      final walletId = path.split('/')[2];
      handler.resolve(
        Response<dynamic>(
          requestOptions: options,
          statusCode: 200,
          data: [
            {
              'id': 'tx_1',
              'wallet_id': walletId,
              'amount': '1200.00',
              'type': 'deposit',
              'status': 'success',
              'description': 'Monthly Paycheck',
              'balance_after': '5820.50',
              'timestamp': '2026-07-08T10:00:00Z',
              'reference_id': 'ref_pay_099',
            },
            {
              'id': 'tx_2',
              'wallet_id': walletId,
              'amount': '45.00',
              'type': 'withdrawal',
              'status': 'success',
              'description': 'ATM Cash Out',
              'balance_after': '4620.50',
              'timestamp': '2026-07-07T15:30:00Z',
              'reference_id': null,
            },
            {
              'id': 'tx_3',
              'wallet_id': walletId,
              'amount': '15.50',
              'type': 'payment',
              'status': 'success',
              'description': 'Organic Grocery Store',
              'balance_after': '4665.50',
              'timestamp': '2026-07-06T08:15:00Z',
              'reference_id': 'ref_pos_112',
            },
          ],
        ),
      );
      return;
    }

    // 3. Wallet Transfer Funds
    if (path == '/wallets/transfer' && method == 'POST') {
      final data = options.data as Map<String, dynamic>;
      final recipientId = data['recipient_wallet_id'] as String;
      final amount = data['amount'] as String;
      final description = data['description'] as String;

      handler.resolve(
        Response<dynamic>(
          requestOptions: options,
          statusCode: 200,
          data: {
            'id': 'tx_transfer_new_${DateTime.now().millisecondsSinceEpoch}',
            'wallet_id': 'wallet_123',
            'amount': amount,
            'type': 'transfer',
            'status': 'success',
            'description': description.isNotEmpty
                ? description
                : 'Transfer to $recipientId',
            'balance_after': '5770.50',
            'timestamp': DateTime.now().toIso8601String(),
            'reference_id': 'ref_trsf_991',
          },
        ),
      );
      return;
    }

    // 4. Cards
    if (path == '/cards') {
      handler.resolve(
        Response<dynamic>(
          requestOptions: options,
          statusCode: 200,
          data: [
            {
              'id': 'card_1',
              'masked_number': '•••• •••• •••• 4111',
              'holder_name': 'JOHN DOE',
              'expiry_date': '2029-12-31T23:59:59Z',
              'credit_limit': '5000.00',
              'current_balance': '1250.75',
              'brand': 'Visa',
              'status': 'active',
            },
            {
              'id': 'card_2',
              'masked_number': '•••• •••• •••• 5222',
              'holder_name': 'JOHN DOE',
              'expiry_date': '2030-06-30T23:59:59Z',
              'credit_limit': '8000.00',
              'current_balance': '0.00',
              'brand': 'Mastercard',
              'status': 'active',
            },
          ],
        ),
      );
      return;
    }

    // 5. Card Transactions
    if (path.startsWith('/cards/') && path.endsWith('/transactions')) {
      final cardId = path.split('/')[2];
      handler.resolve(
        Response<dynamic>(
          requestOptions: options,
          statusCode: 200,
          data: [
            {
              'id': 'ctx_1',
              'card_id': cardId,
              'amount': '45.99',
              'merchant': 'Amazon Shopping',
              'category': 'shopping',
              'timestamp': '2026-07-07T12:00:00Z',
              'is_pending': false,
            },
            {
              'id': 'ctx_2',
              'card_id': cardId,
              'amount': '12.50',
              'merchant': 'Local Burger Joint',
              'category': 'food',
              'timestamp': '2026-07-06T18:30:00Z',
              'is_pending': false,
            },
            {
              'id': 'ctx_3',
              'card_id': cardId,
              'amount': '85.00',
              'merchant': 'Highway Gas Station',
              'category': 'transport',
              'timestamp': '2026-07-05T09:45:00Z',
              'is_pending': true,
            },
          ],
        ),
      );
      return;
    }

    // 6. Block Card
    if (path.startsWith('/cards/') &&
        path.endsWith('/block') &&
        method == 'POST') {
      final cardId = path.split('/')[2];
      handler.resolve(
        Response<dynamic>(
          requestOptions: options,
          statusCode: 200,
          data: {
            'id': cardId,
            'masked_number': cardId == 'card_2'
                ? '•••• •••• •••• 5222'
                : '•••• •••• •••• 4111',
            'holder_name': 'JOHN DOE',
            'expiry_date': cardId == 'card_2'
                ? '2030-06-30T23:59:59Z'
                : '2029-12-31T23:59:59Z',
            'credit_limit': cardId == 'card_2' ? '8000.00' : '5000.00',
            'current_balance': cardId == 'card_2' ? '0.00' : '1250.75',
            'brand': cardId == 'card_2' ? 'Mastercard' : 'Visa',
            'status': 'blocked',
          },
        ),
      );
      return;
    }

    // 7. Loans
    if (path == '/loans') {
      handler.resolve(
        Response<dynamic>(
          requestOptions: options,
          statusCode: 200,
          data: [
            {
              'id': 'loan_1',
              'principal_amount': '25000.00',
              'annual_interest_rate': '0.055',
              'term_months': 36,
              'monthly_payment': '754.85',
              'start_date': '2025-01-01T12:00:00Z',
              'status': 'active',
            },
            {
              'id': 'loan_2',
              'principal_amount': '10000.00',
              'annual_interest_rate': '0.062',
              'term_months': 24,
              'monthly_payment': '444.13',
              'start_date': '2026-06-01T12:00:00Z',
              'status': 'pending_approval',
            },
          ],
        ),
      );
      return;
    }

    // Fallback — call super
    super.onRequest(options, handler);
  }
}
