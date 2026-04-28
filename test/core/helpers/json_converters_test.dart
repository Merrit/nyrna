import 'dart:ui';

import 'package:nyrna/core/helpers/json_converters.dart';
import 'package:test/test.dart';

void main() {
  group('RectConverter:', () {
    test('round-trip with typical values', () {
      const rect = Rect.fromLTWH(10.0, 20.0, 300.0, 400.0);
      final json = rect.toJson();
      final result = RectConverter.fromJson(json);
      expect(result.left, rect.left);
      expect(result.top, rect.top);
      expect(result.width, rect.width);
      expect(result.height, rect.height);
    });

    test('round-trip with zero values', () {
      const rect = Rect.fromLTWH(0.0, 0.0, 0.0, 0.0);
      final json = rect.toJson();
      final result = RectConverter.fromJson(json);
      expect(result.left, 0.0);
      expect(result.top, 0.0);
      expect(result.width, 0.0);
      expect(result.height, 0.0);
    });

    test('round-trip with negative coordinates', () {
      const rect = Rect.fromLTWH(-100.0, -200.0, 800.0, 600.0);
      final json = rect.toJson();
      final result = RectConverter.fromJson(json);
      expect(result.left, -100.0);
      expect(result.top, -200.0);
      expect(result.width, 800.0);
      expect(result.height, 600.0);
    });

    test('round-trip with large values', () {
      const rect = Rect.fromLTWH(9999.0, 8888.0, 7777.0, 6666.0);
      final json = rect.toJson();
      final result = RectConverter.fromJson(json);
      expect(result.left, 9999.0);
      expect(result.top, 8888.0);
      expect(result.width, 7777.0);
      expect(result.height, 6666.0);
    });

    test('malformed JSON throws', () {
      expect(() => RectConverter.fromJson('not valid json'), throwsA(anything));
    });
  });
}
