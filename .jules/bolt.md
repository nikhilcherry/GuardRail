## 2024-05-23 - Undisposed Controllers in Dialogs

**Learning:** `showDialog` combined with `StatefulBuilder` often leads to `TextEditingController` memory leaks. When initialized inside the builder method (or before it as local variables), these controllers are never disposed because there is no `dispose` lifecycle hook for a simple method or `StatefulBuilder`.

**Action:**
1. Extract dialog content into a dedicated `StatefulWidget`.
2. Initialize controllers in `initState` and `dispose()` them in `dispose`.
3. This ensures that every time the dialog is closed, the resources (native text input connections) are properly released.

## 2024-05-24 - Expensive Computations in Getters

**Learning:** Getters or methods called inside `build()` (especially via `Consumer`) that perform collection filtering (e.g., `.where(...).toList()`) run on every rebuild. Even for small lists, this creates necessary garbage. For large lists, it becomes O(N) per frame.

**Action:** Cache the result of expensive filter operations in the provider. Invalidate the cache only when the underlying data source changes. This turns the read operation into O(1).

## 2024-05-24 - DateFormat Caching Misconception

**Learning:** `DateFormat` from `package:intl` uses an internal factory cache. Extracting it to a `static final` variable provides negligible performance benefits while breaking localization support (static variables don't update on locale change).

**Action:** Prefer using `DateFormat` directly (or via a localized helper) to ensure correct locale handling, unless profiling proves strict object allocation is a bottleneck despite the factory cache.

## 2025-02-27 - Large Consumers Cause Unnecessary Header Rebuilds

**Learning:** Wrapping an entire screen in a `Consumer` (or `Consumer2`) causes the entire widget tree to rebuild whenever *any* part of the state changes. This is particularly wasteful when the screen has a static or semi-static header (e.g., "Good Evening, [Name]") that rebuilds every time a list below it updates (e.g., visitor log changes).

**Action:**
1. Extract the header into a separate widget.
2. Use `Selector` or scoped `Consumer` within the header to listen only to the specific properties it needs (e.g., user name, notification count).
3. Ensure the parent screen uses `const` for the header widget, so it is not rebuilt when the parent rebuilds.
4. Limit the main `Consumer` to wrap only the dynamic list content (e.g., `SliverList` or `Expanded`).
