# Process Card Personalization Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add personalization controls to the settings page and make every window tile respect the four new toggles (PID visibility, executable priority, single-line title, suspended pinning) so users can fine-tune the card density.

**Architecture:** Extend `SettingsState`/`SettingsCubit` with the new personalization flags, register a new `PersonalizationSection` widget that lives alongside the current Behavior/Theme sections, and make `WindowTile` react to the updated state while keeping sorting/pinning logic inside `AppsListCubit`.

**Tech Stack:** Flutter + Dart, Bloc/Cubit (`flutter_bloc`), Hive-backed `StorageRepository`, and Flutter Intl localization.

---

### Task 1: Persist new personalization flags in SettingsCubit

**Files:**
- Modify: `lib/settings/cubit/settings_state.dart`
- Modify: `lib/settings/cubit/settings_cubit.dart`
- Modify: `test/settings/cubit/settings_cubit_test.dart`

**Step 1:**
Add three booleans to `SettingsState` (`hideProcessPid`, `showExecutableFirst`, `limitWindowTitleToOneLine`), keep `pinSuspendedWindows` where it is, and ensure `initial()`/constructor callers zero them with `false`.

**Step 2:**
Load each value from storage during `SettingsCubit.init` (`getValue('hideProcessPid') ?? false`, etc.) and pass it into the initial state. Add setters `updateHideProcessPid`, `updateShowExecutableFirst`, `updateLimitWindowTitleToOneLine` that emit the new state and persist the boolean via `storage.saveValue`.

**Step 3:**
Extend `test/settings/cubit/settings_cubit_test.dart` to assert the defaults, to verify each new setter calls `storage.saveValue` with the right key/value pair, and to cover the code path where the stored value is `true`.

**Step 4:**
Run `flutter test test/settings/cubit/settings_cubit_test.dart` and expect the suite to pass.

**Step 5:**
Stage and commit the refreshed cubit: `git add lib/settings/cubit/settings_state.dart lib/settings/cubit/settings_cubit.dart test/settings/cubit/settings_cubit_test.dart` followed by `git commit -m "feat: persist personalization flags"`.

### Task 2: Surface the toggles in a dedicated PersonalizationSection

**Files:**
- Create: `lib/settings/widgets/personalization_section.dart`
- Modify: `lib/settings/widgets/behaviour_section.dart`
- Modify: `lib/settings/widgets/widgets.dart`
- Modify: `lib/settings/settings_page.dart`
- Modify: `lib/localization/app_en.arb`, `lib/localization/app_de.arb`, `lib/localization/app_it.arb`, `lib/localization/app_zh.arb`
- Generated: `lib/localization/app_localizations_*.dart`

**Step 1:**
Move the existing `_PinSuspendedWindowsTile` out of `BehaviourSection` and into the new `PersonalizationSection`. Implement the section with `BlocBuilder<SettingsCubit>` and `SwitchListTile`s for hide PID, show exe first, limit title to one line, and pinning suspended windows, using new localization keys (`personalizationTitle`, `hidePidSetting`, `hidePidSettingDescription`, `exeFirstSetting`, etc.) along with the existing `pinSuspendedWindows` strings.

**Step 2:**
Update `behaviour_section.dart` to drop `_PinSuspendedWindowsTile`. Add `const PersonalizationSection()` (plus spacing) to `settings_page.dart` between `BehaviourSection` and `ThemeSection`. Export the new widget via `widgets.dart`.

**Step 3:**
Add localized strings into each `.arb` file for the new section title/labels/descriptions. Keep the German/Italian/Chinese translations simple but accurate, and do not forget the `@<key>` metadata objects where required.

**Step 4:**
Run `flutter gen-l10n` to regenerate `lib/localization/app_localizations_*.dart`.

**Step 5:**
Create `test/settings/widgets/personalization_section_test.dart` that injects a mock `SettingsCubit`, renders the section, verifies each `SwitchListTile` renders the expected text, and toggles each one to ensure it calls the corresponding cubit method.

**Step 6:**
Run `flutter test test/settings/widgets/personalization_section_test.dart`, then stage and commit the new section/localization/test: `git add lib/settings/widgets/{behaviour_section.dart,widgets.dart,personalization_section.dart} lib/localization/app_*.arb lib/localization/app_localizations_*.dart test/settings/widgets/personalization_section_test.dart` + `git commit -m "feat: add personalization settings section"`.

### Task 3: Make `WindowTile` obey personalization preferences

**Files:**
- Modify: `lib/apps_list/widgets/window_tile.dart`
- Modify: `test/apps_list/widgets/window_tile_test.dart`

**Step 1:**
Import `SettingsCubit`/`SettingsState` so `_WindowTileState` can `context.select` the three new flags. Rework the `ListTile` so its `title` is a `Column` that optionally renders `widget.window.process.executable` at the top (when `showExecutableFirst`), and always renders the window title with `maxLines: 1` + `overflow: TextOverflow.ellipsis` if `limitWindowTitleToOneLine` is enabled. Keep the `subtitle` column but only include `Text('PID: ...')` when `hideProcessPid` is false, and include the executable name there when `showExecutableFirst` is false so the previous layout remains.

**Step 2:**
Adjust `test/apps_list/widgets/window_tile_test.dart` to mock `SettingsCubit.state` combinations and assert that each text appears or disappears as expected (PID line, exec line, ellipsis behavior) while preserving the existing "Suspend all instances" menu test.

**Step 3:**
Run `flutter test test/apps_list/widgets/window_tile_test.dart`.

**Step 4:**
Stage and commit the tile work: `git add lib/apps_list/widgets/window_tile.dart test/apps_list/widgets/window_tile_test.dart` + `git commit -m "feat: personalize window tiles"`.

### Task 4: Manual verification and visual regression checks

**Files:** (manual steps only)

**Step 1:**
Launch the app (e.g., `flutter run`/existing executable), open Settings, toggle each personalization switch, and confirm cards immediately reflect the choice (PID hides/shows, executable moves, title truncates, suspended windows stay pinned). Flip between at least two resolutions (1920x1080 and 1366x768) to ensure spacing stays acceptable.

**Step 2:**
Write down any discovered issues or follow-up fixes; if none arise, note the manual verification is complete.

**Step 3:**
If manual fixes were required, stage/commit them with an appropriate message. If nothing changed, mention the step was purely verification.

---

**Assumptions:** The user asked to work directly on `master` without creating a separate worktree, so this plan keeps all editing in the existing workspace.
