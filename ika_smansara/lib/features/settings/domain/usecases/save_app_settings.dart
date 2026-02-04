import '../entities/app_settings.dart';
import '../repositories/settings_repository.dart';

class SaveAppSettings {
  final SettingsRepository repository;

  SaveAppSettings(this.repository);

  Future<void> call(AppSettings settings) async {
    await repository.saveAppSettings(settings);
  }
}
