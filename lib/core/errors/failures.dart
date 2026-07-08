// =============================================================================
// File: lib/core/errors/failures.dart
// Purpose: Defines the Failure hierarchy for functional error handling.
//
// Architecture Note:
// - These classes live in the Domain layer (pure Dart, no Flutter imports).
// - Repositories return Failure objects instead of throwing Exceptions,
//   enabling predictable, type-safe error handling in BLoCs/Cubits.
// - Uses Equatable so BLoC can compare states containing Failures.
// =============================================================================

import 'package:equatable/equatable.dart';

/// Base class for all failures in the application.
///
/// Each failure carries a human-readable [message] for logging/debugging
/// and an optional [statusCode] for network-related failures.
///
/// Design Decision: We use sealed classes to enable exhaustive pattern
/// matching in Dart 3.x, ensuring every failure type is handled.
sealed class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure({required this.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

/// Failure originating from network/API calls (e.g., Dio errors).
final class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.statusCode});
}

/// Failure originating from local cache or database operations.
final class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

/// Failure when the device has no internet connection.
final class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection. Please check your network.',
  });
}

/// Failure for authentication issues (expired token, unauthorized, etc.).
final class AuthenticationFailure extends Failure {
  const AuthenticationFailure({
    super.message = 'Authentication failed. Please log in again.',
    super.statusCode = 401,
  });
}

/// Failure for secure storage read/write operations.
final class SecureStorageFailure extends Failure {
  const SecureStorageFailure({required super.message});
}

/// Failure for invalid input or validation errors.
final class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}
