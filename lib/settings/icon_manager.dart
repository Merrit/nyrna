import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as image;
import 'package:logging/logging.dart';

class IconManager {
  final _log = Logger('IconManager');

  Uint8List? _loadedIconBytes;

  Future<Uint8List> iconBytes() async {
    if (_loadedIconBytes != null) return Future.value(_loadedIconBytes);
    final byteData = await rootBundle.load('assets/icons/nyrna.png');
    final iconBytes = byteData.buffer.asUint8List();
    _loadedIconBytes = iconBytes;
    return iconBytes;
  }

  /// Re-launch the tray application so it shows the new icon.
  Future<void> _refreshTray() async {
    try {
      await Process.start('toggle_active_hotkey.exe', []);
    } on ProcessException {
      _log.warning('Unable to launch hotkey executable');
    }
  }

  Future<bool> updateIconColor(Color color) async {
    final _iconBytes = await iconBytes();
    final loadedImage = image.decodePng(_iconBytes);
    if (loadedImage == null) return false;
    var updatedImage = image.adjustColor(
      loadedImage,
      blacks: 0,
      whites: 0,
      mids: 0,
    );
    updatedImage = image.colorOffset(
      loadedImage,
      red: color.red,
      green: color.green,
      blue: color.blue,
    );
    final icoBytes = image.encodeIco(updatedImage);
    const assetPath = kDebugMode
        ? '\\assets\\icons'
        : '\\data\\flutter_assets\\assets\\icons';
    final icoDirectory = Directory.current.path + assetPath;
    final ico = File(icoDirectory + '\\nyrna.ico');
    try {
      await ico.writeAsBytes(icoBytes, flush: true);
    } catch (e) {
      _log.warning('Unable to write icon file: $e');
      return false;
    }
    await _refreshTray();
    return true;
  }
}
