import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/printer_settings.dart';
import '../../domain/usecases/get_printer_settings.dart';
import '../../domain/usecases/save_printer_settings.dart';

part 'printer_event.dart';
part 'printer_state.dart';

class PrinterBloc extends Bloc<PrinterEvent, PrinterState> {
  final GetPrinterSettings getPrinterSettings;
  final SavePrinterSettings savePrinterSettings;

  PrinterBloc({
    required this.getPrinterSettings,
    required this.savePrinterSettings,
  }) : super(PrinterInitial()) {
    on<LoadPrinterSettings>(_onLoadPrinterSettings);
    on<ScanDevices>(_onScanDevices);
    on<ConnectDevice>(_onConnectDevice);
    on<UpdatePrinterConfig>(_onUpdatePrinterConfig);
    on<TestPrint>(_onTestPrint);
    on<DisconnectDevice>(_onDisconnectDevice);
  }

  Future<void> _onLoadPrinterSettings(
    LoadPrinterSettings event,
    Emitter<PrinterState> emit,
  ) async {
    emit(PrinterLoading());
    try {
      final settings = await getPrinterSettings();
      emit(PrinterLoaded(settings: settings));
    } catch (e) {
      emit(const PrinterError("Failed to load printer settings"));
    }
  }

  Future<void> _onScanDevices(
    ScanDevices event,
    Emitter<PrinterState> emit,
  ) async {
    if (state is PrinterLoaded) {
      final currentSettings = (state as PrinterLoaded).settings;
      emit(PrinterScanning(settings: currentSettings));

      // Simulate scanning delay
      await Future.delayed(const Duration(seconds: 2));

      // Mock devices
      final devices = [
        {'name': 'RPP02N', 'mac': '00:11:22:33:44:55'},
        {'name': 'Blue-Tooth Printer', 'mac': 'AA:BB:CC:DD:EE:FF'},
      ];

      emit(PrinterScanResult(settings: currentSettings, devices: devices));
    }
  }

  Future<void> _onConnectDevice(
    ConnectDevice event,
    Emitter<PrinterState> emit,
  ) async {
    final currentState = state;
    PrinterSettings? settings;

    if (currentState is PrinterLoaded) settings = currentState.settings;
    if (currentState is PrinterScanResult) settings = currentState.settings;

    if (settings != null) {
      emit(PrinterLoading());
      // Simulate connection delay
      await Future.delayed(const Duration(seconds: 1));

      final newSettings = settings.copyWith(
        macAddress: event.macAddress,
        name: event.name,
      );
      await savePrinterSettings(newSettings);

      emit(PrinterLoaded(settings: newSettings, isConnected: true));
    }
  }

  Future<void> _onDisconnectDevice(
    DisconnectDevice event,
    Emitter<PrinterState> emit,
  ) async {
    if (state is PrinterLoaded) {
      final currentSettings = (state as PrinterLoaded).settings;
      final newSettings = PrinterSettings(
        paperSize: currentSettings.paperSize,
        autoPrintEnabled: currentSettings.autoPrintEnabled,
      );

      await savePrinterSettings(newSettings);
      emit(PrinterLoaded(settings: newSettings, isConnected: false));
    }
  }

  Future<void> _onUpdatePrinterConfig(
    UpdatePrinterConfig event,
    Emitter<PrinterState> emit,
  ) async {
    if (state is PrinterLoaded) {
      final currentState = state as PrinterLoaded;
      final newSettings = currentState.settings.copyWith(
        paperSize: event.paperSize,
        autoPrintEnabled: event.autoPrintEnabled,
      );
      await savePrinterSettings(newSettings);
      emit(
        PrinterLoaded(
          settings: newSettings,
          isConnected: currentState.isConnected,
        ),
      );
    }
  }

  Future<void> _onTestPrint(TestPrint event, Emitter<PrinterState> emit) async {
    // Just a trigger for UI side effect or logging
  }
}
