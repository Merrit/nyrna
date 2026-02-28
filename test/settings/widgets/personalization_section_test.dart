import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nyrna/autostart/autostart_service.dart';
import 'package:nyrna/hotkey/global/hotkey_service.dart';
import 'package:nyrna/localization/app_localizations.dart';
import 'package:nyrna/settings/settings.dart';
import 'package:nyrna/settings/widgets/personalization_section.dart';
import 'package:nyrna/storage/storage_repository.dart';

@GenerateNiceMocks(<MockSpec>[
  MockSpec<AutostartService>(),
  MockSpec<HotkeyService>(),
  MockSpec<StorageRepository>(),
])
import 'personalization_section_test.mocks.dart';

void main() {
  late SettingsCubit settingsCubit;
  late MockAutostartService autostartService;
  late MockHotkeyService hotkeyService;
  late MockStorageRepository storage;

  setUp(() async {
    autostartService = MockAutostartService();
    hotkeyService = MockHotkeyService();
    storage = MockStorageRepository();

    when(autostartService.enable()).thenAnswer((_) async {});
    when(autostartService.disable()).thenAnswer((_) async {});
    when(hotkeyService.addHotkey(any)).thenAnswer((_) async {});
    when(hotkeyService.removeHotkey(any)).thenAnswer((_) async {});
    when(storage.getValue(any)).thenAnswer((_) async => null);
    when(
      storage.saveValue(
        key: anyNamed('key'),
        value: anyNamed('value'),
      ),
    ).thenAnswer((_) async {});
    when(
      storage.getValue(any, storageArea: anyNamed('storageArea')),
    ).thenAnswer((_) async => null);
    when(
      storage.saveValue(
        key: anyNamed('key'),
        value: anyNamed('value'),
        storageArea: anyNamed('storageArea'),
      ),
    ).thenAnswer((_) async {});

    settingsCubit = await SettingsCubit.init(
      autostartService: autostartService,
      hotkeyService: hotkeyService,
      storage: storage,
    );
  });

  tearDown(() {
    settingsCubit.close();
  });

  testWidgets('renders 3 personalization tiles', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: BlocProvider.value(
            value: settingsCubit,
            child: const PersonalizationSection(),
          ),
        ),
      ),
    );

    expect(find.textContaining('Hide PID'), findsOneWidget);
    expect(find.textContaining('Executable at top'), findsOneWidget);
    expect(find.textContaining('Limit title to one line'), findsOneWidget);
  });
}
