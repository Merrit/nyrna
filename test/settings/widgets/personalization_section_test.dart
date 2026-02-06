import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nyrna/localization/app_localizations.dart';
import 'package:nyrna/settings/settings.dart';

class MockSettingsCubit extends Mock implements SettingsCubit {}

final mockSettingsCubit = MockSettingsCubit();

void main() {
  setUp(() {
    reset(mockSettingsCubit);
    when(mockSettingsCubit.state).thenReturn(SettingsState.initial());
    when(mockSettingsCubit.updateHideProcessPid(true)).thenAnswer((_) async {});
    when(mockSettingsCubit.updateHideProcessPid(false)).thenAnswer((_) async {});
    when(mockSettingsCubit.updateShowExecutableFirst(true)).thenAnswer((_) async {});
    when(mockSettingsCubit.updateShowExecutableFirst(false)).thenAnswer((_) async {});
    when(mockSettingsCubit.updateLimitWindowTitleToOneLine(true)).thenAnswer(
      (_) async {},
    );
    when(mockSettingsCubit.updateLimitWindowTitleToOneLine(false)).thenAnswer(
      (_) async {},
    );
    when(mockSettingsCubit.updatePinSuspendedWindows(true)).thenAnswer(
      (_) async {},
    );
    when(mockSettingsCubit.updatePinSuspendedWindows(false)).thenAnswer(
      (_) async {},
    );
    when(mockSettingsCubit.updateCompactCards(true)).thenAnswer((_) async {});
    when(mockSettingsCubit.updateCompactCards(false)).thenAnswer((_) async {});
  });

  testWidgets('renders personalization tiles and toggles for each setting', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: BlocProvider.value(
            value: mockSettingsCubit,
            child: const PersonalizationSection(),
          ),
        ),
      ),
    );

    expect(find.text('Hide PID'), findsOneWidget);
    expect(find.text('Executable at top'), findsOneWidget);
    expect(find.text('Limit title to one line'), findsOneWidget);
    expect(find.text('Compact mode'), findsOneWidget);
    expect(find.text('Pin suspended windows'), findsOneWidget);

    await tester.tap(find.widgetWithText(SwitchListTile, 'Hide PID'));
    await tester.pumpAndSettle();
    verify(mockSettingsCubit.updateHideProcessPid(true)).called(1);

    await tester.tap(find.widgetWithText(SwitchListTile, 'Executable at top'));
    await tester.pumpAndSettle();
    verify(mockSettingsCubit.updateShowExecutableFirst(true)).called(1);

    await tester.tap(find.widgetWithText(SwitchListTile, 'Limit title to one line'));
    await tester.pumpAndSettle();
    verify(mockSettingsCubit.updateLimitWindowTitleToOneLine(true)).called(1);

    await tester.tap(find.widgetWithText(SwitchListTile, 'Pin suspended windows'));
    await tester.pumpAndSettle();
    verify(mockSettingsCubit.updatePinSuspendedWindows(true)).called(1);

    await tester.tap(find.widgetWithText(SwitchListTile, 'Compact mode'));
    await tester.pumpAndSettle();
    verify(mockSettingsCubit.updateCompactCards(true)).called(1);
  });
}
