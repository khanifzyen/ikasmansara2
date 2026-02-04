import '../entities/printer_settings.dart';
import '../repositories/settings_repository.dart';

class SavePrinterSettings {
  final SettingsRepository repository;

  SavePrinterSettings(this.repository);

  Future<void> call(PrinterSettings settings) async {
    await repository.savePrinterSettings(settings);
  }
}
