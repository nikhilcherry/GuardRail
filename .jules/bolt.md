## 2024-05-22 - Expensive Computation in Build
**Learning:** Found O(N) list grouping logic running directly inside `build()` method of `ResidentVisitorsScreen`. This causes unnecessary CPU work on every frame/rebuild.
**Action:** Move expensive data transformations to the Provider/State class and use caching/memoization. Exposed `groupedVisitors` getter in `ResidentProvider`.
