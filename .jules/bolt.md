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

## 2024-05-25 - TableCalendar Event Loading Complexity

**Learning:** `TableCalendar`'s `eventLoader` callback is invoked for every visible day cell during the build cycle. If the data source is a flat list of $N$ items and the calendar displays $M$ days, a naive `.where()` filter results in $O(N \times M)$ complexity. For a month view ($M \approx 42$), this iterates the entire list 42 times per frame.

**Action:** Pre-process the list into a `Map<int, List<Item>>` (using an integer key like `YYYYMMDD` to ignore time) whenever the source list changes. This reduces the complexity to $O(N)$ for the initial group and $O(1)$ for each calendar cell lookup.
