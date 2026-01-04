# Detailed Issues Report — GuardRail App

This document records the UI and functional issues you reported while using the app, explains likely causes, points to where to look in the codebase, and gives suggested fixes or next steps. I did not change code — this is an actionable diagnostic you can use or hand to a developer.

Date: 2025-12-31
Author: Repository analysis / user report

---

## Overview

You reported a set of usability and functional issues across the Resident, Guard and Admin flows. The problems include navigation/back-button behavior, non-working controls (notifications, logout, profile, change-password, toggles), misalignment in UI elements, missing persistence (app forgets login on restart), and some pages or buttons that appear but do not perform actions.

Below each issue is described with:
- What you observed (reproduction steps)
- Why this is likely happening (probable causes)
- Where to look in the repo (files / code areas)
- Suggested fix (concrete next steps and priority)

If you want, I can convert any of the suggested fixes into a PR and implement them.

---

## 1) Cannot go back to Role Selection after using "Trouble logging in" (Android back button)

Observed
- From the Role selection → Resident → "Trouble logging in?" flow, pressing the device Back button does not return to the role-selection screen. The app exits instead.

Reproduction
- Open app → Tap `Resident` → Tap `Trouble logging in?` → Press device Back button (or top/back UI icon) → App closes instead of going to role-selection screen.

Likely causes
- The screen stack may have been replaced rather than pushed, or a `WillPopScope` / back-handler is missing. Another possibility is the role-selection screen was removed from the navigation stack using `Navigator.pushReplacement` or `Navigator.pushAndRemoveUntil`, so there is no previous route to pop back to.
- If the app uses a top-level Navigator to swap home widgets based on `AuthProvider.selectedRole` (instead of normal navigation), the navigation stack may not include the role-selection screen after a selection.

Where to look
- `lib/screens/role_selection_screen.dart` — how roles are selected (calls to `selectRole`).
- `lib/main.dart` — how the app decides which screen to show after role selection (whether routes are replaced).
- The code creating the "Trouble logging in?" screen / button handler (likely `lib/screens/auth/login_screen.dart`).

Suggested fix
- Ensure role selection pushes routes (use `Navigator.push`) rather than replacing the stack unless intentional. If you need a replacement, provide an explicit back path (a 'Change role' button should navigate to role selection using `Navigator.pushReplacement` or navigate to it with a proper route).
- Add a `WillPopScope` to the trouble-login screen to override the hardware back button and explicitly navigate to role selection when pressed.
- Priority: P0 (high) — navigation/back behavior is core UX.

---

## 2) Notification tab not working / misaligned in Resident home

Observed
- In the Resident tab, the notification icon/tab does nothing when tapped. The icon or badge is visually misaligned with its container (styling issue).

Reproduction
- Login as Resident → Open top bar (notification area) → Tap notification icon → No action. Also observe misalignment relative to the box/container.

Likely causes
- The notification button's `onPressed` handler may be empty or unimplemented. The visual misalignment is probably a layout issue: either wrong padding/margins, incorrect use of `Row`/`Stack` alignment, or a fixed-size container that doesn't match icon size.
- If the app uses different AppBar variants per role, the notification widget might be missing role-specific wiring.

Where to look
- `lib/screens/resident/resident_home_screen.dart` (or the resident appbar widget) — the notification button widget.
- Shared top bar widget if the app uses a common `AppBar` component or `lib/theme/app_theme.dart` for sizes.

Suggested fix
- Implement the `onPressed` handler to navigate to the notification screen (or show a modal) and verify that the notification icon is inside a properly sized container (use `IconButton` rather than `GestureDetector` on a custom-sized `Container` when possible).
- Adjust padding and alignment with `MainAxisAlignment` / `CrossAxisAlignment` and verify with different device widths.
- Priority: P1 (medium) — functionality and polish.

---

## 3) Settings back navigation and hardware Back button exits app instead of navigating back

Observed
- From Settings, pressing the device Back button exits the app instead of navigating back to the previous screen. The top/back UI control also does not work.

Reproduction
- Login → Navigate to Settings → Press hardware Back or top/back arrow → App quits (or no effect) instead of returning to previous page.

Likely causes
- The Settings screen might be launched with `Navigator.pushReplacement` or `Navigator.pushAndRemoveUntil`, which clears previous routes. Alternatively, the Settings screen's AppBar may not include a `leading` widget (the top back arrow) or the leading widget's `onPressed` is not wired.
- Another common cause is using `Scaffold` inside a Navigator-less context or replacing the root widget after login so the Settings screen is the only route in the stack.

Where to look
- `lib/screens/resident/resident_settings_screen.dart` or equivalent resident/admin settings files.
- How navigation is invoked when opening Settings (button code) — check `.onTap` or `Navigator` usage where Settings is opened.

