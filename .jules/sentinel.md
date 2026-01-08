# Sentinel Journal

## 2024-05-23 - Insecure Default Configuration
**Vulnerability:** `AuthService` contained a hardcoded fallback to `https://api.example.com` when the `API_BASE_URL` environment variable was missing.
**Learning:** This could lead to credential leakage if the app is deployed with a missing configuration, as it would silently send user data to an arbitrary external server.
**Prevention:** Fail securely by throwing an exception if critical configuration is missing. Ensure the app crashes or shows a config error rather than defaulting to an insecure state.
