**App Improvements — GuardRail**

This document lists recommended improvements to make the GuardRail Flutter app more robust, secure, and production-ready. Items are grouped by priority and include concrete action suggestions you or your team can pick up immediately.

**High Priority (P0)**
- **Secure Authentication Backend:** Replace simulated login in `lib/providers/auth_provider.dart` with real server-side authentication (HTTPS API). Enforce server-side validation for OTP, email/password, and role authorization.
  - Actions: Define API contracts, add network client (e.g., `dio` or `http`), implement token-based auth (JWT or OAuth), and persist tokens securely (use `flutter_secure_storage`).

- **Remove or Isolate Demo Credentials:** Remove demo credentials from `QUICK_START.md` or clearly mark them as local/test-only. Add scripts or a test-only seeder to create local demo accounts instead of publishing credentials.
  - Actions: Update `QUICK_START.md`, add `scripts/create_test_accounts.dart` (or a JSON seed), and document how to run it locally.

- **Fix Login Flow & Add Registration:** Fix the login-button handler logic in `lib/screens/auth/login_screen.dart` and add a `SignUpScreen` for resident/guard registration. Clarify role-specific registration rules (e.g., admin created by owner only).
  - Actions: Implement `SignUpScreen`, wire it to `LoginScreen` (small "Create account" link), and add server endpoints for registration and verification.

**Medium Priority (P1)**
- **Forgot Password & Account Recovery:** Implement an email-based reset password flow and wire the 'Trouble logging in?' button to a `ForgotPasswordScreen`.

- **Phone Input & OTP UX:** Use a robust phone input component (e.g., `intl_phone_number_input`) and implement OTP resend rate-limiting UI (countdown timer, disabled resend button). Validate numbers to E.164 before sending to backend.

- **Role-aware UI & Onboarding:** Make the login and onboarding screens reflect the selected role (`Resident`, `Guard`, `Admin`) and provide a short role-specific onboarding tutorial after first login.

- **Secure Secrets & Configuration:** Move environment-specific values (API base URL, keys) to `.env` or platform-specific config. Use `flutter_dotenv` for local config and ensure secrets are not committed.

**Low Priority (P2)**
- **Accessibility & Localization:** Extract hard-coded strings to ARB files and add `flutter_localizations`. Add semantic labels, ensure color contrast, and validate with accessibility tools.

- **Analytics & Error Tracking:** Add analytics (optional) and error reporting (Sentry) to capture crashes and user flows for improving UX.

- **Automated Tests & CI:** Add unit tests for `AuthProvider`, widget tests for `LoginScreen`/`RoleSelectionScreen`, and create a CI pipeline (GitHub Actions) to run `flutter analyze`, `flutter test`, and build checks.

- **Performance & Image Assets:** Optimize assets, adopt deferred loading for large modules, and profile the app on representative devices.

**Developer Experience**
- **Code Style & Linting:** Add `analysis_options.yaml` rules (already present) and enforce with CI. Consider `flutter format` and pre-commit hooks.

- **Local Dev Seed & Debugging Utilities:** Provide a local seed for data and a `README-dev.md` with debug instructions (`flutter run -d <device>`, how to enable verbose logs, how to seed demo accounts).

- **README & CONTRIBUTING:** Improve `README.md` with clear setup (Android/iOS), how to run the seeder, how to run tests, and how to open the app with different roles.

**Security Checklist (short)**
- Use `flutter_secure_storage` for tokens and sensitive data.
- Enforce HTTPS only, validate TLS certs if using pinned config.
- Rate-limit OTP endpoints and throttle resend attempts.
- Do not commit secrets or demo admin passwords.

**Suggested Implementation Plan**
1. P0: Fix login handler bug and dynamic login title; remove demo credentials from `QUICK_START.md` (small PR, quick win).
2. P0: Wire `AuthProvider` to real authentication endpoints (or create a test API mock server for dev). Add secure token storage.
3. P1: Add `SignUpScreen` and `ForgotPasswordScreen` and the phone validation + OTP UI improvements.
4. P1: Add basic CI: `flutter analyze`, `flutter test`, and a build check.
5. P2: Accessibility, i18n, analytics, and performance optimizations.

**If you want, I can implement step 1 now:**
- Fix the login button conditional and make the login title dynamic.
- Remove or clearly flag demo credentials in `QUICK_START.md`.

Which tasks should I start implementing? Reply with one or more choices (e.g., "P0 fixes", "Add SignUp", "Add CI tests").
