import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:nyrna/hotkey/global/hotkey_service.dart';
import 'package:nyrna/logs/logs.dart';

// Note: addHotkey() and removeHotkey() delegate to the global `hotKeyManager`
// singleton which uses a MethodChannel (dev.leanflutter.plugins/hotkey_manager)
// and an EventChannel (dev.leanflutter.plugins/hotkey_manager_event) to
// communicate with the native side. Both channels are mocked below so tests
// run without a real window system.

const _methodChannel = MethodChannel('dev.leanflutter.plugins/hotkey_manager');
const _eventChannel = EventChannel('dev.leanflutter.plugins/hotkey_manager_event');

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await LoggingManager.initialize(verbose: false);

    // Stub the native MethodChannel so register/unregister calls succeed.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_methodChannel, (call) async => null);

    // Stub the EventChannel so hotKeyManager's constructor doesn't fail when
    // it subscribes to the onKeyEventReceiver stream.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockStreamHandler(
          _eventChannel,
          MockStreamHandler.inline(onListen: (args, sink) {}),
        );
  });

  setUp(() async {
    // Clear any hotkeys registered by previous tests.
    await hotKeyManager.unregisterAll();
  });

  group('HotkeyService:', () {
    test('hotkeyTriggeredStream is a broadcast stream', () {
      final service = HotkeyService();
      expect(service.hotkeyTriggeredStream.isBroadcast, isTrue);
    });

    test('hotkeyTriggeredStream can have multiple listeners without error', () {
      final service = HotkeyService();
      expect(
        () {
          service.hotkeyTriggeredStream.listen((_) {});
          service.hotkeyTriggeredStream.listen((_) {});
        },
        returnsNormally,
      );
    });

    test('addHotkey() registers the hotkey with hotKeyManager', () async {
      final service = HotkeyService();
      final hotKey = HotKey(key: PhysicalKeyboardKey.f12);

      await service.addHotkey(hotKey);

      expect(hotKeyManager.registeredHotKeyList, contains(hotKey));
    });

    test('addHotkey() does not double-register the same hotkey', () async {
      final service = HotkeyService();
      final hotKey = HotKey(key: PhysicalKeyboardKey.f11);

      await service.addHotkey(hotKey);
      final countAfterFirst = hotKeyManager.registeredHotKeyList.length;

      // Calling addHotkey a second time with the same instance should be a
      // no-op because the key is already in registeredHotKeyList.
      await service.addHotkey(hotKey);
      final countAfterSecond = hotKeyManager.registeredHotKeyList.length;

      expect(countAfterSecond, equals(countAfterFirst));
    });

    test('removeHotkey() unregisters the hotkey from hotKeyManager', () async {
      final service = HotkeyService();
      final hotKey = HotKey(key: PhysicalKeyboardKey.f10);

      await service.addHotkey(hotKey);
      expect(hotKeyManager.registeredHotKeyList, contains(hotKey));

      await service.removeHotkey(hotKey);
      expect(hotKeyManager.registeredHotKeyList, isNot(contains(hotKey)));
    });
  });
}
