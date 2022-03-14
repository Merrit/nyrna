import 'package:hive/hive.dart';

/// Persists data for suspended windows, so we know which window
/// to resume the next time this is run.
class Storage {
  Future<int?> getInt(String key) async {
    final box = await Hive.openBox('saved');
    var value = box.get(key);
    if (value != null) value = value as int;
    return value;
  }

  Future<void> saveValue({
    required String key,
    required Object value,
  }) async {
    final box = await Hive.openBox('saved');
    await box.put(key, value);
  }

  /// Delete the saved information, so the next run will suspend.
  Future<void> deleteSaved() async => await Hive.deleteBoxFromDisk('saved');
}
