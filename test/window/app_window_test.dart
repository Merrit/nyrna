import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nyrna/logs/logs.dart';
import 'package:nyrna/storage/storage_repository.dart';
import 'package:nyrna/window/app_window.dart';

@GenerateNiceMocks(<MockSpec>[MockSpec<StorageRepository>()])
import 'app_window_test.mocks.dart';

final mockStorageRepo = MockStorageRepository();

/// A fake window info map returned by the flutter/windowsize channel.
///
/// Frame is [left, top, width, height].
final Map<String, Object?> _fakeWindowInfo = {
  'frame': [10.0, 20.0, 800.0, 600.0],
  'scaleFactor': 1.0,
  'screen': {
    'frame': [0.0, 0.0, 1920.0, 1080.0],
    'visibleFrame': [0.0, 0.0, 1920.0, 1060.0],
    'scaleFactor': 1.0,
  },
};

/// A fake screen list returned by the flutter/windowsize channel.
final List<Map<String, Object?>> _fakeScreenList = [
  {
    'frame': [0.0, 0.0, 1920.0, 1080.0],
    'visibleFrame': [0.0, 0.0, 1920.0, 1060.0],
    'scaleFactor': 1.0,
  },
];

/// The expected screen configuration ID for the fake single-monitor setup.
///
/// Computed from: left(0.0) + top(0.0) + width(1920.0) + height(1080.0) + scaleFactor(1.0)
const String _expectedScreenConfigId = '0.00.01920.01080.01.0';

/// Fake display JSON for the screen_retriever channel.
const Map<String, dynamic> _fakeDisplayJson = {
  'id': '1',
  'name': 'Test Monitor',
  'size': {'width': 1920.0, 'height': 1080.0},
  'visiblePosition': {'dx': 0.0, 'dy': 0.0},
  'visibleSize': {'width': 1920.0, 'height': 1040.0},
  'scaleFactor': 1.0,
};

/// Registers fake handlers for all platform channels used by [AppWindow].
///
/// The optional [onSetWindowFrame] callback receives the frame arguments
/// passed to `window_size.setWindowFrame` so individual tests can assert on
/// which dimensions were applied.
void _setupChannelMocks({
  void Function(List<double> frame)? onSetWindowFrame,
}) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('flutter/windowsize'),
        (MethodCall call) async {
          switch (call.method) {
            case 'getWindowInfo':
              return _fakeWindowInfo;
            case 'getScreenList':
              return _fakeScreenList;
            case 'setWindowFrame':
              onSetWindowFrame?.call((call.arguments as List).cast<double>());
              return null;
            default:
              return null;
          }
        },
      );

  // window_manager channel: provide getBounds response so center() works.
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('window_manager'),
        (MethodCall call) async {
          if (call.method == 'getBounds') {
            return {'x': 0.0, 'y': 0.0, 'width': 530.0, 'height': 600.0};
          }
          return null;
        },
      );

  // screen_retriever channel: provide display info so center() works.
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('dev.leanflutter.plugins/screen_retriever'),
        (MethodCall call) async {
          switch (call.method) {
            case 'getPrimaryDisplay':
              return _fakeDisplayJson;
            case 'getAllDisplays':
              return {
                'displays': [_fakeDisplayJson],
              };
            case 'getCursorScreenPoint':
              return {'dx': 960.0, 'dy': 540.0};
            default:
              return null;
          }
        },
      );
}

