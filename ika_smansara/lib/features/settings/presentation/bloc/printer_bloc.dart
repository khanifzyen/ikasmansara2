import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/services/printer_service.dart';
import '../../domain/entities/printer_settings.dart';
import '../../domain/usecases/get_printer_settings.dart';
import '../../domain/usecases/save_printer_settings.dart';

part 'printer_event.dart';
part 'printer_state.dart';

class PrinterBloc extends Bloc<PrinterEvent, PrinterState> {
  final GetPrinterSettings getPrinterSettings;
  final SavePrinterSettings savePrinterSettings;
  final PrinterService printerService;

  PrinterBloc({
    required this.getPrinterSettings,
    required this.savePrinterSettings,
    required this.printerService,
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
      // Request permissions first to trigger the permission popup
      await printerService.requestPermissions();

      final settings = await getPrinterSettings();
      final isConnected = await printerService.isConnected;
      emit(PrinterLoaded(settings: settings, isConnected: isConnected));
    } catch (e) {
      emit(const PrinterError("Failed to load printer settings"));
    }
  }

  Future<void> _onScanDevices(
    ScanDevices event,
    Emitter<PrinterState> emit,
  ) async {
    if (state is PrinterLoaded || state is PrinterScanResult) {
      PrinterSettings? currentSettings;
      if (state is PrinterLoaded) {
        currentSettings = (state as PrinterLoaded).settings;
      } else if (state is PrinterScanResult) {
        currentSettings = (state as PrinterScanResult).settings;
      }

      if (currentSettings != null) {
        emit(PrinterScanning(settings: currentSettings));
        try {
          final devices = await printerService.scanDevices();
          final deviceList = devices
              .map((d) => {'name': d.name, 'mac': d.macAdress})
              .toList();

          emit(
            PrinterScanResult(settings: currentSettings, devices: deviceList),
          );
        } catch (e) {
          emit(PrinterError("Gagal memindai: ${e.toString()}"));
          // Restore state
          emit(PrinterLoaded(settings: currentSettings));
        }
      }
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

      try {
        final success = await printerService.connect(event.macAddress);
        if (success) {
          final newSettings = settings.copyWith(
            macAddress: event.macAddress,
            name: event.name,
          );
          await savePrinterSettings(newSettings);
          emit(PrinterLoaded(settings: newSettings, isConnected: true));
        } else {
          emit(const PrinterError("Gagal menghubungkan ke printer"));
          emit(PrinterLoaded(settings: settings, isConnected: false));
        }
      } catch (e) {
        emit(PrinterError("Error koneksi: $e"));
        emit(PrinterLoaded(settings: settings, isConnected: false));
      }
    }
  }

  Future<void> _onDisconnectDevice(
    DisconnectDevice event,
    Emitter<PrinterState> emit,
  ) async {
    if (state is PrinterLoaded) {
      final currentSettings = (state as PrinterLoaded).settings;
      await printerService.disconnect();

      // Keep settings but mark disconnected? Or clear mac?
      // Usually keep mac for auto-reconnect, but here we just update status
      emit(PrinterLoaded(settings: currentSettings, isConnected: false));
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
    if (state is PrinterLoaded) {
      final settings = (state as PrinterLoaded).settings;
      try {
        await printerService.printTestTicket(settings.paperSize);
      } catch (e) {
        emit(PrinterError("Gagal mencetak: $e"));
      }
    }
  }
}
