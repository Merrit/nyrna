import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nyrna/localization/app_localizations.dart';
import 'package:nyrna/settings/settings.dart';
import 'package:nyrna/settings/widgets/personalization_section.dart';

class MockSettingsCubit extends Mock implements SettingsCubit {}

final mockSettingsCubit = MockSettingsCubit();

void main() {
  setUp(() {
    reset(mockSettingsCubit);
    when(mockSettingsCubit.state).thenReturn(SettingsState.initial());
    when(mockSettingsCubit.updateHideProcessPid(any)).thenAnswer((_) async {});
    when(mockSettingsCubit.updateShowExecutableFirst(any))
        .thenAnswer((_) async {});
    when(mockSettingsCubit.updateLimitWindowTitleToOneLine(any))
        .thenAnswer((_) async {});
    when(mockSettingsCubit.updatePinSuspendedWindows(any))
        .thenAnswer((_) async {});
  });

  testWidgets('renders personalization tiles and toggles for each setting',
      (tester) async {
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
  });
}
