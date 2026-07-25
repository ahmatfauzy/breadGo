## 2024-07-25 - Prevent Infinite Re-renders in GetX Obx
**Learning:** Calling state-modifying or data-fetching functions (like `fetchProducts`) directly inside a GetX `Obx` or widget `build` method triggers infinite re-render loops and excessive API calls, especially when the data list is empty.
**Action:** Always place data-fetching and state-modifying functions in GetX controller lifecycle methods (e.g., `onInit`) and never inside `Obx` or `build` methods.
