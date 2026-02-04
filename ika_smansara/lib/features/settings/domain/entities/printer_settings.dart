import 'package:equatable/equatable.dart';

class PrinterSettings extends Equatable {
  final String? macAddress;
  final String? name;
  final int paperSize; // 58 or 80
  final bool autoPrintEnabled;

  const PrinterSettings({
    this.macAddress,
    this.name,
    this.paperSize = 58,
    this.autoPrintEnabled = false,
  });

  PrinterSettings copyWith({
    String? macAddress,
    String? name,
    int? paperSize,
    bool? autoPrintEnabled,
  }) {
    return PrinterSettings(
      macAddress: macAddress ?? this.macAddress,
      name: name ?? this.name,
      paperSize: paperSize ?? this.paperSize,
      autoPrintEnabled: autoPrintEnabled ?? this.autoPrintEnabled,
    );
  }

  @override
  List<Object?> get props => [macAddress, name, paperSize, autoPrintEnabled];
}
