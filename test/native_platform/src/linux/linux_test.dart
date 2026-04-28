import 'dart:async';
import 'dart:io';

import 'package:kwin/kwin.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nyrna/logs/logs.dart';
import 'package:nyrna/native_platform/native_platform.dart';
import 'package:nyrna/native_platform/src/linux/active_window/active_window_wayland.dart';
import 'package:nyrna/native_platform/src/linux/dbus/nyrna_dbus.dart';
import 'package:nyrna/native_platform/src/linux/linux.dart';
import 'package:nyrna/native_platform/src/typedefs.dart';
import 'package:test/test.dart';

@GenerateNiceMocks(<MockSpec>[
  MockSpec<KWin>(),
  MockSpec<NyrnaDbus>(),
])
import 'linux_test.mocks.dart';

var mockKWin = MockKWin();
var mockNyrnaDbus = MockNyrnaDbus();

late RunFunction mockRun;

final stubSuccessfulProcessResult = ProcessResult(0, 0, '', '');
final stubFailureProcessResult = ProcessResult(0, 1, '', 'error');

void main() {
  if (Platform.operatingSystem != 'linux') {
    return;
  }

  setUpAll(() async {
    await LoggingManager.initialize(verbose: false);
  });

  setUp(() {
    mockRun = (String executable, List<String> args) async {
      return ProcessResult(1, 1, '', '');
    };

    reset(mockKWin);
    reset(mockNyrnaDbus);
  });

  group('Linux:', () {
    group('currentDesktop:', () {
      test('returns correct virtual desktop', () async {
        mockRun = ((executable, args) async {
          const wmctrlReturnValue = '''
0  - DG: 8948x2873  VP: N/A  WA: 0,0 8948x2420  Workspace 1
1  * DG: 8948x2873  VP: 0,0  WA: 0,0 8948x2420  Workspace 2''';
          return ProcessResult(982333, 0, wmctrlReturnValue, '');
        });
        Linux linux = await Linux.initialize(mockRun);
        int desktop = await linux.currentDesktop();
        expect(desktop, 1);

        mockRun = ((executable, args) async {
          const wmctrlReturnValue = '''
0  * DG: 8948x2873  VP: N/A  WA: 0,0 8948x2420  Workspace 1
1  - DG: 8948x2873  VP: 0,0  WA: 0,0 8948x2420  Workspace 2''';
          return ProcessResult(982333, 0, wmctrlReturnValue, '');
        });
        linux = await Linux.initialize(mockRun);
        desktop = await linux.currentDesktop();
        expect(desktop, 0);
      });
    });

    test('windows() returns appropriate list of Window objects on x11', () async {
      if (Platform.environment['XDG_SESSION_TYPE'] != 'x11') {
        return;
      }

      // Mock the run function to return the expected wmctrl output for x11.
      mockRun = ((executable, args) async {
        const wmctrlReturnValue = '''
0x0640003e  0 8062   shodan Muesli - Wikipedia — Mozilla Firefox
0x05800003  1 69029  shodan linux.dart - nyrna - Visual Studio Code
0x02800006 -1 140564 shodan Telegram (4)
0x02e0002a  0 157040 shodan Downloads
0x058000f0  1 69029  shodan dartpad.dart - dartpad - Visual Studio Code
''';

        if (executable == 'readlink') {
          String returnValue;
          switch (args.first) {
            case '/proc/8062/exe':
              returnValue = 'firefox-bin';
              break;
            case '/proc/140564/exe':
              returnValue = 'Telegram';
              break;
            case '/proc/157040/exe':
              returnValue = 'nautilus';
              break;
            default:
              returnValue = '';
          }
          return ProcessResult(0, 0, returnValue, '');
        }

        return ProcessResult(982333, 0, wmctrlReturnValue, '');
      });

      final linux = await Linux.initialize(mockRun);
      final windows = await linux.windows();

      final expected = [
        const Window(
          id: '104857662',
          process: Process(
            executable: 'firefox-bin',
            pid: 8062,
            status: ProcessStatus.unknown,
          ),
          title: 'Muesli - Wikipedia — Mozilla Firefox',
        ),
        const Window(
          id: '41943046',
          process: Process(
            executable: 'Telegram',
            pid: 140564,
            status: ProcessStatus.unknown,
          ),
          title: 'Telegram (4)',
        ),
        const Window(
          id: '48234538',
          process: Process(
            executable: 'nautilus',
            pid: 157040,
            status: ProcessStatus.unknown,
          ),
          title: 'Downloads',
        ),
      ];
      expect(windows, expected);
    });

    test('windows() returns appropriate list of Window objects on wayland', () async {
      const kdeWaylandSession = SessionType(
        displayProtocol: DisplayProtocol.wayland,
        environment: DesktopEnvironment.kde,
      );

      const mockWindowJsonFromKdeWaylandScript =
          '[{"caption":"Wayland to X Recording bridge — Xwayland Video Bridge","pid":4962,"internalId":"{008b967c-58df-4128-ab4b-008acec9c4c8}","onCurrentDesktop":true},{"caption":"Muesli - Wikipedia — Mozilla Firefox","pid":7284,"internalId":"{b0c70d8b-07ae-4ee6-9d49-78a930adef3e}","onCurrentDesktop":true},{"caption":"Home — Dolphin","pid":627076,"internalId":"{d36459ad-bb52-44da-906e-990a393a9c8b}","onCurrentDesktop":true},{"caption":"doctor.cpp - libkscreen - Visual Studio Code","pid":945351,"internalId":"{efe8603d-5049-4451-8957-ed2e8eec5e04}","onCurrentDesktop":true},{"caption":"","pid":4419,"internalId":"{c892b0e3-ff47-4f77-b83c-5eef80104601}","onCurrentDesktop":true},{"caption":"QDBusViewer","pid":417686,"internalId":"{962a58dc-ee64-4223-b450-c2ba7861fc89}","onCurrentDesktop":false}]';

      when(mockNyrnaDbus.windowsJson).thenReturn(mockWindowJsonFromKdeWaylandScript);
      when(mockNyrnaDbus.activeWindowUpdates).thenAnswer((_) => const Stream.empty());

      mockRun = ((executable, args) async {
        String returnValue = '';
        if (executable == 'readlink') {
          switch (args.first) {
            case '/proc/4962/exe':
              returnValue = '/usr/bin/xwaylandvideobridge';
            case '/proc/7284/exe':
              returnValue = '/usr/lib64/firefox/firefox';
            case '/proc/627076/exe':
              returnValue = '/usr/bin/dolphin';
            case '/proc/945351/exe':
              returnValue = '/usr/share/code/code';
            case '/proc/4419/exe':
              returnValue = '/usr/bin/plasmashell';
            case '/proc/417686/exe':
              returnValue = '/usr/bin/qdbusviewer';
            default:
              returnValue = '';
          }
        }
        return ProcessResult(0, 0, returnValue, '');
      });

      final linux = await Linux.initialize(
        mockRun,
        kwin: mockKWin,
        nyrnaDbus: mockNyrnaDbus,
        sessionOverride: kdeWaylandSession,
      );
      final windows = await linux.windows();

      final expected = [
        const Window(
          id: '{b0c70d8b-07ae-4ee6-9d49-78a930adef3e}',
          process: Process(
            executable: 'firefox',
            pid: 7284,
            status: ProcessStatus.unknown,
          ),
          title: 'Muesli - Wikipedia — Mozilla Firefox',
        ),
        const Window(
          id: '{d36459ad-bb52-44da-906e-990a393a9c8b}',
          process: Process(
            executable: 'dolphin',
            pid: 627076,
            status: ProcessStatus.unknown,
          ),
          title: 'Home — Dolphin',
        ),
        const Window(
          id: '{efe8603d-5049-4451-8957-ed2e8eec5e04}',
          process: Process(
            executable: 'code',
            pid: 945351,
            status: ProcessStatus.unknown,
          ),
          title: 'doctor.cpp - libkscreen - Visual Studio Code',
        ),
      ];

      expect(windows, expected);
    });

    group('ActiveWindowWayland:', () {
      test('sets linux.activeWindow when a JSON update is received', () async {
        final controller = StreamController<String>.broadcast();
        when(mockNyrnaDbus.windowsJson).thenReturn('[]');
        when(mockNyrnaDbus.activeWindowUpdates).thenAnswer((_) => controller.stream);

        mockRun = (executable, args) async {
          if (executable == 'readlink' && args.first == '/proc/12345/exe') {
            return ProcessResult(0, 0, '/usr/bin/firefox\n', '');
          }
          return ProcessResult(0, 0, '', '');
        };

        const kdeWaylandSession = SessionType(
          displayProtocol: DisplayProtocol.wayland,
          environment: DesktopEnvironment.kde,
        );

        final linux = await Linux.initialize(
          mockRun,
          kwin: mockKWin,
          nyrnaDbus: mockNyrnaDbus,
          sessionOverride: kdeWaylandSession,
        );

        const windowJson =
            '{"caption":"Muesli - Wikipedia — Mozilla Firefox",'
            '"pid":12345,"internalId":"{b0c70d8b-07ae}"}';
        controller.add(windowJson);

        // Allow the async listener callback to complete.
        await Future.delayed(Duration.zero);

        expect(linux.activeWindow, isNotNull);
        expect(linux.activeWindow!.id, '{b0c70d8b-07ae}');
        expect(
          linux.activeWindow!.title,
          'Muesli - Wikipedia — Mozilla Firefox',
        );
        expect(linux.activeWindow!.process.executable, 'firefox');
        expect(linux.activeWindow!.process.pid, 12345);

        await controller.close();
        await ActiveWindowWayland.dispose();
      });
    });

    group('minimize/restore on KDE Wayland:', () {
      const kdeWaylandSession = SessionType(
        displayProtocol: DisplayProtocol.wayland,
        environment: DesktopEnvironment.kde,
      );

      setUp(() {
        when(mockNyrnaDbus.windowsJson).thenReturn('[]');
        when(mockNyrnaDbus.activeWindowUpdates).thenAnswer((_) => const Stream.empty());
      });

      Future<Linux> buildLinux() => Linux.initialize(
        mockRun,
        kwin: mockKWin,
        nyrnaDbus: mockNyrnaDbus,
        sessionOverride: kdeWaylandSession,
      );

      test(
        'minimizeWindow() calls kwin.loadScript() with correct script content',
        () async {
          final scriptCalls = <({String name, String content})>[];

          when(mockKWin.loadScript(any, any)).thenAnswer((invocation) async {
            final path = invocation.positionalArguments[0] as String;
            final name = invocation.positionalArguments[1] as String;
            final file = File(path);
            final content = file.existsSync() ? await file.readAsString() : '';
            scriptCalls.add((name: name, content: content));
          });

          final linux = await buildLinux();

          // Clear calls made during initialize() (script loading).
          scriptCalls.clear();

          const windowId = '{b0c70d8b-07ae-4ee6-9d49-78a930adef3e}';
          await linux.minimizeWindow(windowId);

          expect(scriptCalls, hasLength(1));
          expect(scriptCalls.first.name, 'nyrna_minimize');

          final expectedContent = Linux.kwinMinimizeRestoreScript
              .replaceAll('%windowId%', windowId)
              .replaceAll('%minimize%', 'true');
          expect(scriptCalls.first.content, expectedContent);
        },
      );

      test(
        'restoreWindow() calls kwin.loadScript() with correct script content',
        () async {
          final scriptCalls = <({String name, String content})>[];

          when(mockKWin.loadScript(any, any)).thenAnswer((invocation) async {
            final path = invocation.positionalArguments[0] as String;
            final name = invocation.positionalArguments[1] as String;
            final file = File(path);
            final content = file.existsSync() ? await file.readAsString() : '';
            scriptCalls.add((name: name, content: content));
          });

          final linux = await buildLinux();

          // Clear calls made during initialize() (script loading).
          scriptCalls.clear();

          const windowId = '{b0c70d8b-07ae-4ee6-9d49-78a930adef3e}';
          await linux.restoreWindow(windowId);

          expect(scriptCalls, hasLength(1));
          expect(scriptCalls.first.name, 'nyrna_restore');

          final expectedContent = Linux.kwinMinimizeRestoreScript
              .replaceAll('%windowId%', windowId)
              .replaceAll('%minimize%', 'false');
          expect(scriptCalls.first.content, expectedContent);
        },
      );
    });

    group('checkDependencies:', () {
      const x11Session = SessionType(
        displayProtocol: DisplayProtocol.x11,
        environment: DesktopEnvironment.kde,
      );

      test('always returns true on KDE Wayland (no binary deps needed)', () async {
        const kdeWaylandSession = SessionType(
          displayProtocol: DisplayProtocol.wayland,
          environment: DesktopEnvironment.kde,
        );

        when(mockNyrnaDbus.windowsJson).thenReturn('[]');
        when(
          mockNyrnaDbus.activeWindowUpdates,
        ).thenAnswer((_) => const Stream.empty());

        // Even with a run function that always fails, KDE Wayland should
        // return true because it uses D-Bus scripting, not binary tools.
        mockRun = ((executable, args) async => stubFailureProcessResult);

        final linux = await Linux.initialize(
          mockRun,
          kwin: mockKWin,
          nyrnaDbus: mockNyrnaDbus,
          sessionOverride: kdeWaylandSession,
        );
        final result = await linux.checkDependencies();
        expect(result, isTrue);
      });

      test('finds dependencies when present', () async {
        mockRun = ((executable, args) async {
          return (args[1].contains('wmctrl') || args[1].contains('xdotool'))
              ? stubSuccessfulProcessResult
              : stubFailureProcessResult;
        });

        final linux = await Linux.initialize(mockRun, sessionOverride: x11Session);
        final haveDependencies = await linux.checkDependencies();
        expect(haveDependencies, true);
      });

      test('returns false if missing wmctrl', () async {
        mockRun = ((executable, args) async {
          return (args[1].contains('wmctrl'))
              ? stubSuccessfulProcessResult
              : stubFailureProcessResult;
        });

        final linux = await Linux.initialize(mockRun, sessionOverride: x11Session);
        final haveDependencies = await linux.checkDependencies();
        expect(haveDependencies, false);
      });

      test('returns false if missing xdotool', () async {
        mockRun = ((executable, args) async {
          return (args[1].contains('xdotool'))
              ? stubSuccessfulProcessResult
              : stubFailureProcessResult;
        });

        final linux = await Linux.initialize(mockRun, sessionOverride: x11Session);
        final haveDependencies = await linux.checkDependencies();
        expect(haveDependencies, false);
      });
    });
  });
}
