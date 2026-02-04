import '../entities/app_settings.dart';
import '../repositories/settings_repository.dart';

class GetAppSettings {
  final SettingsRepository repository;

  GetAppSettings(this.repository);

  Future<AppSettings> call() async {
    return await repository.getAppSettings();
  }
}
