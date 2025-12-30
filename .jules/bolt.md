# Bolt Journal

## 2024-02-22 - Unbounded ListView & DateFormat Optimization

**Learning:** `ListView(shrinkWrap: true)` inside a `SingleChildScrollView` defeats list virtualization, causing all items to render at once. This is a common performance bottleneck in scrollable screens with dynamic content. Also, instantiating `DateFormat` inside `build()` is a subtle but impactful overhead when repeated in list items.

**Action:**
1. Replace `SingleChildScrollView` + `Column` with `CustomScrollView` + `Slivers` (e.g., `SliverList`, `SliverToBoxAdapter`) when a list needs to scroll with other content.
2. Extract formatters (like `DateFormat`) to `static final` fields to reuse instances.
3. Always verify that list items are actually lazy-loaded (though environment limitations prevented runtime verification here).
