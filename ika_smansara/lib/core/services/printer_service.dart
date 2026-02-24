import 'dart:io';

import 'package:flutter/foundation.dart';
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
        debugPrint(
          'PrinterService: Android SDK: ${androidInfo.version.sdkInt}',
        );

        if (androidInfo.version.sdkInt >= 31) {
          // Android 12+ (SDK 31+)
          debugPrint('PrinterService: Requesting A12+ permissions');
          Map<Permission, PermissionStatus> statuses = await [
            Permission.bluetoothScan,
            Permission.bluetoothConnect,
            Permission.location, // Fallback: force location request
          ].request();

          statuses.forEach((key, value) {
            debugPrint('PrinterService: $key = $value');
          });

          // Check if Bluetooth permissions are granted.
          final scan = statuses[Permission.bluetoothScan];
          final connect = statuses[Permission.bluetoothConnect];

          return (scan?.isGranted ?? false) && (connect?.isGranted ?? false);
        } else {
          // Android 11 and below
          debugPrint('PrinterService: Requesting Legacy permissions');
          Map<Permission, PermissionStatus> statuses = await [
            Permission.bluetooth,
            Permission.location,
          ].request();

          statuses.forEach((key, value) {
            debugPrint('PrinterService: $key = $value');
          });

          return statuses.values.every((status) => status.isGranted);
        }
      }
      return true;
    } catch (e) {
      debugPrint('PrinterService: Error checking permission: $e');
      return false;
    }
  }

  /// Request Bluetooth permissions without scanning devices
  Future<bool> requestPermissions() async {
    return await checkPermission();
  }

  Future<List<BluetoothInfo>> scanDevices() async {
    bool permissionGranted = await checkPermission();
    debugPrint('PrinterService: Permission granted? $permissionGranted');
    if (!permissionGranted) {
      throw Exception('Izin Bluetooth/Lokasi tidak diberikan');
    }

    final bool isBluetoothEnabled =
        await PrintBluetoothThermal.bluetoothEnabled;
    debugPrint('PrinterService: Bluetooth enabled? $isBluetoothEnabled');
    if (!isBluetoothEnabled) {
      throw Exception('Bluetooth belum aktif');
    }

    try {
      // Add a timeout to prevent infinite hanging
      return await PrintBluetoothThermal.pairedBluetooths.timeout(
        const Duration(seconds: 4),
        onTimeout: () {
          debugPrint('PrinterService: Scan timed out');
          throw Exception(
            'Gagal memindai (Timeout). Pastikan perangkat sudah di-pairing.',
          );
        },
      );
    } catch (e) {
      debugPrint('PrinterService: Scan error: $e');
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
    try {
      return await PrintBluetoothThermal.connectionStatus.timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          debugPrint('PrinterService: Connection status check timed out');
          return false;
        },
      );
    } catch (e) {
      debugPrint('PrinterService: Error checking connection status: $e');
      return false;
    }
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

  /// Print event ticket with QR code
  /// [ticketId] - The record ID from event_booking_tickets
  /// [ticketCode] - The unique ticket code (e.g. TIX-REU10-001)
  /// [ticketName] - Ticket type name (e.g. VIP Package)
  /// [userName] - Name of the ticket holder
  /// [options] - Selected options (e.g. {size: "XL"})
  /// [eventTitle] - Event title
  /// [eventDate] - Event date
  /// [eventTime] - Event time (e.g. "08:00")
  /// [eventLocation] - Event location
  /// [paperSize] - Paper width: 58 or 80
  Future<void> printEventTicket({
    required String ticketId,
    required String ticketCode,
    required String ticketName,
    required String userName,
    required Map<String, dynamic> options,
    required String eventTitle,
    required DateTime eventDate,
    required String eventTime,
    required String eventLocation,
    required int paperSize,
  }) async {
    final connected = await isConnected;
    if (!connected) {
      throw Exception(
        'Printer tidak terhubung. Silakan hubungkan terlebih dahulu.',
      );
    }

    List<int> bytes = [];
    final profile = await CapabilityProfile.load();
    final generator = Generator(
      paperSize == 58 ? PaperSize.mm58 : PaperSize.mm80,
      profile,
    );

    // Format date
    final months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final days = ['', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final dayName = days[eventDate.weekday];
    final formattedDate =
        '$dayName, ${eventDate.day} ${months[eventDate.month]} ${eventDate.year}';

    // Format options
    String optionsStr = '';
    if (options.isNotEmpty) {
      optionsStr = options.entries.map((e) => '${e.value}').join(', ');
    }

    bytes += generator.reset();

    // === HEADER ===
    bytes += generator.text(
      'IKA SMANSARA',
      styles: const PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
        bold: true,
      ),
    );
    bytes += generator.feed(1);
    bytes += generator.hr();

    // === EVENT INFO ===
    bytes += generator.text('EVENT:', styles: const PosStyles(bold: true));
    bytes += generator.text(eventTitle);
    bytes += generator.feed(1);

    bytes += generator.text('WAKTU:', styles: const PosStyles(bold: true));
    bytes += generator.text('$formattedDate - $eventTime');
    bytes += generator.feed(1);

    bytes += generator.text('LOKASI:', styles: const PosStyles(bold: true));
    bytes += generator.text(eventLocation);
    bytes += generator.hr();

    // === TICKET INFO ===
    bytes += generator.row([
      PosColumn(text: 'TIKET', width: 4, styles: const PosStyles(bold: true)),
      PosColumn(text: ': $ticketName', width: 8),
    ]);
    bytes += generator.row([
      PosColumn(text: 'NAMA', width: 4, styles: const PosStyles(bold: true)),
      PosColumn(text: ': $userName', width: 8),
    ]);
    if (optionsStr.isNotEmpty) {
      bytes += generator.row([
        PosColumn(text: 'OPSI', width: 4, styles: const PosStyles(bold: true)),
        PosColumn(text: ': $optionsStr', width: 8),
      ]);
    }
    bytes += generator.hr();

    // === QR CODE ===
    // Format: ticketId:ticketCode (per SKEMA.md)
    final qrContent = '$ticketId:$ticketCode';
    bytes += generator.qrcode(qrContent, size: QRSize.size6);
    bytes += generator.feed(1);

    // === TICKET CODE (Human Readable) ===
    bytes += generator.text(
      ticketCode,
      styles: const PosStyles(
        align: PosAlign.center,
        //bold: true,
        //height: PosTextSize.size1,
        //width: PosTextSize.size2,
      ),
    );
    bytes += generator.hr();

    // === FOOTER ===
    bytes += generator.text(
      'Simpan struk ini sebagai',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      'bukti tiket masuk.',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.feed(1);
    bytes += generator.text(
      'Download di Playstore:',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      'IKA SMANSARA',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );

    //bytes += generator.feed(2);
    bytes += generator.cut();

    await PrintBluetoothThermal.writeBytes(bytes);
  }
}
