import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/usecases/get_app_settings.dart';
import '../../domain/usecases/save_app_settings.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final GetAppSettings getAppSettings;
  final SaveAppSettings saveAppSettings;

  SettingsBloc({required this.getAppSettings, required this.saveAppSettings})
    : super(SettingsInitial()) {
    on<LoadAppSettings>(_onLoadAppSettings);
    on<ToggleTheme>(_onToggleTheme);
    on<ToggleNotifications>(_onToggleNotifications);
  }

  Future<void> _onLoadAppSettings(
    LoadAppSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());
    try {
      final settings = await getAppSettings();
      emit(SettingsLoaded(settings));
    } catch (e) {
      emit(const SettingsError("Failed to load settings"));
    }
  }

  Future<void> _onToggleTheme(
    ToggleTheme event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentSettings = (state as SettingsLoaded).settings;
      final newSettings = currentSettings.copyWith(themeMode: event.themeMode);
      await saveAppSettings(newSettings);
      emit(SettingsLoaded(newSettings));
    }
  }

  Future<void> _onToggleNotifications(
    ToggleNotifications event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentSettings = (state as SettingsLoaded).settings;
      final newSettings = currentSettings.copyWith(
        notificationsEnabled: event.isEnabled,
      );
      await saveAppSettings(newSettings);
      emit(SettingsLoaded(newSettings));
    }
  }
}
