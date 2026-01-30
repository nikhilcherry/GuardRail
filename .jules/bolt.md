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

## 2024-05-25 - Caching Stats in Provider

**Learning:** Computing statistics (like counts of pending/active items) inside the `build` method leads to redundant iterations and object allocations on every frame.

**Action:** Move the calculation to the Provider level. Compute the stats only when the data changes (in mutator methods) and cache the result in simple variables. Expose these variables via getters for O(1) access in the UI.

## 2024-05-25 - TableCalendar O(N*M) Event Loading

**Learning:** `TableCalendar`'s `eventLoader` callback is invoked for every visible day (M ~ 42) on every rebuild. Providing a function that filters the full list (O(N)) results in O(N*M) complexity, causing severe lag during scrolling or selection.

**Action:** Pre-calculate a `Map<DateTime, List<Event>>` (grouping events by date) whenever the data source changes. This allows the `eventLoader` to perform O(1) lookups, reducing overall complexity to O(N + M).

## 2024-05-25 - Memory Impact of Unresized Images

**Learning:** Loading full-resolution images (e.g., from camera) into small thumbnail widgets using `FileImage` consumes excessive memory as the entire image is decoded. For a grid of thumbnails, this can quickly lead to OOM or jank.

**Action:** Wrap `FileImage` with `ResizeImage` (or `ResizeImage.resizeIfNeeded`) specifying the target `width` or `height` (e.g., `width: 150` for thumbnails) to decode only the necessary dimensions, significantly reducing memory footprint.

## 2024-05-25 - Removing Redundant Models and Caching

**Learning:** Duplicate models (e.g., `ResidentVisitor` wrapping `Visitor`) cause unnecessary O(N) object allocation loops during data updates. Additionally, logic like grouping events by date inside `build()` methods (for `TableCalendar`) causes O(N) recalculations on every rebuild.

**Action:**
1.  Standardize on a single shared model (`Visitor`).
2.  Move expensive grouping/filtering logic to the Provider (e.g., `groupedVisitors`).
3.  Memoize the result in the Provider and only invalidate it when the underlying data changes.
