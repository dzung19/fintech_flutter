// =============================================================================
// File: lib/core/errors/exceptions.dart
// Purpose: Custom Exception classes for the Data layer.
//
// Architecture Note:
// - Exceptions are ONLY used in the Data layer (data sources, API clients).
// - Repositories MUST catch these and convert them to Failure objects
//   before returning results to the Domain layer.
// - This prevents raw exceptions from leaking to BLoCs or the UI.
// =============================================================================

/// Exception thrown when a server/API call fails.
///
/// Carries the HTTP [statusCode] and a descriptive [message] for
/// debugging and conversion to [ServerFailure].
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({required this.message, this.statusCode});

  @override
  String toString() =>
      'ServerException(status: $statusCode, message: $message)';
}

/// Exception thrown when local cache operations fail.
class CacheException implements Exception {
  final String message;

  const CacheException({required this.message});

  @override
  String toString() => 'CacheException(message: $message)';
}

/// Exception thrown when authentication is invalid or expired.
class AuthenticationException implements Exception {
  final String message;

  const AuthenticationException({this.message = 'Authentication required.'});

  @override
  String toString() => 'AuthenticationException(message: $message)';
}

/// Exception thrown when secure storage operations fail.
class SecureStorageException implements Exception {
  final String message;

  const SecureStorageException({required this.message});

  @override
  String toString() => 'SecureStorageException(message: $message)';
}
