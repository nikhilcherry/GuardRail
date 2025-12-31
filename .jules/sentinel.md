## 2024-02-22 - Sensitive Error Exposure in UI
**Vulnerability:** The application was catching exceptions during login (e.g., `catch (e)`) and displaying the raw exception message `$e` directly to the user in a `SnackBar`.
**Learning:** Exposing raw error messages or stack traces to users is a security risk (Information Disclosure). It can reveal backend implementation details, database structure, or internal network information to attackers.
**Prevention:** Always catch specific exceptions where possible, and display generic, user-friendly messages to the UI (e.g., "Login failed. Please check your credentials."). Log the specific error details securely for debugging purposes, but never show them to the end user.
