import 'package:flutter/material.dart';
import 'package:nyrna/components/window_tile.dart';
import 'package:nyrna/nyrna.dart';
import 'package:nyrna/process.dart';
import 'package:nyrna/settings/screens/settings_screen.dart';
import 'package:nyrna/settings/settings.dart';
import 'package:provider/provider.dart';

class RunningAppsScreen extends StatefulWidget {
  static const id = 'running_apps_screen';

  @override
  _RunningAppsScreenState createState() => _RunningAppsScreenState();
}

class _RunningAppsScreenState extends State<RunningAppsScreen> {
  Nyrna nyrna;

  @override
  void didChangeDependencies() {
    nyrna = Provider.of<Nyrna>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<Nyrna>(
          builder: (context, nyrna, widget) {
            return Text('Current Desktop: ${nyrna.currentDesktop}');
          },
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, SettingsScreen.id),
          ),
        ],
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width / 1.20,
          child: ListView.builder(
            padding: EdgeInsets.only(top: 40),
            itemCount: nyrna.windows.length,
            itemBuilder: (context, index) {
              if (nyrna.windows.length == 0) return Container();
              var keys = nyrna.windows.keys.toList();
              var window = nyrna.windows[keys[index]];
              return ChangeNotifierProvider(
                key: UniqueKey(),
                create: (context) => Process(window.pid),
                child: WindowTile(
                  window: window,
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton:
          ((settings.autoRefresh && settings.refreshInterval > 10) ||
                  !settings.autoRefresh)
              ? _floatingActionButton()
              : null,
    );
  }

  FloatingActionButton _floatingActionButton() {
    return FloatingActionButton(
      child: Icon(Icons.refresh),
      onPressed: () => nyrna.fetchData(),
    );
  }
}
