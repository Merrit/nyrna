import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nyrna/infrastructure/launcher/launcher.dart';
import 'package:nyrna/infrastructure/preferences/preferences.dart';

part 'preferences_state.dart';

late PreferencesCubit preferencesCubit;

class PreferencesCubit extends Cubit<PreferencesState> {
  PreferencesCubit() : super(PreferencesInitial()) {
    preferencesCubit = this;
  }

  Future<void> createLauncher() async {
    await Launcher.add();
  }

  /// If user wishes to ignore this update, save to SharedPreferences.
  Future<void> ignoreUpdate(String version) async {
    await Preferences.instance.setString(key: 'ignoredUpdate', value: version);
  }
}
