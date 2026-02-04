import 'package:shared_preferences/shared_preferences.dart';
import '../models/printer_settings_model.dart';
import '../models/app_settings_model.dart';

abstract class SettingsLocalDataSource {
  Future<PrinterSettingsModel> getPrinterSettings();
  Future<void> savePrinterSettings(PrinterSettingsModel settings);

  Future<AppSettingsModel> getAppSettings();
  Future<void> saveAppSettings(AppSettingsModel settings);

  Future<void> clear();
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String keyPrinterMac = 'printer_mac_address';
  static const String keyPrinterName = 'printer_name';
  static const String keyPaperSize = 'printer_paper_size';
  static const String keyAutoPrint = 'auto_print_enabled';

  static const String keyThemeMode = 'theme_mode';
  static const String keyNotifEnabled = 'notifications_enabled';

  SettingsLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<PrinterSettingsModel> getPrinterSettings() async {
    return PrinterSettingsModel(
      macAddress: sharedPreferences.getString(keyPrinterMac),
      name: sharedPreferences.getString(keyPrinterName),
      paperSize: sharedPreferences.getInt(keyPaperSize) ?? 58,
      autoPrintEnabled: sharedPreferences.getBool(keyAutoPrint) ?? false,
    );
  }

  @override
  Future<void> savePrinterSettings(PrinterSettingsModel settings) async {
    if (settings.macAddress != null) {
      await sharedPreferences.setString(keyPrinterMac, settings.macAddress!);
    } else {
      await sharedPreferences.remove(keyPrinterMac);
    }

    if (settings.name != null) {
      await sharedPreferences.setString(keyPrinterName, settings.name!);
    } else {
      await sharedPreferences.remove(keyPrinterName);
    }

    await sharedPreferences.setInt(keyPaperSize, settings.paperSize);
    await sharedPreferences.setBool(keyAutoPrint, settings.autoPrintEnabled);
  }

  @override
  Future<AppSettingsModel> getAppSettings() async {
    return AppSettingsModel(
      notificationsEnabled: sharedPreferences.getBool(keyNotifEnabled) ?? true,
      themeMode: sharedPreferences.getString(keyThemeMode) ?? 'system',
    );
  }

  @override
  Future<void> saveAppSettings(AppSettingsModel settings) async {
    await sharedPreferences.setBool(
      keyNotifEnabled,
      settings.notificationsEnabled,
    );
    await sharedPreferences.setString(keyThemeMode, settings.themeMode);
  }

  @override
  Future<void> clear() async {
    await sharedPreferences.remove(keyPrinterMac);
    await sharedPreferences.remove(keyPrinterName);
    await sharedPreferences.remove(keyPaperSize);
    await sharedPreferences.remove(keyAutoPrint);
    await sharedPreferences.remove(keyThemeMode);
    await sharedPreferences.remove(keyNotifEnabled);
  }
}
