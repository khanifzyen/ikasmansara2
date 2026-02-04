part of 'printer_bloc.dart';

abstract class PrinterEvent extends Equatable {
  const PrinterEvent();

  @override
  List<Object?> get props => [];
}

class LoadPrinterSettings extends PrinterEvent {}

class ScanDevices extends PrinterEvent {}

class ConnectDevice extends PrinterEvent {
  final String name;
  final String macAddress;

  const ConnectDevice({required this.name, required this.macAddress});

  @override
  List<Object?> get props => [name, macAddress];
}

class DisconnectDevice extends PrinterEvent {}

class UpdatePrinterConfig extends PrinterEvent {
  final int? paperSize;
  final bool? autoPrintEnabled;

  const UpdatePrinterConfig({this.paperSize, this.autoPrintEnabled});

  @override
  List<Object?> get props => [paperSize, autoPrintEnabled];
}

class TestPrint extends PrinterEvent {}
