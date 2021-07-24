import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nyrna/infrastructure/launcher/launcher.dart';

part 'preferences_state.dart';

late PreferencesCubit preferencesCubit;

class PreferencesCubit extends Cubit<PreferencesState> {
  PreferencesCubit() : super(PreferencesInitial()) {
    preferencesCubit = this;
  }

  Future<void> createLauncher() async {
    await Launcher.add();
  }
}
