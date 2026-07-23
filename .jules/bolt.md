## 2024-07-24 - Flutter Obx Build Method Anti-Pattern
**Learning:** Calling state-modifying functions (like API fetches) inside a GetX `Obx` block or `build` method creates an infinite loop if the condition for calling it (e.g. `isEmpty`) is continuously met (e.g. an empty response from server).
**Action:** Always ensure data fetching happens in controller lifecycle methods (like `onInit` or `onReady`) or via user interactions, never inside reactive widget build methods.