Suggested fix
- Use `Navigator.push` to open Settings, ensuring a previous route exists. If you must use replacement, add an explicit `back` or `change role` button that navigates to the intended parent.
- Ensure AppBar includes a `leading: BackButton()` or `IconButton` wired to `Navigator.pop(context)`.
- Priority: P0 (high) — navigation expectations are core.

---

## 4) Logout button visible but does not log the user out

Observed
- Clicking "Log out" in Settings shows a button press but does not log the user out. The app may require closing/reopening before login is lost/changed.

Reproduction
- Login as Resident/Guard/Admin → Settings → Tap `Log out` → Nothing happens (still logged in) or requires closing the app to return to login.

Likely causes
- The `onPressed` implementation for logout may not be wired to the `AuthProvider.logout()` or it may call logout but `AuthProvider` only changes `_isLoggedIn` in memory and the app's main widget rebuild logic might not react (e.g., missing `notifyListeners()` or the main consumer is not listening). Alternatively, if login persistence is used incorrectly (i.e., stored token is not cleared), the app may re-authenticate on resume.
- Another cause: logout action might trigger navigation to login, but because `selectedRole` or other state is still set, the `main.dart` logic immediately re-routes into the app shell.

Where to look
- `lib/screens/*/settings` files for the `onPressed` handler.
- `lib/providers/auth_provider.dart` — logout implementation (we inspected it earlier: `logout()` resets state and calls `notifyListeners()` — if other parts of the app are not reacting, the issue is in how the UI listens/reacts).
- `lib/main.dart` — how `AuthProvider.isLoggedIn` is used to choose initial screen.

Suggested fix
- Verify the logout button calls `context.read<AuthProvider>().logout()` and that `AuthProvider.logout()` clears persistent tokens (if implemented) and calls `notifyListeners()`.
- If tokens or session data are stored (e.g., in `shared_preferences` or `flutter_secure_storage`), ensure those are deleted on logout.
- Ensure that `main.dart` listens to `AuthProvider` and navigates to the login screen immediately on `isLoggedIn == false`.
- Priority: P0 (high) — security and expected behavior.

---

## 5) Profile and Change Password pages not opening

Observed
- Tapping `Profile` or `Change Password` does not open the respective screens.

Reproduction
- Settings → Tap `Profile` or `Change Password` → Nothing (no navigation or the screen is blank).

Likely causes
- The UI elements may have empty `onPressed` handlers or may navigate to a route that is not registered in the app's routing table. Another cause is that the target screens exist but their constructors are incomplete or throw an error silently (caught) so nothing displays.

Where to look
- `lib/screens/resident/resident_settings_screen.dart` (or admin settings). Search for the entries for `Profile` and `Change Password` and validate their `onTap`/`onPressed` code.
- `lib/screens/profile/*` and `lib/screens/auth/*` for change-password screens.

Suggested fix
- Add/verify `onPressed` handlers to navigate to the correct routes, ensure routes are added to `MaterialApp.routes` or use `Navigator.push` with a `MaterialPageRoute`.
- Add try/catch logging to surface exceptions if constructors are failing.
- Priority: P1 (medium)

---

## 6) Visitor management / face login / toggles and theme switches don't persist or have no effect

Observed
- In Settings: toggles such as Face ID, Notification toggles, Dark/System theme toggle change visually but do not affect app behavior or are non-functional.

Reproduction
- Settings → Toggle Face ID / Notification / Theme → Visual toggle moves but app behavior (theme or notifications) does not change or changes only temporarily.

Likely causes
- The switch widgets likely update only local state (a `setState` flag) but do not persist the change into a global provider or persistent storage, nor do they trigger the app theme or platform-specific behavior.
- Example: theme toggles must update a shared theme provider or call a method in a top-level stateful widget to re-run `MaterialApp` with new `ThemeData`.

Where to look
- `lib/screens/*/settings` files for toggle code. `lib/theme/app_theme.dart` for theme definitions. Any provider file that may manage app theme (not present by default).

Suggested fix
- Create or use a theme provider (e.g., `ThemeProvider`) that stores selected theme in `SharedPreferences` or `flutter_secure_storage`, notify listeners on change, and apply the theme at the `MaterialApp` level.
- Hook Face ID & notification toggles to the underlying platform APIs or to a settings provider that persists their values.
- Priority: P1 (medium)

---

## 7) Top-left/back arrow (AppBar) not working

Observed
- The top app bar back arrow does not perform navigation; pressing it has no effect.

Reproduction
- Open a sub-screen that shows a top-left back arrow → tap the arrow → nothing happens.

