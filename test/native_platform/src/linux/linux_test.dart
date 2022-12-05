import 'dart:io';

import 'package:nyrna/native_platform/native_platform.dart';
import 'package:nyrna/native_platform/src/linux/linux.dart';
import 'package:nyrna/native_platform/src/typedefs.dart';
import 'package:test/test.dart';

late RunFunction mockRun;

final stubSuccessfulProcessResult = ProcessResult(0, 0, '', '');

void main() {
  setUp(() {
    mockRun = (String executable, List<String> args) async {
      return ProcessResult(1, 1, '', '');
    };
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
        Linux linux = Linux(mockRun);
        int desktop = await linux.currentDesktop();
        expect(desktop, 1);

        mockRun = ((executable, args) async {
          const wmctrlReturnValue = '''
0  * DG: 8948x2873  VP: N/A  WA: 0,0 8948x2420  Workspace 1
1  - DG: 8948x2873  VP: 0,0  WA: 0,0 8948x2420  Workspace 2''';
          return ProcessResult(982333, 0, wmctrlReturnValue, '');
        });
        linux = Linux(mockRun);
        desktop = await linux.currentDesktop();
        expect(desktop, 0);
      });
    });

    test('windows() returns appropriate list of Window objects', () async {
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
      final linux = Linux(mockRun);
      final windows = await linux.windows();
      final expected = [
        Window(
          id: 104857662,
          process: const Process(
            executable: 'firefox-bin',
            pid: 8062,
            status: ProcessStatus.unknown,
          ),
          title: 'Muesli - Wikipedia — Mozilla Firefox',
        ),
        Window(
          id: 41943046,
          process: const Process(
            executable: 'Telegram',
            pid: 140564,
            status: ProcessStatus.unknown,
          ),
          title: 'Telegram (4)',
        ),
        Window(
          id: 48234538,
          process: const Process(
            executable: 'nautilus',
            pid: 157040,
            status: ProcessStatus.unknown,
          ),
          title: 'Downloads',
        ),
      ];
      expect(windows, expected);
    });

    group('checkDependencies:', () {
      test('finds dependencies when present', () async {
        mockRun = ((executable, args) async {
          if (executable == 'wmctrl' || executable == 'xdotool') {
            return stubSuccessfulProcessResult;
          } else {
            throw Exception('Command not found!');
          }
        });

        final linux = Linux(mockRun);
        final haveDependencies = await linux.checkDependencies();
        expect(haveDependencies, true);
      });

      test('returns false if missing wmctrl', () async {
        mockRun = ((executable, args) async {
          if (executable == 'xdotool') {
            return stubSuccessfulProcessResult;
          } else {
            throw Exception('Command not found!');
          }
        });

        final linux = Linux(mockRun);
        final haveDependencies = await linux.checkDependencies();
        expect(haveDependencies, false);
      });

      test('returns false if missing xdotool', () async {
        mockRun = ((executable, args) async {
          if (executable == 'wmctrl') {
            return stubSuccessfulProcessResult;
          } else {
            throw Exception('Command not found!');
          }
        });

        final linux = Linux(mockRun);
        final haveDependencies = await linux.checkDependencies();
        expect(haveDependencies, false);
      });
    });
  });
}
