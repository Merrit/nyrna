import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nyrna/storage/storage_repository.dart';
import 'package:nyrna/theme/theme.dart';

@GenerateNiceMocks(<MockSpec>[
  MockSpec<StorageRepository>(),
])
import 'theme_cubit_test.mocks.dart';

final mockStorageRepo = MockStorageRepository();

late ThemeCubit cubit;
ThemeState get state => cubit.state;

void main() {
  group('ThemeCubit:', () {
    setUp(() async {
      reset(mockStorageRepo);

      when(mockStorageRepo.getValue(any)).thenAnswer((_) async {});
      when(mockStorageRepo.saveValue(
        key: anyNamed('key'),
        value: anyNamed('value'),
        storageArea: anyNamed('storageArea'),
      )).thenAnswer((_) async {});

      cubit = await ThemeCubit.init(mockStorageRepo);
    });

    test('global instance is available', () {
      expect(themeCubit, isA<ThemeCubit>());
    });

    test('default theme is dark', () {
      expect(state.appTheme, AppTheme.dark);
    });

    test('saved light theme preference loads light theme', () async {
      when(mockStorageRepo.getValue('appTheme'))
          .thenAnswer((_) async => 'AppTheme.light');
      cubit = await ThemeCubit.init(mockStorageRepo);
      expect(state.appTheme, AppTheme.light);
    });

    test('saved dark theme preference loads dark theme', () async {
      when(mockStorageRepo.getValue('appTheme')).thenAnswer((_) async => 'AppTheme.dark');
      cubit = await ThemeCubit.init(mockStorageRepo);
      expect(state.appTheme, AppTheme.dark);
    });

    test('saved pitch black theme preference loads pitch black theme', () async {
      when(mockStorageRepo.getValue('appTheme'))
          .thenAnswer((_) async => 'AppTheme.pitchBlack');
      cubit = await ThemeCubit.init(mockStorageRepo);
      expect(state.appTheme, AppTheme.pitchBlack);
    });

    test('changing theme works', () async {
      // Default
      expect(state.appTheme, AppTheme.dark);
      // Light
      await cubit.changeTheme(AppTheme.light);
      expect(state.appTheme, AppTheme.light);
      verify(mockStorageRepo.saveValue(
        key: 'appTheme',
        value: 'AppTheme.light',
      )).called(1);
      // Dark
      await cubit.changeTheme(AppTheme.dark);
      expect(state.appTheme, AppTheme.dark);
      verify(mockStorageRepo.saveValue(
        key: 'appTheme',
        value: 'AppTheme.dark',
      )).called(1);
      // Pitch Black
      await cubit.changeTheme(AppTheme.pitchBlack);
      expect(state.appTheme, AppTheme.pitchBlack);
      verify(mockStorageRepo.saveValue(
        key: 'appTheme',
        value: 'AppTheme.pitchBlack',
      )).called(1);
    });
  });
}
