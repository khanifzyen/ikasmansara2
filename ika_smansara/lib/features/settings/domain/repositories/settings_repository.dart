import '../entities/printer_settings.dart';
import '../entities/app_settings.dart';

abstract class SettingsRepository {
  Future<PrinterSettings> getPrinterSettings();
  Future<void> savePrinterSettings(PrinterSettings settings);

  Future<AppSettings> getAppSettings();
  Future<void> saveAppSettings(AppSettings settings);

  Future<void> clearSettings();
}