void _clearChannelMocks() {
  for (final channel in [
    'flutter/windowsize',
    'window_manager',
    'dev.leanflutter.plugins/screen_retriever',
  ]) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(MethodChannel(channel), null);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await LoggingManager.initialize(verbose: false);
  });

  setUp(() {
    reset(mockStorageRepo);
    _setupChannelMocks();
  });

  tearDown(() {
    _clearChannelMocks();
  });

  group('AppWindow:', () {
    group('saveWindowSizeAndPosition:', () {
      test('calls storage.saveValue with correct storageArea and key', () async {
        final appWindow = AppWindow(mockStorageRepo);

        await appWindow.saveWindowSizeAndPosition();

        verify(
          mockStorageRepo.saveValue(
            storageArea: 'windowSizeAndPosition',
            key: _expectedScreenConfigId,
            value: anyNamed('value'),
          ),
        ).called(1);
      });

      test('saves JSON-encoded Rect matching current window frame', () async {
        final appWindow = AppWindow(mockStorageRepo);
        String? savedValue;

        when(
          mockStorageRepo.saveValue(
            storageArea: anyNamed('storageArea'),
            key: anyNamed('key'),
            value: anyNamed('value'),
          ),
        ).thenAnswer((invocation) async {
          savedValue = invocation.namedArguments[const Symbol('value')];
        });

        await appWindow.saveWindowSizeAndPosition();

        expect(savedValue, isNotNull);
        final map = json.decode(savedValue!) as Map<String, dynamic>;
        expect(map['left'], 10.0);
        expect(map['top'], 20.0);
        expect(map['width'], 800.0);
        expect(map['height'], 600.0);
      });
    });

    group('setWindowSizeAndPosition:', () {
      test('reads saved rect from storage and does not call saveValue', () async {
        const savedJson = '{"left":100.0,"top":200.0,"width":530.0,"height":600.0}';
        when(
          mockStorageRepo.getValue(
            _expectedScreenConfigId,
            storageArea: 'windowSizeAndPosition',
          ),
        ).thenAnswer((_) async => savedJson);

        final appWindow = AppWindow(mockStorageRepo);
        await appWindow.setWindowSizeAndPosition();

        verify(
          mockStorageRepo.getValue(
            _expectedScreenConfigId,
            storageArea: 'windowSizeAndPosition',
          ),
        ).called(1);
        verifyNever(
          mockStorageRepo.saveValue(
            key: anyNamed('key'),
            value: anyNamed('value'),
          ),
        );
      });

      test('when no saved rect, uses default 530x600 size', () async {
        // Return null to simulate first run.
        when(
          mockStorageRepo.getValue(any, storageArea: anyNamed('storageArea')),
        ).thenAnswer((_) async => null);

        // Track which frame was set via the channel.
        List<double>? setFrame;
        _setupChannelMocks(
          onSetWindowFrame: (frame) => setFrame = frame,
        );

        final appWindow = AppWindow(mockStorageRepo);
        await appWindow.setWindowSizeAndPosition();

        expect(setFrame, isNotNull);
        // Default width is 530, height is 600.
        expect(setFrame![2], 530.0);
        expect(setFrame![3], 600.0);
      });
    });

    group('reset:', () {
      test('deletes saved value from windowSizeAndPosition storageArea', () async {
        // Stub getValue to return a saved rect so setWindowSizeAndPosition
        // does NOT call center() (which requires additional platform setup).
        const savedJson = '{"left":100.0,"top":200.0,"width":530.0,"height":600.0}';
        when(
          mockStorageRepo.getValue(any, storageArea: anyNamed('storageArea')),
        ).thenAnswer((_) async => savedJson);

        final appWindow = AppWindow(mockStorageRepo);
        await appWindow.reset();

        verify(
          mockStorageRepo.deleteValue(
            _expectedScreenConfigId,
            storageArea: 'windowSizeAndPosition',
          ),
        ).called(1);
      });

      test('then calls setWindowSizeAndPosition (reads storage)', () async {
        const savedJson = '{"left":100.0,"top":200.0,"width":530.0,"height":600.0}';
        when(
          mockStorageRepo.getValue(any, storageArea: anyNamed('storageArea')),
        ).thenAnswer((_) async => savedJson);

        final appWindow = AppWindow(mockStorageRepo);
        await appWindow.reset();

        verify(
          mockStorageRepo.getValue(
            _expectedScreenConfigId,
            storageArea: 'windowSizeAndPosition',
          ),
        ).called(1);
      });
    });
  });
}
