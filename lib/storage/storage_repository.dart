import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

/// Interfaces with the host OS to store & retrieve data from disk.
class StorageRepository {
  /// This class is a singleton.
  /// Singleton instance of the service.
  static late StorageRepository instance;

  /// Instance of Hive upon which to interface for storage.
  final HiveInterface _hive;

  /// Private singleton constructor.
  const StorageRepository._(this._hive);

  /// Initialize the storage access and [instance].
  /// Needs to be initialized only once, in the `main()` function.
  static Future<StorageRepository> initialize(HiveInterface hive) async {
    // Hive has a bug and initializes its storage for Flutter apps to an
    // incorrect directory on desktop platforms.Initialize to a specific
    // directory.
    final dir = await getApplicationSupportDirectory();
    // Defaults to ~/.local/share/nyrna/storage
    hive.init('${dir.path}/storage');
    instance = StorageRepository._(hive);
    return instance;
  }

  /// Save and close all storage to ensure clean exit.
  Future<void> close() async => await _hive.close();

  /// Delete [key] from storage.
  Future<void> deleteValue(String key, {String? storageArea}) async {
    final Box box = await _getBox(storageArea);
    await box.delete(key);
  }

  /// Get a value from local disk storage.
  ///
  /// If the [key] doesn't exist, [null] is returned.
  Future<dynamic> getValue(String key, {String? storageArea}) async {
    final Box box = await _getBox(storageArea);
    return box.get(key);
  }

  /// Get all values associated with [storageArea].
  Future<Iterable<dynamic>> getStorageAreaValues(String storageArea) async {
    final Box box = await _getBox(storageArea);
    return box.values;
  }

  /// Persist a value to local disk storage.
  ///
  /// [key] is the key to access the data.
  ///
  /// [value] is the data to be saved.
  ///
  /// [storageArea] is the name of a specific storage area in which to save.
  /// (Optional)
  Future<void> saveValue({
    required String key,
    required dynamic value,
    String? storageArea,
  }) async {
    final Box box = await _getBox(storageArea);
    await box.put(key, value);
  }

  /// Populate [storageArea] with [entries].
  Future<void> saveStorageAreaValues({
    required String storageArea,
    required Map<dynamic, dynamic> entries,
  }) async {
    final Box box = await _getBox(storageArea);
    await box.putAll(entries);
  }

  /// A generic storage pool, anything large should make its own box.
  static const String _kGeneralBoxName = 'general';

  /// Get a Hive storage box, either the one associated with
  /// [storageAreaName], or the general storage box.
  Future<Box> _getBox(String? storageAreaName) async {
    try {
      return await _hive.openBox(storageAreaName ?? _kGeneralBoxName);
    } on Exception catch (e) {
      debugPrint('Unable to access storage; is another app instance '
          'already running? Error: $e');
      exit(1);
    }
  }
}
