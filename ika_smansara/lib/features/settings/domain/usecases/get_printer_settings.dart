import '../entities/printer_settings.dart';
import '../repositories/settings_repository.dart';

class GetPrinterSettings {
  final SettingsRepository repository;

  GetPrinterSettings(this.repository);

  Future<PrinterSettings> call() async {
    return await repository.getPrinterSettings();
  }
}
