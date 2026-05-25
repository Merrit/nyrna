import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

/// Physical keys whose names are not available in release builds via
/// [PhysicalKeyboardKey.debugName] (which is assert-only in Flutter) and are
/// also absent from hotkey_manager's built-in label map.
final _extraPhysicalKeyLabels = <PhysicalKeyboardKey, String>{
  PhysicalKeyboardKey.pause: 'Pause',
  PhysicalKeyboardKey.insert: 'Insert',
  PhysicalKeyboardKey.printScreen: 'Print Screen',
  PhysicalKeyboardKey.scrollLock: 'Scroll Lock',
  PhysicalKeyboardKey.numLock: 'Num Lock',
  PhysicalKeyboardKey.numpadAdd: 'Num +',
  PhysicalKeyboardKey.numpadSubtract: 'Num -',
  PhysicalKeyboardKey.numpadMultiply: 'Num *',
  PhysicalKeyboardKey.numpadDivide: 'Num /',
  PhysicalKeyboardKey.numpadEnter: 'Num Enter',
  PhysicalKeyboardKey.numpadDecimal: 'Num .',
  PhysicalKeyboardKey.numpad0: 'Num 0',
  PhysicalKeyboardKey.numpad1: 'Num 1',
  PhysicalKeyboardKey.numpad2: 'Num 2',
  PhysicalKeyboardKey.numpad3: 'Num 3',
  PhysicalKeyboardKey.numpad4: 'Num 4',
  PhysicalKeyboardKey.numpad5: 'Num 5',
  PhysicalKeyboardKey.numpad6: 'Num 6',
  PhysicalKeyboardKey.numpad7: 'Num 7',
  PhysicalKeyboardKey.numpad8: 'Num 8',
  PhysicalKeyboardKey.numpad9: 'Num 9',
  PhysicalKeyboardKey.f13: 'F13',
  PhysicalKeyboardKey.f14: 'F14',
  PhysicalKeyboardKey.f15: 'F15',
  PhysicalKeyboardKey.f16: 'F16',
  PhysicalKeyboardKey.f17: 'F17',
  PhysicalKeyboardKey.f18: 'F18',
  PhysicalKeyboardKey.f19: 'F19',
  PhysicalKeyboardKey.f20: 'F20',
  PhysicalKeyboardKey.f21: 'F21',
  PhysicalKeyboardKey.f22: 'F22',
  PhysicalKeyboardKey.f23: 'F23',
  PhysicalKeyboardKey.f24: 'F24',
};

/// Human-readable labels for [HotKeyModifier] values.
///
/// [HotKeyModifier.physicalKeys] also relies on [PhysicalKeyboardKey.debugName]
/// indirectly, so we use a static map here instead.
const _modifierLabels = <HotKeyModifier, String>{
  HotKeyModifier.alt: 'Alt',
  HotKeyModifier.capsLock: '⇪',
  HotKeyModifier.control: 'Ctrl',
  HotKeyModifier.fn: 'fn',
  HotKeyModifier.meta: '⊞',
  HotKeyModifier.shift: 'Shift',
};

/// Returns a human-readable label for [hotKey] that is safe in release builds.
///
/// [HotKey.debugName] uses [PhysicalKeyboardKey.debugName] which is
/// assert-only and returns `null` outside of debug mode.
String hotkeyLabel(HotKey hotKey) {
  PhysicalKeyboardKey? physicalKey;
  if (hotKey.key is PhysicalKeyboardKey) {
    physicalKey = hotKey.key as PhysicalKeyboardKey;
  }

  // hotkey_manager's KeyboardKeyExt.keyLabel covers most standard keys but
  // also falls back to debugName for unknown ones, so we check our extended
  // map first.
  final keyName = (physicalKey != null ? _extraPhysicalKeyLabels[physicalKey] : null) ??
      hotKey.key.keyLabel;

  final modifierNames = (hotKey.modifiers ?? []).map((m) => _modifierLabels[m] ?? m.name);

  return [...modifierNames, keyName].join(' + ');
}
