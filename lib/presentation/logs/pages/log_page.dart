import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:nyrna/infrastructure/logger/log_file.dart';

/// Display Nyrna's logs.
class LogPage extends StatefulWidget {
  static final id = 'LogScreen';

  @override
  _LogPageState createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  /// The level of logs to show, changed with the DropdownButton.
  Level level = Level.INFO;

  String logsText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 30),
        child: Column(
          children: [
            Row(
              children: [
                const Text('Log level'),
                const SizedBox(width: 10),
                DropdownButton<Level>(
                  value: level,
                  onChanged: (Level? newLevel) {
                    setState(() => level = newLevel!);
                  },
                  items: const [
                    DropdownMenuItem(
                      value: Level.INFO,
                      child: Text('INFO'),
                    ),
                    DropdownMenuItem(
                      value: Level.WARNING,
                      child: Text('WARNING'),
                    ),
                    DropdownMenuItem(
                      value: Level.SEVERE,
                      child: Text('SEVERE'),
                    ),
                    DropdownMenuItem(
                      value: Level.ALL,
                      child: Text('ALL'),
                    ),
                  ],
                ),
                // Add spacing so the button is at the far right.
                Expanded(child: Container()),
                ElevatedButton(
                  onPressed: () async {
                    // Copy the visible logs to user's clipboard.
                    await Clipboard.setData(ClipboardData(text: logsText));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Logs copied to clipboard')),
                    );
                  },
                  child: Text('Copy'),
                ),
              ],
            ),
            Flexible(
              flex: 1,
              child: Container(
                color: Colors.grey[800],
                width: double.infinity,
                height: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                child: Scrollbar(
                  isAlwaysShown: true,
                  child: SingleChildScrollView(
                    child: _logText(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SelectableText _logText() {
    logsText = '';
    LogFile.logs.forEach(
      (LogRecord record) {
        // Add if the record's level matches the user's choice.
        if (record.level == level || level == Level.ALL) {
          logsText = logsText +
              '${record.time} \n'
                  '${record.level.name} \n'
                  'Logger: ${record.loggerName} \n'
                  '${record.message} \n'
                  '\n';
        }
      },
    );
    return SelectableText(logsText);
  }
}
