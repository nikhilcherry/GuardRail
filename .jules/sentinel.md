## 2024-02-22 - Sensitive Error Exposure in UI
**Vulnerability:** The application was catching exceptions during login (e.g., `catch (e)`) and displaying the raw exception message `$e` directly to the user in a `SnackBar`.
**Learning:** Exposing raw error messages or stack traces to users is a security risk (Information Disclosure). It can reveal backend implementation details, database structure, or internal network information to attackers.
**Prevention:** Always catch specific exceptions where possible, and display generic, user-friendly messages to the UI (e.g., "Login failed. Please check your credentials."). Log the specific error details securely for debugging purposes, but never show them to the end user.

## 2024-05-21 - Sensitive Log Exposure
**Vulnerability:** The application was using `print()` to log "EMERGENCY" events including timestamps in `GuardProvider` and `ResidentProvider`.
**Learning:** `print()` output is often visible in system logs (like Android `logcat`) even in release builds, potentially exposing sensitive user actions or state to other applications or physical attackers.
**Prevention:** Use a dedicated logging service (like `LoggerService`) that conditionally logs only in debug mode or sends encrypted logs to a crash reporting service in production.

## 2024-05-23 - Unbounded Network Requests
**Vulnerability:** `http.post` calls in `AuthService` lacked a timeout configuration.
**Learning:** Default HTTP clients often have no timeout or very long timeouts. This allows malicious actors or unstable networks to hang the application indefinitely, leading to resource exhaustion (DoS) and poor UX.
**Prevention:** Always chain `.timeout()` to `Future`-based network calls or configure a global timeout in the HTTP client options.

## 2024-05-27 - Unbounded Input Length (DoS)
**Vulnerability:** The `VisitorDialog` text fields (Name, Flat, Vehicle) had no `maxLength` constraint, allowing entry of strings of unlimited length.
**Learning:** Accepting unbounded input can lead to Denial of Service (DoS) via memory exhaustion (OOM crashes) or processing delays, especially if this data is persisted or sent to a backend.
**Prevention:** Always enforce `maxLength` on `TextField` and `TextFormField` widgets, aligning limits with backend database schemas or reasonable UI constraints.

## 2024-10-24 - Insecure PII Storage in Shared Preferences
**Vulnerability:** The `AuthRepository` was storing sensitive user data (Name, Email, Phone, Flat ID) in plain-text `SharedPreferences`.
**Learning:** `SharedPreferences` on Android stores data in an XML file that can be easily read if the device is rooted or via backup extraction. It is not suitable for Personally Identifiable Information (PII).
**Prevention:** Use `FlutterSecureStorage` (which uses Keystore/Keychain) for all sensitive data. Only use `SharedPreferences` for non-sensitive UI flags (e.g., `isLoggedIn`, `themeMode`).

## 2024-10-25 - Insecure Random Number Generation
**Vulnerability:** The application was using `Random()` to generate `flatId` and `guardId`.
**Learning:** `Random()` is a pseudo-random number generator (PRNG) that is not cryptographically secure. Predictable IDs can potentially lead to enumeration attacks or unauthorized resource access.
**Prevention:** Use `Random.secure()` for generating IDs, tokens, or any security-sensitive values to ensure they are unpredictable.
