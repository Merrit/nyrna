import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nyrna/storage/storage_repository.dart';
import 'package:nyrna/theme/theme.dart';

class MockStorageRepository extends Mock implements StorageRepository {}

StorageRepository storage = MockStorageRepository();

late ThemeCubit cubit;
ThemeState get state => cubit.state;

void main() {
  group('ThemeCubit:', () {
    setUp(() async {
      when(() => storage.getValue(any())).thenAnswer((_) async {});
      when(() => storage.saveValue(
            key: any(named: 'key'),
            value: any(named: 'value'),
            storageArea: any(named: 'storageArea'),
          )).thenAnswer((_) async {});

      cubit = await ThemeCubit.init(storage);
    });

    test('global instance is available', () {
      expect(themeCubit, isA<ThemeCubit>());
    });

    test('default theme is dark', () {
      expect(state.appTheme, AppTheme.dark);
    });

    test('saved light theme preference loads light theme', () async {
      when(() => storage.getValue('appTheme'))
          .thenAnswer((_) async => 'AppTheme.light');
      cubit = await ThemeCubit.init(storage);
      expect(state.appTheme, AppTheme.light);
    });

    test('saved dark theme preference loads dark theme', () async {
      when(() => storage.getValue('appTheme'))
          .thenAnswer((_) async => 'AppTheme.dark');
      cubit = await ThemeCubit.init(storage);
      expect(state.appTheme, AppTheme.dark);
    });

    test('saved pitch black theme preference loads pitch black theme',
        () async {
      when(() => storage.getValue('appTheme'))
          .thenAnswer((_) async => 'AppTheme.pitchBlack');
      cubit = await ThemeCubit.init(storage);
      expect(state.appTheme, AppTheme.pitchBlack);
    });

    test('changing theme works', () async {
      // Default
      expect(state.appTheme, AppTheme.dark);
      // Light
      await cubit.changeTheme(AppTheme.light);
      expect(state.appTheme, AppTheme.light);
      verify(() => storage.saveValue(
            key: 'appTheme',
            value: 'AppTheme.light',
          )).called(1);
      // Dark
      await cubit.changeTheme(AppTheme.dark);
      expect(state.appTheme, AppTheme.dark);
      verify(() => storage.saveValue(
            key: 'appTheme',
            value: 'AppTheme.dark',
          )).called(1);
      // Pitch Black
      await cubit.changeTheme(AppTheme.pitchBlack);
      expect(state.appTheme, AppTheme.pitchBlack);
      verify(() => storage.saveValue(
            key: 'appTheme',
            value: 'AppTheme.pitchBlack',
          )).called(1);
    });
  });
}
