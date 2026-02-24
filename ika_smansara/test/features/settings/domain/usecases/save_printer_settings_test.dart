import 'package:flutter_test/flutter_test.dart';
import 'package:ika_smansara/features/settings/domain/entities/printer_settings.dart';
import 'package:ika_smansara/features/settings/domain/repositories/settings_repository.dart';
import 'package:ika_smansara/features/settings/domain/usecases/save_printer_settings.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<SettingsRepository>()])
import 'save_printer_settings_test.mocks.dart';

void main() {
  late SavePrinterSettings useCase;
  late MockSettingsRepository mockRepository;

  setUp(() {
    mockRepository = MockSettingsRepository();
    useCase = SavePrinterSettings(mockRepository);
  });

  group('SavePrinterSettings UseCase', () {
    const tPrinterSettings = PrinterSettings(
      macAddress: '00:1A:2B:3C:4D:5E',
      name: 'Test Printer',
      paperSize: 58,
      autoPrintEnabled: true,
    );

    test('should save printer settings to repository', () async {
      // Arrange
      when(mockRepository.savePrinterSettings(tPrinterSettings))
          .thenAnswer((_) async {});

      // Act
      await useCase(tPrinterSettings);

      // Assert
      verify(mockRepository.savePrinterSettings(tPrinterSettings));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should save settings with 58mm paper size', () async {
      // Arrange
      const smallPaperSettings = PrinterSettings(
        macAddress: '00:1A:2B:3C:4D:5E',
        name: '58mm Printer',
        paperSize: 58,
        autoPrintEnabled: false,
      );
      when(mockRepository.savePrinterSettings(smallPaperSettings))
          .thenAnswer((_) async {});

      // Act
      await useCase(smallPaperSettings);

      // Assert
      verify(mockRepository.savePrinterSettings(smallPaperSettings));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should save settings with 80mm paper size', () async {
      // Arrange
      const largePaperSettings = PrinterSettings(
        macAddress: '00:1A:2B:3C:4D:5E',
        name: '80mm Printer',
        paperSize: 80,
        autoPrintEnabled: false,
      );
      when(mockRepository.savePrinterSettings(largePaperSettings))
          .thenAnswer((_) async {});

      // Act
      await useCase(largePaperSettings);

      // Assert
      verify(mockRepository.savePrinterSettings(largePaperSettings));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should save settings with auto print enabled', () async {
      // Arrange
      const autoPrintSettings = PrinterSettings(
        macAddress: 'AA:BB:CC:DD:EE:FF',
        name: 'Auto Printer',
        paperSize: 58,
        autoPrintEnabled: true,
      );
      when(mockRepository.savePrinterSettings(autoPrintSettings))
          .thenAnswer((_) async {});

      // Act
      await useCase(autoPrintSettings);

      // Assert
      verify(mockRepository.savePrinterSettings(autoPrintSettings));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should save settings with auto print disabled', () async {
      // Arrange
      const manualPrintSettings = PrinterSettings(
        macAddress: '00:1A:2B:3C:4D:5E',
        name: 'Manual Printer',
        paperSize: 58,
        autoPrintEnabled: false,
      );
      when(mockRepository.savePrinterSettings(manualPrintSettings))
          .thenAnswer((_) async {});

      // Act
      await useCase(manualPrintSettings);

      // Assert
      verify(mockRepository.savePrinterSettings(manualPrintSettings));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should propagate repository error', () async {
      // Arrange
      final exception = Exception('Failed to save printer settings');
      when(mockRepository.savePrinterSettings(tPrinterSettings))
          .thenThrow(exception);

      // Act & Assert
      expect(
        () => useCase(tPrinterSettings),
        throwsA(exception),
      );
      verify(mockRepository.savePrinterSettings(tPrinterSettings));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should handle void return type', () async {
      // Arrange
      when(mockRepository.savePrinterSettings(tPrinterSettings))
          .thenAnswer((_) async {});

      // Act
      await useCase(tPrinterSettings);

      // Assert
      // Void function - just verify it was called
      verify(mockRepository.savePrinterSettings(tPrinterSettings));
    });
  });

  group('SavePrinterSettings UseCase - Validations', () {
    test('should save settings without printer (null values)', () async {
      // Arrange
      const noPrinterSettings = PrinterSettings();
      when(mockRepository.savePrinterSettings(noPrinterSettings))
          .thenAnswer((_) async {});

      // Act
      await useCase(noPrinterSettings);

      // Assert
      verify(mockRepository.savePrinterSettings(const PrinterSettings(
        macAddress: null,
        name: null,
        paperSize: 58,
        autoPrintEnabled: false,
      )));
    });

    test('should save settings created with copyWith', () async {
      // Arrange
      final originalSettings = PrinterSettings(
        macAddress: '00:1A:2B:3C:4D:5E',
        name: 'Original',
        paperSize: 58,
        autoPrintEnabled: false,
      );
      final updatedSettings = originalSettings.copyWith(
        name: 'Updated',
        autoPrintEnabled: true,
      );
      when(mockRepository.savePrinterSettings(updatedSettings))
          .thenAnswer((_) async {});

      // Act
      await useCase(updatedSettings);

      // Assert
      verify(mockRepository.savePrinterSettings(updatedSettings));
    });

    test('should save settings with null MAC and name', () async {
      // Arrange
      const nullFieldsSettings = PrinterSettings(
        macAddress: null,
        name: null,
        paperSize: 58,
        autoPrintEnabled: false,
      );
      when(mockRepository.savePrinterSettings(nullFieldsSettings))
          .thenAnswer((_) async {});

      // Act
      await useCase(nullFieldsSettings);

      // Assert
      verify(mockRepository.savePrinterSettings(nullFieldsSettings));
    });

    test('should save multiple settings in sequence', () async {
      // Arrange
      const settings1 = PrinterSettings(paperSize: 58);
      const settings2 = PrinterSettings(paperSize: 80);
      const settings3 = PrinterSettings(autoPrintEnabled: true);

      when(mockRepository.savePrinterSettings(settings1))
          .thenAnswer((_) async {});
      when(mockRepository.savePrinterSettings(settings2))
          .thenAnswer((_) async {});
      when(mockRepository.savePrinterSettings(settings3))
          .thenAnswer((_) async {});

      // Act
      await useCase(settings1);
      await useCase(settings2);
      await useCase(settings3);

      // Assert
      verifyInOrder([
        mockRepository.savePrinterSettings(settings1),
        mockRepository.savePrinterSettings(settings2),
        mockRepository.savePrinterSettings(settings3),
      ]);
    });
  });

  group('SavePrinterSettings UseCase - Edge Cases', () {
    test('should save settings with invalid MAC address', () async {
      // Arrange
      const invalidMacSettings = PrinterSettings(
        macAddress: 'invalid-mac-address',
        name: 'Test',
        paperSize: 58,
        autoPrintEnabled: false,
      );
      when(mockRepository.savePrinterSettings(invalidMacSettings))
          .thenAnswer((_) async {});

      // Act
      await useCase(invalidMacSettings);

      // Assert
      verify(mockRepository.savePrinterSettings(invalidMacSettings));
    });

    test('should save settings with very long printer name', () async {
      // Arrange
      final longNameSettings = PrinterSettings(
        macAddress: '00:1A:2B:3C:4D:5E',
        name: 'A' * 200,
        paperSize: 58,
        autoPrintEnabled: false,
      );
      when(mockRepository.savePrinterSettings(longNameSettings))
          .thenAnswer((_) async {});

      // Act
      await useCase(longNameSettings);

      // Assert
      verify(mockRepository.savePrinterSettings(longNameSettings));
    });

    test('should save settings with custom paper size', () async {
      // Arrange
      const customPaperSettings = PrinterSettings(
        macAddress: '00:1A:2B:3C:4D:5E',
        name: 'Custom',
        paperSize: 72,
        autoPrintEnabled: false,
      );
      when(mockRepository.savePrinterSettings(customPaperSettings))
          .thenAnswer((_) async {});

      // Act
      await useCase(customPaperSettings);

      // Assert
      verify(mockRepository.savePrinterSettings(customPaperSettings));
    });
  });
}
