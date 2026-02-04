import '../../domain/entities/app_settings.dart';

class AppSettingsModel extends AppSettings {
  const AppSettingsModel({super.notificationsEnabled, super.themeMode});

  factory AppSettingsModel.fromEntity(AppSettings entity) {
    return AppSettingsModel(
      notificationsEnabled: entity.notificationsEnabled,
      themeMode: entity.themeMode,
    );
  }

  AppSettings toEntity() {
    return AppSettings(
      notificationsEnabled: notificationsEnabled,
      themeMode: themeMode,
    );
  }
}
