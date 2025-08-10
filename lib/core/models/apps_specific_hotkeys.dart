import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

part 'apps_specific_hotkeys.freezed.dart';
part 'apps_specific_hotkeys.g.dart';

/// A hotkey that toggles the suspend state of a specific application.
@freezed
abstract class AppSpecificHotkey with _$AppSpecificHotkey {
  const factory AppSpecificHotkey({
    /// The executable name of the application.
    ///
    /// Example: `Telegram`, `firefox-bin`, `notepad.exe`, etc.
    required String executable,

    /// The chosen hotkey.
    required HotKey hotkey,
  }) = _AppSpecificHotkey;

  factory AppSpecificHotkey.fromJson(Map<String, dynamic> json) =>
      _$AppSpecificHotkeyFromJson(json);
}
