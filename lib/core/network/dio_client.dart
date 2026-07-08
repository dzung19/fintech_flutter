// =============================================================================
// File: lib/core/network/dio_client.dart
// Purpose: Centralized HTTP client built on Dio with authentication
//          interceptors, timeouts, and structured error handling.
//
// Architecture Notes:
// - This client is registered as a LazySingleton in the DI container.
// - An AuthInterceptor automatically injects the Bearer token from
//   SecureStorageService into every outgoing request.
// - A 401 response triggers token clearing and emits an AuthenticationException
//   for the repository layer to convert into an AuthenticationFailure.
// - All API communication MUST use HTTPS (enforced by base URL config).
// - The Domain layer never imports this file; only the Data layer does.
//
// SECURITY:
// - Tokens are read from flutter_secure_storage, never from SharedPreferences.
// - No credentials are logged, even on error.
// - Connection timeouts prevent resource exhaustion attacks.
// =============================================================================

import 'package:dio/dio.dart';

import '../errors/exceptions.dart';
import '../security/secure_storage_service.dart';
import 'mock_interceptor.dart';

/// Configuration constants for the Dio HTTP client.
///
/// In production, [baseUrl] should be loaded from environment configuration
/// (e.g., --dart-define) rather than hardcoded.
/// TODO(security): Load base URL from environment config or a secure
/// build-time constant rather than hardcoding.
abstract final class ApiConfig {
  /// Base URL for the FinTech API. Must use HTTPS.
  static const String baseUrl = 'https://api.fintech-app.example.com/v1';

  /// Maximum time to wait for a TCP connection to be established.
  static const Duration connectTimeout = Duration(seconds: 15);

  /// Maximum time to wait for the server's response after connection.
  static const Duration receiveTimeout = Duration(seconds: 15);

  /// Maximum time to wait for sending the request body.
  static const Duration sendTimeout = Duration(seconds: 15);

  /// Toggle this to mock all remote network requests client-side.
  static const bool useMockApi = true;
}

/// Centralized HTTP client wrapping [Dio] with authentication, error
/// handling, and consistent timeout configuration.
///
/// Usage (always obtained from DI, never instantiated directly):
/// ```dart
/// final client = getIt<DioClient>();
/// final response = await client.get('/accounts/balance');
/// ```
class DioClient {
  /// The underlying Dio instance, fully configured with interceptors.
  final Dio _dio;

  /// Creates a [DioClient] with the provided [Dio] instance.
  ///
  /// The [dio] parameter allows constructor injection for unit testing.
  /// In production, use the factory constructor [DioClient.withInterceptors]
  /// which wires up the [AuthInterceptor] automatically.
  DioClient({required this._dio});

