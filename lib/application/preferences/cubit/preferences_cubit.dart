import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nyrna/application/app/app.dart';
import 'package:nyrna/infrastructure/launcher/launcher.dart';
import 'package:nyrna/infrastructure/preferences/preferences.dart';

part 'preferences_state.dart';

late PreferencesCubit preferencesCubit;

class PreferencesCubit extends Cubit<PreferencesState> {
  final Preferences _prefs;

  PreferencesCubit(Preferences prefs)
      : _prefs = prefs,
        super(
          PreferencesState(
            autoRefresh: prefs.getBool('autoRefresh') ?? (Platform.isWindows)
                ? false
                : true,
            refreshInterval: prefs.getInt('refreshInterval') ?? 5,
          ),
        ) {
    preferencesCubit = this;
  }

  Future<void> createLauncher() async {
    await Launcher.add();
  }

  /// If user wishes to ignore this update, save to SharedPreferences.
  Future<void> ignoreUpdate(String version) async {
    await _prefs.setString(key: 'ignoredUpdate', value: version);
  }

  Future<void> setRefreshInterval(int interval) async {
    if (interval > 0) {
      await _prefs.setInt(key: 'refreshInterval', value: interval);
      emit(state.copyWith(refreshInterval: interval));
    }
  }

  Future<void> updateAutoRefresh([bool? autoEnabled]) async {
    if (autoEnabled != null) {
      await _prefs.setBool(key: 'autoRefresh', value: autoEnabled);
      appCubit.setAutoRefresh(
        autoRefresh: autoEnabled,
        refreshInterval: state.refreshInterval,
      );
      emit(state.copyWith(autoRefresh: autoEnabled));
    }
  }
}
