// =============================================================================
// File: lib/core/constants/api_endpoints.dart
// Purpose: Centralized API endpoint path constants.
//
// Architecture Note:
// - All endpoint strings live here — no magic strings scattered across
//   data sources.
// - The base URL is configured in DioClient (ApiConfig.baseUrl).
//   These are relative paths appended to that base.
// - Pure Dart — no Flutter imports.
// =============================================================================

/// Centralized API endpoint paths for all features.
///
/// Usage:
/// ```dart
/// final response = await dioClient.get(ApiEndpoints.walletBalance('wallet-123'));
/// ```
abstract final class ApiEndpoints {
  // ===========================================================================
  // Auth
  // ===========================================================================
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';

  // ===========================================================================
  // Wallet
  // ===========================================================================
  static const String wallets = '/wallets';

  static String walletById(String walletId) => '/wallets/$walletId';

  static String walletTransactions(String walletId) =>
      '/wallets/$walletId/transactions';

  static const String walletTransfer = '/wallets/transfer';

  // ===========================================================================
  // Credit Card
  // ===========================================================================
  static const String cards = '/cards';

  static String cardById(String cardId) => '/cards/$cardId';

  static String cardTransactions(String cardId) =>
      '/cards/$cardId/transactions';

  static String blockCard(String cardId) => '/cards/$cardId/block';

  // ===========================================================================
  // Loan
  // ===========================================================================
  static const String loans = '/loans';

  static String loanById(String loanId) => '/loans/$loanId';

  static String loanSchedule(String loanId) => '/loans/$loanId/schedule';
}
