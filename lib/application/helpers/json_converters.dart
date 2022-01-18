// ignore_for_file: unnecessary_this

import 'dart:convert';
import 'dart:ui';

/// Converts Rect objects to / from json easily.
///
/// Needed so they can be saved as a String to preferences.
extension RectConverter on Rect {
  static Rect fromJson(String json) {
    final rectMap = jsonDecode(json) as Map<String, dynamic>;
    return Rect.fromLTWH(
      rectMap['left'],
      rectMap['top'],
      rectMap['width'],
      rectMap['height'],
    );
  }

  String toJson() {
    final rectMap = <String, dynamic>{
      'left': this.left,
      'top': this.top,
      'width': this.width,
      'height': this.height,
    };
    return jsonEncode(rectMap);
  }
}
