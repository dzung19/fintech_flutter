// =============================================================================
// File: lib/core/security/secure_storage_service.dart
// Purpose: Wrapper around flutter_secure_storage for all sensitive data.
//
// Architecture Notes:
// - SECURITY: Uses flutter_secure_storage with Android EncryptedSharedPreferences
//   enabled. NEVER use SharedPreferences for tokens, PINs, or keys.
// - This service is registered as a LazySingleton in the DI container.
// - All methods use explicit return types and null safety.
// - Exceptions are caught and re-thrown as SecureStorageException for
//   consistent error handling in repositories.
//
// Storage Keys are centralized as private constants to prevent typos
// and ensure single-source-of-truth for key names.
// =============================================================================

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../errors/exceptions.dart';

/// Centralized service for reading/writing sensitive data to encrypted storage.
///
/// All tokens, PINs, biometric keys, and financial credentials MUST go
/// through this service — never through SharedPreferences or plain files.
///
/// Usage:
/// ```dart
/// final storage = getIt<SecureStorageService>();
/// await storage.saveAccessToken('eyJhbGci...');
/// final token = await storage.getAccessToken();
/// ```
class SecureStorageService {
  // ---------------------------------------------------------------------------
  // Storage Keys — private constants to avoid magic strings.
  // ---------------------------------------------------------------------------
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _pinKey = 'user_pin';
  static const String _biometricKeyAlias = 'biometric_key';
  static const String _encryptionKeyAlias = 'app_encryption_key';

  /// The underlying secure storage instance, configured with platform-specific
  /// security options.
  final FlutterSecureStorage _storage;

  /// Creates the service with a pre-configured [FlutterSecureStorage] instance.
  ///
  /// The [storage] parameter enables constructor injection for testability —
  /// unit tests can provide a mock without touching the real keystore.
  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              // SECURITY: Android options enforce EncryptedSharedPreferences,
              // which uses AES-256-SIV for key encryption and AES-256-GCM for
              // value encryption under the hood (AndroidX Security Crypto).
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
              // SECURITY: iOS options set accessibility to first unlock only,
              // preventing access while the device is locked.
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
            );

  // ===========================================================================
  // Access Token
  // ===========================================================================

  /// Persists the OAuth2 access token to encrypted storage.
  ///
  /// Throws [SecureStorageException] if the write operation fails.
  Future<void> saveAccessToken(String token) async {
    await _write(key: _accessTokenKey, value: token);
  }

  /// Retrieves the stored access token, or `null` if none exists.
  ///
  /// Throws [SecureStorageException] on read failure.
  Future<String?> getAccessToken() async {
    return _read(key: _accessTokenKey);
  }

  /// Returns `true` if an access token is currently stored.
  Future<bool> hasAccessToken() async {
    final String? token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // ===========================================================================
  // Refresh Token
  // ===========================================================================

  /// Persists the OAuth2 refresh token to encrypted storage.
  ///
  /// Throws [SecureStorageException] if the write operation fails.
  Future<void> saveRefreshToken(String token) async {
    await _write(key: _refreshTokenKey, value: token);
  }

  /// Retrieves the stored refresh token, or `null` if none exists.
  ///
  /// Throws [SecureStorageException] on read failure.
  Future<String?> getRefreshToken() async {
    return _read(key: _refreshTokenKey);
  }

  // ===========================================================================
  // User PIN
  // ===========================================================================

  /// Saves the user's transaction PIN in encrypted form.
  ///
  /// Throws [SecureStorageException] if the write operation fails.
  ///
  /// SECURITY NOTE: The PIN should already be hashed by the caller before
  /// storage. This service provides encryption-at-rest, but defense-in-depth
  /// demands we don't store raw PINs even in encrypted containers.
  /// TODO(security): Enforce that only hashed PINs are stored here.
  Future<void> savePin(String hashedPin) async {
    await _write(key: _pinKey, value: hashedPin);
  }

  /// Retrieves the stored (hashed) PIN, or `null` if none is set.
  ///
  /// Throws [SecureStorageException] on read failure.
  Future<String?> getPin() async {
    return _read(key: _pinKey);
  }

  /// Returns `true` if a PIN has been configured.
  Future<bool> hasPin() async {
    final String? pin = await getPin();
    return pin != null && pin.isNotEmpty;
  }

  // ===========================================================================
  // Biometric / Encryption Keys
  // ===========================================================================

  /// Stores a biometric authentication key alias.
  ///
  /// Throws [SecureStorageException] if the write operation fails.
  Future<void> saveBiometricKey(String key) async {
    await _write(key: _biometricKeyAlias, value: key);
  }

  /// Retrieves the biometric authentication key alias.
  ///
  /// Throws [SecureStorageException] on read failure.
  Future<String?> getBiometricKey() async {
    return _read(key: _biometricKeyAlias);
  }

  /// Stores the app-level encryption key used for local data encryption.
  ///
  /// Throws [SecureStorageException] if the write operation fails.
  Future<void> saveEncryptionKey(String key) async {
    await _write(key: _encryptionKeyAlias, value: key);
  }

  /// Retrieves the app-level encryption key.
  ///
  /// Throws [SecureStorageException] on read failure.
  Future<String?> getEncryptionKey() async {
    return _read(key: _encryptionKeyAlias);
  }

  // ===========================================================================
  // Session Management
  // ===========================================================================

  /// Wipes ALL sensitive data from secure storage.
  ///
  /// Call this on user logout or account deletion to ensure no residual
  /// credentials remain on-device.
  ///
  /// SECURITY: Clears the entire keystore namespace for this app.
  /// This is intentionally aggressive — partial clears risk leaving
  /// orphaned tokens.
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } on Exception catch (e) {
      throw SecureStorageException(
        message: 'Failed to clear secure storage: $e',
      );
    }
  }

  /// Deletes only the authentication tokens (access + refresh).
  ///
  /// Use this for token rotation or soft-logout scenarios where the
  /// user's PIN and biometric setup should be preserved.
  Future<void> clearTokens() async {
    await _delete(key: _accessTokenKey);
    await _delete(key: _refreshTokenKey);
  }

  // ===========================================================================
  // Private Helpers — DRY wrappers with consistent error handling.
  // ===========================================================================

  /// Writes a value to secure storage, wrapping platform exceptions.
  Future<void> _write({required String key, required String value}) async {
    try {
      await _storage.write(key: key, value: value);
    } on Exception catch (e) {
      throw SecureStorageException(
        message: 'Failed to write key "$key" to secure storage: $e',
      );
    }
  }

  /// Reads a value from secure storage, wrapping platform exceptions.
  Future<String?> _read({required String key}) async {
    try {
      return await _storage.read(key: key);
    } on Exception catch (e) {
      throw SecureStorageException(
        message: 'Failed to read key "$key" from secure storage: $e',
      );
    }
  }

  /// Deletes a single key from secure storage, wrapping platform exceptions.
  Future<void> _delete({required String key}) async {
    try {
      await _storage.delete(key: key);
    } on Exception catch (e) {
      throw SecureStorageException(
        message: 'Failed to delete key "$key" from secure storage: $e',
      );
    }
  }
}
