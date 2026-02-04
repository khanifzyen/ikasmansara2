part of 'printer_bloc.dart';

abstract class PrinterState extends Equatable {
  const PrinterState();

  @override
  List<Object?> get props => [];
}

class PrinterInitial extends PrinterState {}

class PrinterLoading extends PrinterState {}

class PrinterLoaded extends PrinterState {
  final PrinterSettings settings;
  final bool isConnected;

  const PrinterLoaded({required this.settings, this.isConnected = false});

  @override
  List<Object?> get props => [settings, isConnected];
}

class PrinterScanning extends PrinterState {
  final PrinterSettings settings;
  const PrinterScanning({required this.settings});

  @override
  List<Object?> get props => [settings];
}

class PrinterScanResult extends PrinterState {
  final PrinterSettings settings;
  final List<Map<String, String>> devices; // Mock device list

  const PrinterScanResult({required this.settings, required this.devices});

  @override
  List<Object?> get props => [settings, devices];
}

class PrinterError extends PrinterState {
  final String message;

  const PrinterError(this.message);

  @override
  List<Object?> get props => [message];
}
