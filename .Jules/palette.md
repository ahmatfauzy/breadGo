## 2024-07-22 - Adding Accessibility to Icon-Only Buttons in Flutter
**Learning:** When using `FloatingActionButton` or `IconButton` in Flutter with just an `Icon`, screen readers cannot easily infer the button's purpose. `semanticLabel` inside the `Icon` helps screen readers, and `tooltip` inside `FloatingActionButton` provides visual guidance (hover/long-press) and further context.
**Action:** Always include both a `tooltip` on the button itself and a `semanticLabel` on the `Icon` widget when adding icon-only interactive elements in Flutter, to maximize both usability and accessibility.
