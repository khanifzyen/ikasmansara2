import '../../domain/entities/app_settings.dart';
import '../../domain/entities/printer_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_data_source.dart';
import '../models/app_settings_model.dart';
import '../models/printer_settings_model.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource localDataSource;

  SettingsRepositoryImpl(this.localDataSource);

  @override
  Future<PrinterSettings> getPrinterSettings() async {
    final model = await localDataSource.getPrinterSettings();
    return model.toEntity();
  }

  @override
  Future<void> savePrinterSettings(PrinterSettings settings) async {
    await localDataSource.savePrinterSettings(
      PrinterSettingsModel.fromEntity(settings),
    );
  }

  @override
  Future<AppSettings> getAppSettings() async {
    final model = await localDataSource.getAppSettings();
    return model.toEntity();
  }

  @override
  Future<void> saveAppSettings(AppSettings settings) async {
    await localDataSource.saveAppSettings(
      AppSettingsModel.fromEntity(settings),
    );
  }

  @override
  Future<void> clearSettings() async {
    await localDataSource.clear();
  }
}
