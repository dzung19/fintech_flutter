# FinTech App

A production-grade FinTech mobile application combining **Digital Wallet**, **Credit Card Integration**, and **Loan Amortization** — built with Flutter and Clean Architecture.

---

## Tech Stack

| Category | Technology | Version | Purpose |
|----------|-----------|---------|---------|
| **Framework** | Flutter | SDK ^3.12.2 | Cross-platform mobile UI |
| **Language** | Dart 3.x | — | Null-safe, strongly typed |
| **State Management** | `flutter_bloc` | ^9.1.1 | Bloc for complex flows, Cubit for simple states |
| **Dependency Injection** | `get_it` | ^9.2.1 | Service locator — all services registered as singletons |
| **Networking** | `dio` | ^5.10.0 | HTTP client with interceptors, timeouts, error handling |
| **Secure Storage** | `flutter_secure_storage` | ^10.3.1 | AES-256 encrypted keystore (Android EncryptedSharedPreferences) |
| **Financial Math** | `decimal` | ^3.2.4 | Arbitrary-precision arithmetic — **no `double` for currency** |
| **Equality** | `equatable` | ^2.1.0 | Value equality for BLoC states and domain entities |
| **Formatting** | `intl` | ^0.20.3 | Date/number/currency formatting |

---

## Architecture

### Feature-First + Clean Architecture

```
lib/
├── core/                          # Shared infrastructure
│   ├── constants/                 # App-wide constants, API endpoints
│   ├── di/
│   │   └── injection_container.dart   # GetIt DI setup (single source of truth)
│   ├── errors/
│   │   ├── exceptions.dart            # Data-layer exceptions
│   │   └── failures.dart              # Domain-layer sealed Failure classes
│   ├── network/
│   │   └── dio_client.dart            # Dio + AuthInterceptor
│   ├── security/
│   │   └── secure_storage_service.dart # Encrypted storage wrapper
│   ├── theme/                     # App-wide theming, colors, typography
│   └── utils/                     # Shared utilities, extensions
│
├── features/                      # Independent feature modules
│   ├── wallet/                    # Digital Wallet
│   │   ├── data/                  # Data sources, models, repository impl
│   │   ├── domain/                # Entities, use cases, repository interfaces
│   │   └── presentation/         # BLoCs, Cubits, Widgets, Pages
│   ├── card/                      # Credit Card Integration
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── loan/                      # Loan Amortization
│       ├── data/
│       ├── domain/
│       └── presentation/
│
└── main.dart                      # Entry point — DI bootstrap → runApp()
```

### Layer Rules

| Layer | Allowed Imports | Responsibility |
|-------|----------------|----------------|
| **Domain** | Pure Dart only (no Flutter, Dio, DB packages) | Entities, Use Cases, abstract Repository interfaces |
| **Data** | Domain + external packages (Dio, DB, etc.) | API calls, local storage, Repository implementations |
| **Presentation** | Domain + Flutter + BLoC | Widgets dispatch events → BLoC → listen to states. **No business logic in UI.** |

### Data Flow

```
UI (Widget) → dispatches Event → BLoC → calls Use Case → Repository (interface)
                                                              ↓
                                                    Repository (impl in Data layer)
                                                              ↓
                                                    Remote/Local Data Source
                                                              ↓
                                                    Returns Result<Entity, Failure>
                                                              ↓
BLoC emits new State ← Use Case returns ← Repository returns ←
```

### Error Handling

Functional error handling using sealed `Failure` classes:

```dart
// Domain layer — sealed class enables exhaustive pattern matching
sealed class Failure extends Equatable {
  final String message;
  final int? statusCode;
}

// Concrete failures
final class ServerFailure extends Failure { ... }
final class AuthenticationFailure extends Failure { ... }
final class NetworkFailure extends Failure { ... }
```

- **Data layer** throws `Exception` subclasses (`ServerException`, `CacheException`)
- **Repository** catches exceptions → converts to `Failure` objects
- **BLoC** receives `Failure` → emits error state → UI displays user-friendly message
- **Exceptions never leak to the UI**

### Dependency Injection

All registrations live in `lib/core/di/injection_container.dart`:

```dart
// Core services — LazySingleton (one instance, created on first access)
getIt.registerLazySingleton<SecureStorageService>(() => SecureStorageService());
getIt.registerLazySingleton<DioClient>(() => DioClient.withInterceptors(...));

// Feature BLoCs — Factory (fresh instance per screen)
getIt.registerFactory(() => WalletBloc(getWalletBalance: getIt()));
```

---

## Current Implementation

### ✅ Implementation Status

| Component / Phase | Description / Deliverables | Status |
|-------------------|----------------------------|--------|
| **Core Foundation** | DI setup, secure storage wrapper, network client config | ✅ Completed |
| **Phase 2: Core Infrastructure** | Shared result wrapper, API endpoints, currency helper, themes | ✅ Completed |
| **Phase 3: Wallet Module** | Entities, use cases, remote data source, BLoC, UI balance dashboard | ✅ Completed |
| **Phase 4: Card Integration** | Masked cards, category-mapped transactions, BLoC, carousel card layout | ✅ Completed |
| **Phase 5: Loan Amortization** | Loans list, local Decimal/Rational calculation of schedules, calculator UI | ✅ Completed |


---

## Security Principles

| Principle | Implementation |
|-----------|---------------|
| **No plaintext secrets** | All tokens, PINs, keys stored via `flutter_secure_storage` with `encryptedSharedPreferences: true` |
| **No `SharedPreferences` for credentials** | Enforced by architecture — `SecureStorageService` is the only storage abstraction |
| **Bearer token injection** | `AuthInterceptor` reads token from encrypted storage per-request |
| **401 auto-handling** | Tokens cleared immediately on auth failure; `AuthenticationException` propagated |
| **No PII logging** | `LogInterceptor` has request/response body logging disabled |
| **No `double` for money** | `decimal` package enforced for all currency and interest calculations |
| **SSL validation** | Bad certificate errors explicitly caught and rejected |

---

## Getting Started

```bash
# 1. Install dependencies
flutter pub get

# 2. Run in debug mode
flutter run

# 3. Run tests
flutter test

# 4. Analyze code
flutter analyze
```

### Prerequisites

- Flutter SDK ^3.12.2 (stable channel)
- Dart SDK ^3.12.2
- Android Studio / Xcode for platform-specific builds
