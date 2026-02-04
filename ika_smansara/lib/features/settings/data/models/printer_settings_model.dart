import '../../domain/entities/printer_settings.dart';

class PrinterSettingsModel extends PrinterSettings {
  const PrinterSettingsModel({
    super.macAddress,
    super.name,
    super.paperSize,
    super.autoPrintEnabled,
  });

  factory PrinterSettingsModel.fromEntity(PrinterSettings entity) {
    return PrinterSettingsModel(
      macAddress: entity.macAddress,
      name: entity.name,
      paperSize: entity.paperSize,
      autoPrintEnabled: entity.autoPrintEnabled,
    );
  }

  PrinterSettings toEntity() {
    return PrinterSettings(
      macAddress: macAddress,
      name: name,
      paperSize: paperSize,
      autoPrintEnabled: autoPrintEnabled,
    );
  }
}
