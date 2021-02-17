import 'dart:io' as DartIO;

import 'package:flutter/material.dart';
import 'package:nyrna/linux/linux_process.dart';
import 'package:nyrna/native_process.dart';

class Process extends ChangeNotifier {
  Process(this.pid) {
    _fetchProcess();
  }

  final int pid;
  NativeProcess _process;

  String get executable => _process.executable;

  String get status => _process.status;

  bool toggle() {
    bool successful = _process.toggle();
    notifyListeners();
    return successful;
  }

  void _fetchProcess() {
    switch (DartIO.Platform.operatingSystem) {
      case 'linux':
        _process = LinuxProcess(pid);
        break;
      default:
    }
  }
}
