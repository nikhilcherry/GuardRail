# Project Optimization and Documentation Report

## 1. Project Overview
**Guardrail** is a Flutter-based mobile application designed for residential security access management. It serves three primary user roles:
- **Residents**: Manage visitors, receive approvals, and view logs.
- **Guards**: Scan QR codes, log entries/exits, and verify visitors.
- **Admins**: Manage flats, guards, and system settings.

The application uses **Provider** for state management and **GoRouter** for navigation. It is designed with a "security-first" mindset (e.g., locking the app on background, HTTPS enforcement).

## 2. File and Module Analysis

### 2.1 Directory Structure
- `lib/main.dart`: Entry point. Initializes services (Firebase, Crash Reporting) and Providers.
- `lib/router/`: Contains `AppRouter`, handling all navigation logic and route guarding.
- `lib/providers/`: State management logic (`AuthProvider`, `GuardProvider`, `ResidentProvider`, etc.).
- `lib/repositories/`: Data access layer. Currently uses a mix of in-memory caching and mock services, structured to swap easily with real APIs.
- `lib/services/`: External integrations (`AuthService`, `LoggerService`, `CrashReportingService`).
- `lib/screens/`: UI logic organized by role (`admin`, `guard`, `resident`, `auth`).
- `lib/l10n/`: Localization files.

### 2.2 Obsolete & Redundant Files
The following files and directories were identified as obsolete, unused, or deprecated and are recommended for removal:

| File / Directory | Reason for Removal |
| :--- | :--- |
| `stitch_role_selection/` | Contains raw HTML/CSS/Tailwind mockups not used in the Flutter app. |
| `lib/screens/role_selection_screen.dart` | The role selection flow has been moved to `WelcomeScreen` (entry) and `SignUpScreen`/`LoginScreen`. It is not referenced in `AppRouter`. |
| `lib/screens/admin/admin_additional_screens.dart` | Explicitly marked as deprecated. Its content has been split into `AdminFlatsScreen`, `AdminGuardsScreen`, etc. |
| `lib/main.dart` (Class `RootScreen`) | `RootScreen` is dead code. `AppRouter` handles the initial redirection logic based on auth state, rendering this widget unused. |

### 2.3 Key Modules & Documentation

#### **AuthProvider (`lib/providers/auth_provider.dart`)**
- **Purpose**: Central hub for authentication state (LoggedIn, Role, User Data).
- **Key Features**:
  - `checkLoginStatus()`: Runs on startup to restore session from `SharedPreferences`/`SecureStorage`.
  - `loginWithPhoneAndOTP` / `loginWithEmail`: Authenticates via `AuthService` (HTTP) with a fallback to `MockAuthService` for demo purposes.
  - `lockApp()` / `unlockApp()`: Handles biometric security when the app goes to the background.
  - `verifyId()`: Manages the "Pending Approval" state for Guards.

#### **GuardProvider (`lib/providers/guard_provider.dart`)**
- **Purpose**: Manages the operational state for Guards (Visitor entries, Scan logs).
- **Key Features**:
  - `processScan()`: Validates QR codes. **Note**: Contains logic to prevent duplicate scans for the same location ID on the same day.
  - `entries`: List of visitors. Currently initialized with dummy data (`_entries`) which should be removed in production.
  - `_loadData()`: Simulates fetching data.

#### **AppRouter (`lib/router/app_router.dart`)**
- **Purpose**: Centralized navigation configuration using `go_router`.
- **Key Features**:
  - **Route Guards (`redirect`)**: Automatically redirects users based on `isLoggedIn`, `isVerified`, `selectedRole`, and `isAppLocked`. This ensures unverified users or locked sessions cannot access dashboard routes.

#### **AuthService (`lib/services/auth_service.dart`)**
- **Purpose**: Handles network requests for authentication.
- **Key Features**:
  - `login` / `register`: HTTP POST requests.
  - **Security**: Enforces a 30-second timeout to prevent DoS via hanging connections.
  - **Biometrics**: Wraps `local_auth` for device authentication.

## 3. Optimization Recommendations

### 3.1 Code Cleanup
1.  **Remove `RootScreen`**: In `lib/main.dart`, the `RootScreen` class is unused. The `MaterialApp.router` uses `AppRouter`, which does not utilize `RootScreen`.
2.  **Delete `stitch_role_selection/`**: This directory adds unnecessary weight to the repository.
3.  **Refactor `GuardProvider`**:
    -   **Issue**: `_entries` is initialized with hardcoded dummy data.
    -   **Fix**: Initialize with an empty list and fetch data from `VisitorRepository` or an API on `init`.
    -   **Performance**: `processScan` iterates through `_checks` (List) to find duplicates. For a high volume of checks, use a `Set<String>` of keys (e.g., `"${guardId}_${locationId}_${date}"`) for O(1) lookup.

### 3.2 Security Improvements
-   **Mock Fallbacks**: `AuthProvider` currently falls back to `MockAuthService` if the HTTP request fails. In a production release, this fallback should be strictly disabled or wrapped in a `kDebugMode` check to prevent potential bypasses if the real server is down.
-   **Secure Storage**: Ensure `flutter_secure_storage` is used for all sensitive tokens (currently implemented in `AuthService`), but verify that `SharedPreferences` (used for `isLoggedIn` flags) does not store PII.

### 3.3 Performance
-   **Image Caching**: The app uses `Image.file` and network images. Ensure `cached_network_image` is used for profile photos to prevent repeated downloads.
-   **List Rendering**: `GuardHomeScreen` and `ResidentHomeScreen` lists are already using `ListView.builder` / `SliverList`. Ensure `itemExtent` or `prototypeItem` is used if list items have fixed heights to optimize layout calculation.

## 4. Conclusion
The project is well-structured and follows modern Flutter best practices (Provider, GoRouter, Lints). The primary work needed is **cleanup** (removing unused files) and **transitioning from mock data to real API integration**. The security foundations (Lock Screen, Biometrics, Secure Storage) are solid.