  /// Factory constructor that creates a fully configured [DioClient] with:
  /// - Base URL and timeout settings from [ApiConfig].
  /// - An [AuthInterceptor] for automatic Bearer token injection.
  /// - A [LogInterceptor] for development debugging (disabled in production).
  ///
  /// [secureStorageService] is required to provide the auth token.
  factory DioClient.withInterceptors({
    required SecureStorageService secureStorageService,
  }) {
    final Dio dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        sendTimeout: ApiConfig.sendTimeout,
        // SECURITY: Always expect JSON responses; reject unexpected MIME types.
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
        // SECURITY: Do not follow redirects automatically to prevent
        // open-redirect attacks in API responses.
        followRedirects: false,
        // Validate status codes — let the interceptor handle 401.
        validateStatus: (int? status) =>
            status != null && status >= 200 && status < 300,
      ),
    );

    // Wire up interceptors in execution order.
    if (ApiConfig.useMockApi) {
      dio.interceptors.add(MockInterceptor());
    } else {
      dio.interceptors.addAll([
        AuthInterceptor(secureStorageService: secureStorageService),
        // NOTE: LogInterceptor is for development only.
        // SECURITY: Disable request/response body logging in production
        // to prevent token/PII leakage in logs.
        // TODO(security): Gate this behind a build flavor or environment flag.
        LogInterceptor(
          request: true,
          requestHeader: false, // Don't log auth headers.
          requestBody: false, // Don't log request bodies (may contain PII).
          responseHeader: false,
          responseBody: false, // Don't log response bodies (may contain PII).
          error: true,
          logPrint: (Object object) {
            // SECURITY: In production, route to a structured logger
            // that strips sensitive fields.
            // ignore: avoid_print
            print('[DioClient] $object');
          },
        ),
      ]);
    }

    return DioClient(dio: dio);
  }

  // ===========================================================================
  // HTTP Methods — thin wrappers with consistent error conversion.
  // ===========================================================================

  /// Performs an HTTP GET request to the specified [path].
  ///
  /// Throws [ServerException] on non-2xx responses or network errors.
  /// Throws [AuthenticationException] if the token is rejected (401).
  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _performRequest(
      () => _dio.get(path, queryParameters: queryParameters, options: options),
    );
  }

  /// Performs an HTTP POST request to the specified [path].
  ///
  /// Throws [ServerException] on non-2xx responses or network errors.
  /// Throws [AuthenticationException] if the token is rejected (401).
  Future<Response<dynamic>> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _performRequest(
      () => _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
    );
  }

  /// Performs an HTTP PUT request to the specified [path].
  ///
  /// Throws [ServerException] on non-2xx responses or network errors.
  /// Throws [AuthenticationException] if the token is rejected (401).
  Future<Response<dynamic>> put(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _performRequest(
      () => _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
    );
  }

  /// Performs an HTTP PATCH request to the specified [path].
  ///
  /// Throws [ServerException] on non-2xx responses or network errors.
  /// Throws [AuthenticationException] if the token is rejected (401).
  Future<Response<dynamic>> patch(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _performRequest(
      () => _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
    );
  }

  /// Performs an HTTP DELETE request to the specified [path].
  ///
  /// Throws [ServerException] on non-2xx responses or network errors.
  /// Throws [AuthenticationException] if the token is rejected (401).
  Future<Response<dynamic>> delete(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _performRequest(
      () => _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
    );
  }

  // ===========================================================================
  // Private — Centralized error conversion.
  // ===========================================================================

  /// Executes the given [request] and converts Dio errors into domain
  /// exceptions ([ServerException], [AuthenticationException]).
  ///
  /// This ensures every HTTP method goes through the same error-handling
  /// pipeline, keeping the public API clean and consistent.
  Future<Response<dynamic>> _performRequest(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// Maps a [DioException] to the appropriate domain exception.
  ///
  /// - 401 → [AuthenticationException] (token expired/invalid).
  /// - Other status codes → [ServerException] with details.
  /// - Timeout/connection → [ServerException] with descriptive message.
  Exception _mapDioException(DioException exception) {
    final int? statusCode = exception.response?.statusCode;

    // SECURITY: 401 Unauthorized — the token is expired or invalid.
    if (statusCode == 401) {
      return const AuthenticationException(
        message: 'Session expired. Please log in again.',
      );
    }

    // SECURITY: 403 Forbidden — the user lacks permissions.
    if (statusCode == 403) {
      return const ServerException(
        message: 'Access denied. Insufficient permissions.',
        statusCode: 403,
      );
    }

    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
        return const ServerException(
          message: 'Connection timed out. Please check your network.',
        );
      case DioExceptionType.sendTimeout:
        return const ServerException(
          message: 'Request timed out while sending data.',
        );
      case DioExceptionType.receiveTimeout:
        return const ServerException(
          message: 'Server took too long to respond.',
        );
      case DioExceptionType.connectionError:
        return const ServerException(
          message: 'Could not connect to the server. Please try again.',
        );
      case DioExceptionType.badResponse:
        // SECURITY: Extract a safe error message. Never expose raw
        // server error bodies to the user — they may contain internal details.
        final String serverMessage = _extractSafeErrorMessage(
          exception.response?.data,
        );
        return ServerException(message: serverMessage, statusCode: statusCode);
      case DioExceptionType.cancel:
        return const ServerException(message: 'Request was cancelled.');
      case DioExceptionType.badCertificate:
        // SECURITY: Certificate validation failure — potential MITM.
        return const ServerException(
          message: 'SSL certificate validation failed. Connection refused.',
        );
      case DioExceptionType.unknown:
        return ServerException(
          message: exception.message ?? 'An unexpected network error occurred.',
        );
      case DioExceptionType.transformTimeout:
        return const ServerException(
          message: 'Request transformation timed out. Please try again.',
        );
    }
  }

  /// Extracts a user-safe error message from a server response body.
  ///
  /// SECURITY: Only reads a known 'message' field from the JSON response.
  /// Falls back to a generic message to prevent leaking server internals.
  String _extractSafeErrorMessage(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      final dynamic message = responseData['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }
    return 'An unexpected server error occurred.';
  }
}

// =============================================================================
// AuthInterceptor — Injects Bearer tokens and handles 401 globally.
// =============================================================================

/// Dio [Interceptor] that automatically attaches the stored Bearer token
/// to every outgoing request and handles 401 responses centrally.
///
/// Architecture:
/// - Reads the access token from [SecureStorageService] on each request.
/// - If no token is found, the request proceeds without auth headers
///   (for public endpoints like login/register).
/// - On 401 response, clears stored tokens and rejects the request so
///   the repository layer can trigger a re-authentication flow.
class AuthInterceptor extends Interceptor {
  final SecureStorageService _secureStorageService;

  AuthInterceptor({required this._secureStorageService});

  /// Called before every request — injects the Bearer token if available.
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final String? accessToken = await _secureStorageService.getAccessToken();

      if (accessToken != null && accessToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
    } on Exception {
      // SECURITY: If token retrieval fails, proceed without auth.
      // The server will return 401 if auth is required, which is handled
      // in onError below.
    }

    handler.next(options);
  }

  /// Called on error responses — handles 401 by clearing tokens.
  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      // SECURITY: Clear stale tokens immediately on 401 to prevent
      // retry loops with an invalid token.
      try {
        await _secureStorageService.clearTokens();
      } on Exception {
        // Best-effort token clearing — don't block the error flow.
      }

      // Reject with a clear authentication error. The repository converts
      // this into an AuthenticationFailure for the BLoC.
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          response: err.response,
          type: err.type,
          message: 'Authentication expired. Tokens cleared.',
        ),
      );
      return;
    }

    // For non-401 errors, pass through to the default error handling.
    handler.next(err);
  }
}
