import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';

class PrinterService {
  Future<bool> checkPermission() async {
    try {
      if (Platform.isAndroid) {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;
        print('PrinterService: Android SDK: ${androidInfo.version.sdkInt}');

        if (androidInfo.version.sdkInt >= 31) {
          // Android 12+ (SDK 31+)
          print('PrinterService: Requesting A12+ permissions');
          Map<Permission, PermissionStatus> statuses = await [
            Permission.bluetoothScan,
            Permission.bluetoothConnect,
            Permission.location, // Fallback: force location request
          ].request();

          statuses.forEach((key, value) {
            print('PrinterService: $key = $value');
          });

          // Check if Bluetooth permissions are granted.
          final scan = statuses[Permission.bluetoothScan];
          final connect = statuses[Permission.bluetoothConnect];

          return (scan?.isGranted ?? false) && (connect?.isGranted ?? false);
        } else {
          // Android 11 and below
          print('PrinterService: Requesting Legacy permissions');
          Map<Permission, PermissionStatus> statuses = await [
            Permission.bluetooth,
            Permission.location,
          ].request();

          statuses.forEach((key, value) {
            print('PrinterService: $key = $value');
          });

          return statuses.values.every((status) => status.isGranted);
        }
      }
      return true;
    } catch (e) {
      print('PrinterService: Error checking permission: $e');
      return false;
    }
  }

  Future<List<BluetoothInfo>> scanDevices() async {
    bool permissionGranted = await checkPermission();
    print('PrinterService: Permission granted? $permissionGranted');
    if (!permissionGranted) {
      throw Exception('Izin Bluetooth/Lokasi tidak diberikan');
    }

    final bool isBluetoothEnabled =
        await PrintBluetoothThermal.bluetoothEnabled;
    print('PrinterService: Bluetooth enabled? $isBluetoothEnabled');
    if (!isBluetoothEnabled) {
      throw Exception('Bluetooth belum aktif');
    }

    try {
      // Add a timeout to prevent infinite hanging
      return await PrintBluetoothThermal.pairedBluetooths.timeout(
        const Duration(seconds: 4),
        onTimeout: () {
          print('PrinterService: Scan timed out');
          throw Exception(
            'Gagal memindai (Timeout). Pastikan perangkat sudah di-pairing.',
          );
        },
      );
    } catch (e) {
      print('PrinterService: Scan error: $e');
      rethrow;
    }
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
