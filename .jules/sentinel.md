## 2024-05-22 - Missing Input Length Validation
**Vulnerability:** Text fields for email (password reset) and visitor names (QR generation) lacked `maxLength` constraints.
**Learning:** Even simple text fields can be vectors for DoS or buffer overflow attacks if inputs are unbounded.
**Prevention:** Always enforce `maxLength` on `TextField` and `TextFormField`. Use `buildCounter` to hide the counter if it disrupts the UI design.
