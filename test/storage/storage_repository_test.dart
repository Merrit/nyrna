import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nyrna/storage/storage_repository.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

/// A fake [PathProviderPlatform] that redirects getApplicationSupportPath() to
/// a caller-supplied temp directory so Hive is initialised in isolation.
class _FakePathProvider extends PathProviderPlatform {
  _FakePathProvider(this._supportPath);
  final String _supportPath;

  @override
  Future<String?> getApplicationSupportPath() async => _supportPath;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('nyrna_storage_test_');
    PathProviderPlatform.instance = _FakePathProvider(tempDir.path);
    await StorageRepository.initialize(Hive);
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('StorageRepository - initialize():', () {
    test('initialize() sets the singleton instance', () {
      expect(StorageRepository.instance, isNotNull);
    });
  });

  group('StorageRepository - saveValue() / getValue():', () {
    test('round-trips a String value', () async {
      await StorageRepository.instance.saveValue(key: 'strKey', value: 'hello');
      final result = await StorageRepository.instance.getValue('strKey');
      expect(result, 'hello');
    });

    test('round-trips an int value', () async {
      await StorageRepository.instance.saveValue(key: 'intKey', value: 42);
      final result = await StorageRepository.instance.getValue('intKey');
      expect(result, 42);
    });

    test('round-trips a bool value', () async {
      await StorageRepository.instance.saveValue(key: 'boolKey', value: true);
      final result = await StorageRepository.instance.getValue('boolKey');
      expect(result, true);
    });

    test('round-trips a List value', () async {
      await StorageRepository.instance.saveValue(key: 'listKey', value: [1, 2, 3]);
      final result = await StorageRepository.instance.getValue('listKey');
      expect(result, [1, 2, 3]);
    });

    test('returns null for a key that does not exist', () async {
      final result = await StorageRepository.instance.getValue('nonExistentKey');
      expect(result, isNull);
    });

    test('uses a named storageArea when provided', () async {
      await StorageRepository.instance.saveValue(
        key: 'areaKey',
        value: 'areaValue',
        storageArea: 'myArea',
      );
      final result = await StorageRepository.instance.getValue(
        'areaKey',
        storageArea: 'myArea',
      );
      expect(result, 'areaValue');
    });
  });

  group('StorageRepository - deleteValue():', () {
    test('deletes a value so it is no longer retrievable', () async {
      await StorageRepository.instance.saveValue(key: 'toDelete', value: 'gone');
      await StorageRepository.instance.deleteValue('toDelete');
      final result = await StorageRepository.instance.getValue('toDelete');
      expect(result, isNull);
    });
  });

  group('StorageRepository - getStorageAreaValues():', () {
    test('returns all values in a named storage area', () async {
      await StorageRepository.instance.saveValue(
        key: 'k1',
        value: 'v1',
        storageArea: 'areaX',
      );
      await StorageRepository.instance.saveValue(
        key: 'k2',
        value: 'v2',
        storageArea: 'areaX',
      );

      final values = await StorageRepository.instance.getStorageAreaValues('areaX');
      expect(values, containsAll(['v1', 'v2']));
    });
  });

  group('StorageRepository - saveStorageAreaValues():', () {
    test('bulk-saves entries to a named storage area', () async {
      await StorageRepository.instance.saveStorageAreaValues(
        storageArea: 'bulk',
        entries: {'bk1': 10, 'bk2': 20},
      );

      final v1 = await StorageRepository.instance.getValue('bk1', storageArea: 'bulk');
      final v2 = await StorageRepository.instance.getValue('bk2', storageArea: 'bulk');
      expect(v1, 10);
      expect(v2, 20);
    });
  });
}
