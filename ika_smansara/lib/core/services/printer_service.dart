import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';

class PrinterService {
  Future<bool> checkPermission() async {
    if (Platform.isAndroid) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.bluetooth,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.location,
      ].request();

      return statuses.values.every((status) => status.isGranted);
    }
    return true;
  }

  Future<List<BluetoothInfo>> scanDevices() async {
    bool permissionGranted = await checkPermission();
    if (!permissionGranted) {
      throw Exception('Izin Bluetooth tidak diberikan');
    }
    return await PrintBluetoothThermal.pairedBluetooths;
  }

  Future<bool> connect(String macAddress) async {
    return await PrintBluetoothThermal.connect(macPrinterAddress: macAddress);
  }

  Future<bool> disconnect() async {
    return await PrintBluetoothThermal.disconnect;
  }

  Future<bool> get isConnected async {
    return await PrintBluetoothThermal.connectionStatus;
  }

  Future<void> printTestTicket(int paperSize) async {
    List<int> bytes = [];
    final profile = await CapabilityProfile.load();
    final generator = Generator(
      paperSize == 58 ? PaperSize.mm58 : PaperSize.mm80,
      profile,
    );

    bytes += generator.reset();
    bytes += generator.text(
      'IKA SMANSARA',
      styles: const PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
        bold: true,
      ),
    );
    bytes += generator.text(
      'Test Printer Berhasil',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.feed(1);
    bytes += generator.hr();

    final connected = await isConnected;
    bytes += generator.text(
      'Status: ${connected ? "Terhubung" : "Terputus"}',
      styles: const PosStyles(align: PosAlign.center),
    );

    bytes += generator.feed(2);
    bytes += generator.cut();

    await PrintBluetoothThermal.writeBytes(bytes);
  }
}
