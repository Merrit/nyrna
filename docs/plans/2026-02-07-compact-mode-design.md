# Compact Card Density Mode Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add a “Compact mode” toggle in Personalization that reduces the internal vertical spacing/padding inside each process card while keeping the existing card-to-card spacing unchanged.

**Architecture:** Persist the toggle in `SettingsState`/`SettingsCubit`, expose it via the `PersonalizationSection` (with localization), and have `WindowTile` read it to adjust its inner padding/spacing in a single place.

**Tech Stack:** Flutter + Dart, Bloc/Cubit (`flutter_bloc`), Flutter Intl localization, widget tests via `flutter test`.

---

### Task 1: Persist the compact flag in settings

**Files:**
- Modify: `lib/settings/cubit/settings_state.dart`
- Modify: `lib/settings/cubit/settings_cubit.dart`
- Modify: `test/settings/cubit/settings_cubit_test.dart`

**Step 1:**  
Add a `compactCards` boolean to `SettingsState`, defaulting to `false` in `SettingsState.initial()` and included in every factory call.

**Step 2:**  
During `SettingsCubit.init`, read `'compactCards'` from storage (default `false`) and include it in the initial state. Provide a setter `updateCompactCards(bool value)` that saves to storage and emits the new state.

**Step 3:**  
Update `test/settings/cubit/settings_cubit_test.dart` to expect the default `compactCards == false`, to verify `storage.saveValue` is called when toggling it, and to cover the branch where storage already contains `true`.

**Step 4:**  
Run `flutter test test/settings/cubit/settings_cubit_test.dart` (via absolute-path Flutter) to confirm the new logic doesn’t regress.

**Step 5:**  
Commit these changes with `git commit -m "feat(settings): persist compact cards flag"`.

### Task 2: Expose the toggle in Personalization

**Files:**
- Modify: `lib/settings/widgets/personalization_section.dart`
- Modify: `lib/settings/widgets/widgets.dart`
- Modify: `lib/localization/app_en.arb`, `lib/localization/app_de.arb`, `lib/localization/app_it.arb`, `lib/localization/app_zh.arb`
- Generated: `lib/localization/app_localizations_*.dart`

**Step 1:**  
Add a new `SwitchListTile` (below the existing ones) that binds to `state.compactCards`, uses localized strings like `compactModeTitle`/`compactModeDescription`, and calls `updateCompactCards(value)` when toggled.

**Step 2:**  
Add the new localization entries to each `.arb` with descriptions and regenerate the Dart localization files via `flutter gen-l10n`.

**Step 3:**  
Ensure `lib/settings/widgets/widgets.dart` exports the updated section (already does) and run `flutter test test/settings/widgets/personalization_section_test.dart` after adding assertions that the new text exists and the cubit's setter is invoked.

**Step 4:**  
Commit this chunk with `git commit -m "feat(settings): add compact card toggle"`.

### Task 3: Apply compact spacing to WindowTile

**Files:**
- Modify: `lib/apps_list/widgets/window_tile.dart`
- Modify: `test/apps_list/widgets/window_tile_test.dart`

**Step 1:**  
Use `context.select` to read `state.compactCards`. When true, reduce the `contentPadding` of the `ListTile`, tighten the spacing between the leading dot and text, and shrink/removes the `SizedBox` or `Spacers` within the tile so the visible card body is more compact while the outer `Card` margin stays the same.

**Step 2:**  
In `_buildSubtitle` or the relevant widget tree, remove/reduce extra `SizedBox` widgets and lower `Column` spacing when `compactCards` is enabled.

**Step 3:**  
Update `test/apps_list/widgets/window_tile_test.dart` to verify that when `compactCards` is true the `ListTile` uses the tighter padding (e.g., by checking `find.byType(ListTile)` and verifying its `contentPadding`), and that when false the default spacing remains.

**Step 4:**  
Run `flutter test test/apps_list/widgets/window_tile_test.dart` to ensure the change survives.

**Step 5:**  
Commit with `git commit -m "feat(apps_list): support compact card spacing"`.

### Task 4: Visual verification & documentation

**Files:** (manual/notes)

**Step 1:**  
Launch the app, toggle the compact mode switch, and confirm each card’s inner spacing tightens while card-to-card spacing stays identical; do this in Settings and the main list.

**Step 2:**  
Document any follow-up tweaks needed in `docs/plans/<date>-compact-mode-notes.md` or update the TODO, then stage/commit if necessary.

**Step 3:**  
If all looks good, summarize the manual test results in the eventual PR description.

---

**Assumptions:** Existing personalization UI already loads `SettingsCubit`, so no additional Bloc wiring is needed; we’re still working on master without a separate worktree.
