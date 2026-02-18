import 'package:flutter_test/flutter_test.dart';
import 'package:ika_smansara/features/settings/domain/entities/printer_settings.dart';
import 'package:ika_smansara/features/settings/domain/repositories/settings_repository.dart';
import 'package:ika_smansara/features/settings/domain/usecases/get_printer_settings.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<SettingsRepository>()])
import 'get_printer_settings_test.mocks.dart';

void main() {
  late GetPrinterSettings useCase;
  late MockSettingsRepository mockRepository;

  setUp(() {
    mockRepository = MockSettingsRepository();
    useCase = GetPrinterSettings(mockRepository);
  });

  group('GetPrinterSettings UseCase', () {
    const tPrinterSettings = PrinterSettings(
      macAddress: '00:1A:2B:3C:4D:5E',
      name: 'Test Printer',
      paperSize: 58,
      autoPrintEnabled: true,
    );

    test('should get printer settings from repository', () async {
      // Arrange
      when(mockRepository.getPrinterSettings())
          .thenAnswer((_) async => tPrinterSettings);

      // Act
      final result = await useCase();

      // Assert
      expect(result, equals(tPrinterSettings));
      expect(result.macAddress, equals('00:1A:2B:3C:4D:5E'));
      expect(result.name, equals('Test Printer'));
      expect(result.paperSize, equals(58));
      expect(result.autoPrintEnabled, isTrue);
      verify(mockRepository.getPrinterSettings());
      verifyNoMoreInteractions(mockRepository);
    });

    test('should get default settings when none saved', () async {
      // Arrange
      const defaultSettings = PrinterSettings(
        macAddress: null,
        name: null,
        paperSize: 58,
        autoPrintEnabled: false,
      );
      when(mockRepository.getPrinterSettings())
          .thenAnswer((_) async => defaultSettings);

      // Act
      final result = await useCase();

      // Assert
      expect(result.macAddress, isNull);
      expect(result.name, isNull);
      expect(result.paperSize, equals(58));
      expect(result.autoPrintEnabled, isFalse);
      verify(mockRepository.getPrinterSettings());
      verifyNoMoreInteractions(mockRepository);
    });

    test('should propagate repository error', () async {
      // Arrange
      final exception = Exception('Failed to load printer settings');
      when(mockRepository.getPrinterSettings()).thenThrow(exception);

      // Act & Assert
      expect(
        () => useCase(),
        throwsA(exception),
      );
      verify(mockRepository.getPrinterSettings());
      verifyNoMoreInteractions(mockRepository);
    });

    test('should get settings with 80mm paper size', () async {
      // Arrange
      const largePaperSettings = PrinterSettings(
        macAddress: '00:1A:2B:3C:4D:5E',
        name: '80mm Printer',
        paperSize: 80,
        autoPrintEnabled: false,
      );
      when(mockRepository.getPrinterSettings())
          .thenAnswer((_) async => largePaperSettings);

      // Act
      final result = await useCase();

      // Assert
      expect(result.paperSize, equals(80));
      expect(result.name, equals('80mm Printer'));
    });

    test('should get settings without printer configured', () async {
      // Arrange
      const noPrinterSettings = PrinterSettings();
      when(mockRepository.getPrinterSettings())
          .thenAnswer((_) async => noPrinterSettings);

      // Act
      final result = await useCase();

      // Assert
      expect(result.macAddress, isNull);
      expect(result.name, isNull);
      expect(result.paperSize, equals(58));
      expect(result.autoPrintEnabled, isFalse);
    });

    test('should call repository only once', () async {
      // Arrange
      when(mockRepository.getPrinterSettings())
          .thenAnswer((_) async => const PrinterSettings());

      // Act
      await useCase();

      // Assert
      verify(mockRepository.getPrinterSettings()).called(1);
    });
  });

  group('GetPrinterSettings UseCase - Edge Cases', () {
    test('should handle printer with auto print enabled', () async {
      // Arrange
      const autoPrintSettings = PrinterSettings(
        macAddress: 'AA:BB:CC:DD:EE:FF',
        name: 'Auto Printer',
        paperSize: 58,
        autoPrintEnabled: true,
      );
      when(mockRepository.getPrinterSettings())
          .thenAnswer((_) async => autoPrintSettings);

      // Act
      final result = await useCase();

      // Assert
      expect(result.autoPrintEnabled, isTrue);
    });

    test('should handle different MAC address formats', () async {
      // Arrange
      final macFormats = [
        '00:1A:2B:3C:4D:5E',
        '00-1A-2B-3C-4D-5E',
        '001A.2B3C.4D5E',
      ];

      for (final mac in macFormats) {
        final settings = PrinterSettings(macAddress: mac);
        when(mockRepository.getPrinterSettings())
            .thenAnswer((_) async => settings);

        // Act
        final result = await useCase();

        // Assert
        expect(result.macAddress, equals(mac));
      }
    });

    test('should handle very long printer name', () async {
      // Arrange
      final longName = 'A' * 200;
      final longNameSettings = PrinterSettings(name: longName);
      when(mockRepository.getPrinterSettings())
          .thenAnswer((_) async => longNameSettings);

      // Act
      final result = await useCase();

      // Assert
      expect(result.name?.length, equals(200));
    });

    test('should handle custom paper size', () async {
      // Arrange
      const customPaperSettings = PrinterSettings(
        macAddress: '00:1A:2B:3C:4D:5E',
        name: 'Custom Printer',
        paperSize: 72,
        autoPrintEnabled: false,
      );
      when(mockRepository.getPrinterSettings())
          .thenAnswer((_) async => customPaperSettings);

      // Act
      final result = await useCase();

      // Assert
      expect(result.paperSize, equals(72));
    });
  });
}
