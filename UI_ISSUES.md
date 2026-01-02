**UI Issues & Recommendations**

This document lists observed UI and authentication-related issues in the GuardRail project, with file references and suggested fixes. Use this as a checklist when improving the user experience and security for authentication and role flows.

**Summary:**
- **Scope:** Authentication screens, role selection, and related UI across the app.
- **Primary concerns:** Missing sign-up flow, unclear/dynamic role handling, incorrect login logic, placeholder demo credentials in docs, and a few UX/accessibility gaps.

**Authentication / Login (high priority)**
- **Hardcoded title (incorrect role text):** `lib/screens/auth/login_screen.dart` shows the static heading `Guard Login`. When the app supports multiple roles (resident, guard, admin) the title should reflect the selected role.
  - Impact: Confuses users who selected a different role.
  - Suggestion: Read `AuthProvider.selectedRole` and render a contextual title, e.g. `${roleCapitalized} Login`.

- **Missing Sign-up / Registration screen:** There is no visible flow for users to create accounts (sign up) for residents or guards.
  - Files checked: `lib/screens/auth/login_screen.dart`, `lib/screens/role_selection_screen.dart`, `lib/providers/auth_provider.dart`.
  - Impact: New users can't register; only demo accounts work.
  - Suggestion: Add a `SignUpScreen` (phone/email registration) and surface a "Create account" link on the login screen.

- **Login button logic bug (wrong handler selection):** In `lib/screens/auth/login_screen.dart` the login button's `onPressed` chooses handlers that don't match `_useEmail` meaning:
  - It calls phone/OTP handlers even when `_useEmail == true`.
  - Impact: Email password login may not be executed correctly.
  - Suggestion: Fix conditional to call `_handleEmailLogin` when `_useEmail` is true; call `_handlePhoneLogin` only for phone flow; call `_handleOTPVerification` when verifying OTP.

- **Empty 'Trouble logging in?' action:** `login_screen.dart` includes a `TextButton.icon` for 'Trouble logging in?' with an empty `onPressed`.
  - Impact: Dead UI; no password reset or support flow.
  - Suggestion: Implement a 'Forgot password' flow (email) and a help/support modal or link.

- **Phone input validation & formatting:** Phone field only checks presence; no formatting/validation (country code handling, E.164). The UI uses a US-formatted hint but there's no enforcement.
  - Suggestion: Use a phone input package (e.g., `intl_phone_number_input`) or validate E.164 formatting. Add helpful error messages and show country code.

- **OTP resend UX:** `resendOTP` is implemented but there's no rate-limit UI (countdown) and no visual feedback besides a snackbar.
  - Suggestion: Add a countdown timer and disable resend until timer expires.

**Role Selection & Navigation**
- **Role selection isn't shown after login:** `main.dart` uses `AuthProvider.selectedRole` to decide which home to show, but the `LoginScreen` does not show the selected role or allow changing it in-place.
  - Files: `lib/screens/role_selection_screen.dart`, `lib/main.dart`.
  - Suggestion: Show the selected role on the login screen, and allow switching back to role selection (small link/button) without logging out.

- **No registration pathway per-role:** There's no difference between role-specific sign-up paths (e.g., admin-only creation vs resident self-register). Clarify policies and add flows accordingly.

**Security / Documentation (important)**
- **Demo credentials in `QUICK_START.md`:** Demo phones, OTPs and an `admin` password (`admin123`) exist in `QUICK_START.md`.
  - Impact: If accidentally used in production, this leaks insecure credentials.
  - Suggestion: Remove credentials from public docs or clearly mark them as local-only; replace with developer-only environment variables or reproduce accounts created at runtime.

- **AuthProvider simulates login without server validation:** `lib/providers/auth_provider.dart` sets `_isLoggedIn = true` after a delay (no credential checks).
  - Impact: This is fine for prototyping, but must be replaced before production with secure API calls.

**UX / Accessibility / Miscellaneous**
- **Lack of loading / disabled states for secondary actions:** Some UI elements (resend buttons, toggle) lack clear disabled/active states.
- **Contrast & accessibility checks:** Use semantic labels for icons, add `semanticsLabel` where appropriate, ensure color contrast meets WCAG for text on `AppTheme.primary` backgrounds.
- **No i18n / localization:** Text strings are hard-coded; consider extracting to localization files.

**Concrete Fixes (suggested code changes)**
- Fix login handler selection in `login_screen.dart` (example):

  - Replace the button onPressed logic with:

    - If `_useEmail` is true:
      - If `_showOTPInput` is true -> call `_handleOTPVerification` (if email OTP flow is used) or call `_handleEmailLogin` for password.
      - Else -> call `_handleEmailLogin`.
    - Else (phone flow):
      - If `_showOTPInput` -> `_handleOTPVerification` else `_handlePhoneLogin`.

- Make the login title dynamic using `context.watch<AuthProvider>().selectedRole`.

- Add a `SignUpScreen` and a small link/button on the `LoginScreen` to open it.

- Implement a `ForgotPasswordScreen` or modal, wire it to the 'Trouble logging in?' button.

**Next steps / Prioritization**
- P0 (urgent): Fix the login button handler bug; remove insecure demo credentials from public docs.
- P1: Add sign-up and forgot-password flows; make login title dynamic per role.
- P2: Improve phone validation, OTP resend UX, and add accessibility labels.

If you'd like, I can open a PR that:
- Fixes the login button conditional and makes the title dynamic.
- Removes or flags demo credentials in `QUICK_START.md`.
- Adds a placeholder `SignUpScreen` and wires a link from the login screen.

Tell me which of the above you'd like implemented first and I'll create the changes and tests as needed.