Likely causes
- The app bar may have a custom `leading` with an `Icon` instead of `BackButton` or `IconButton` wired to `Navigator.pop(context)`. If the widget renders but `onPressed` is empty it won't pop.
- If the route stack has no previous route (see earlier issues), `Navigator.pop` may exit the app.

Where to look
- Any `AppBar` declarations in the screens where you observe this behavior (e.g., settings screens, profile screens). Search for `AppBar(leading:` occurrences.

Suggested fix
- Use `leading: BackButton()` or `leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context))`. Also guard `Navigator.canPop(context)` where needed and provide an alternate navigation path when pop is not possible.
- Priority: P0 (high)

---

## 8) App returns to Login on close/reopen (no remembered session)

Observed
- After closing the app and reopening, it returns to the login screen even if the user did not explicitly logout.

Reproduction
- Login → Close app → Reopen app → Login screen shown.

Likely causes
- There is no persistent authentication state. The currently inspected `AuthProvider` sets `_isLoggedIn = true` in memory, but there is no code to persist a session token to disk on login and restore it on startup.

Where to look
- `lib/providers/auth_provider.dart` — login methods and whether token storage is implemented.
- `lib/main.dart` — initial checks on startup — if it only reads in-memory flags it will not remember login.

Suggested fix
- Implement secure persistent session storage: after login store a token/flag in `flutter_secure_storage` or `shared_preferences`. On app start, attempt to read stored credentials and validate them (e.g., call a `/me` endpoint) before setting `isLoggedIn = true`.
- Priority: P0 (high)

---

## 9) Guard flow: some items not clickable; missing logout option

Observed
- Guard flow mostly works, but `View all` does nothing and some recent entries are non-interactive. There's no visible logout option from specific guard pages.

Reproduction
- Login as Guard → Visit guard pages → Tap `View all` or recent entries → nothing / no navigation. No logout in some screens.

Likely causes
- `onTap` handlers missing or routes not registered. Logout link might be missing from some pages so the user cannot easily sign out from nested screens.

Where to look
- Guard screens under `lib/screens/guard/` and their UI files for `onTap` handlers.

Suggested fix
- Add `onTap` implementations or enable navigation to the intended detail screens. Add a shared AppBar or menu with logout and settings links for guard pages, or ensure the top-level drawer includes logout.
- Priority: P1 (medium)

---

## 10) Admin flow: similar logout issues; otherwise content mostly visible

Observed
- Admin dashboard shows information but logout from settings does not work; user must close app to sign out.

Reproduction
- Login as Admin → Settings → Logout → no effect.

Likely causes
- Same as Issue 4: logout not clearing persistent data or not triggering UI state changes.

Where to look
- `lib/screens/admin/*` and `lib/providers/auth_provider.dart`.

Suggested fix
- Same as Issue 4 + ensure admin screens listen to `AuthProvider` for logout triggers.
- Priority: P0 (high)

---

## Cross-cutting recommendations

- Add logging and error reporting (Sentry, simple debug prints) around navigation actions so missing or failing navigations produce a visible error during development.
- Add unit/widget tests for navigation flows to catch regressions (role selection → login → settings → logout → back behaviour).
- Use a small state management pattern for settings and theme (Provider already used — extend it or add separate providers for `SettingsProvider` and `ThemeProvider`).
- Audit all `TextButton.icon`, `IconButton`, and `GestureDetector` uses and ensure each interactive UI element has a non-null `onPressed`/`onTap` that either navigates or provides feedback.

---

## Concrete first-step checklist (what I recommend the team do now)

1. Fix logout wiring and persistence: ensure `AuthProvider.logout()` clears persistence and `main.dart` listens to `isLoggedIn` and shows login screen immediately.
2. Fix back navigation on the trouble-login and settings screens by ensuring `Navigator.push` is used and adding `BackButton` in `AppBar` where missing.
3. Implement persistent login (store token/flag) and validate on app startup.
4. Run a quick search for `onPressed: () {}` or empty handlers and implement those handlers or remove dead UI.
5. Add developer logging when navigation fails to surface silent errors.

---

## Appendix — quick file pointers

- `lib/screens/auth/login_screen.dart` — login/OTP/email logic, toggles and "Trouble logging in?" button.
- `lib/providers/auth_provider.dart` — login/logout state; currently in-memory (no persistence).
- `lib/screens/role_selection_screen.dart` — how roles are selected and initial navigation.
- `lib/screens/resident/resident_settings_screen.dart` — resident settings UI (Logout, Change Password, Face ID toggles).
- `lib/screens/resident/resident_home_screen.dart` — resident home bar and notification UI.
- `lib/screens/guard/*` — guard flow pages (view all, check-ins, recent entries).
- `lib/screens/admin/*` — admin dashboard and settings.

