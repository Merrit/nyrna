import 'dart:typed_data';

import 'package:flutter/services.dart';

class IconManager {
  Future<Uint8List> get iconUint8List async {
    final iconBytes = await rootBundle.load('assets/icons/nyrna.png');
    final iconAsUint8List = iconBytes.buffer.asUint8List();
    return iconAsUint8List;
  }

  // updateIcon({required int color}) {}
}
