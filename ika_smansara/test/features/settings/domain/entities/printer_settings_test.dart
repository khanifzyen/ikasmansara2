import 'package:flutter_test/flutter_test.dart';
import 'package:ika_smansara/features/settings/domain/entities/printer_settings.dart';

void main() {
  group('PrinterSettings Entity', () {
    test('should create PrinterSettings with default values', () {
      // Act
      final settings = PrinterSettings();

      // Assert
      expect(settings.macAddress, isNull);
      expect(settings.name, isNull);
      expect(settings.paperSize, equals(58));
      expect(settings.autoPrintEnabled, isFalse);
    });

    test('should create PrinterSettings with custom values', () {
      // Act
      final settings = PrinterSettings(
        macAddress: '00:1A:2B:3C:4D:5E',
        name: 'Bluetooth Printer',
        paperSize: 80,
        autoPrintEnabled: true,
      );

      // Assert
      expect(settings.macAddress, equals('00:1A:2B:3C:4D:5E'));
      expect(settings.name, equals('Bluetooth Printer'));
      expect(settings.paperSize, equals(80));
      expect(settings.autoPrintEnabled, isTrue);
    });

    test('should implement Equatable', () {
      // Arrange
      const settings1 = PrinterSettings(
        macAddress: '00:1A:2B:3C:4D:5E',
        name: 'Printer',
        paperSize: 58,
        autoPrintEnabled: true,
      );
      const settings2 = PrinterSettings(
        macAddress: '00:1A:2B:3C:4D:5E',
        name: 'Printer',
        paperSize: 58,
        autoPrintEnabled: true,
      );
      const settings3 = PrinterSettings(
        macAddress: '00:1A:2B:3C:4D:5F',
        name: 'Different Printer',
        paperSize: 80,
        autoPrintEnabled: false,
      );

      // Assert
      expect(settings1, equals(settings2));
      expect(settings1, isNot(equals(settings3)));
    });

    test('copyWith should update only provided values', () {
      // Arrange
      const originalSettings = PrinterSettings(
        macAddress: '00:1A:2B:3C:4D:5E',
        name: 'Printer',
        paperSize: 58,
        autoPrintEnabled: false,
      );

      // Act
      final updatedSettings = originalSettings.copyWith(
        autoPrintEnabled: true,
      );

      // Assert
      expect(updatedSettings.macAddress, equals('00:1A:2B:3C:4D:5E'));
      expect(updatedSettings.name, equals('Printer'));
      expect(updatedSettings.paperSize, equals(58));
      expect(updatedSettings.autoPrintEnabled, isTrue);
    });

    test('copyWith should update all values', () {
      // Arrange
      const originalSettings = PrinterSettings(
        macAddress: 'AA:BB:CC:DD:EE:FF',
        name: 'Old Printer',
        paperSize: 58,
        autoPrintEnabled: false,
      );

      // Act
      final updatedSettings = originalSettings.copyWith(
        macAddress: '11:22:33:44:55:66',
        name: 'New Printer',
        paperSize: 80,
        autoPrintEnabled: true,
      );

      // Assert
      expect(updatedSettings.macAddress, equals('11:22:33:44:55:66'));
      expect(updatedSettings.name, equals('New Printer'));
      expect(updatedSettings.paperSize, equals(80));
      expect(updatedSettings.autoPrintEnabled, isTrue);
    });

    test('copyWith should preserve original when null provided', () {
      // Arrange
      const originalSettings = PrinterSettings(
        macAddress: '00:1A:2B:3C:4D:5E',
        name: 'Test Printer',
        paperSize: 80,
        autoPrintEnabled: true,
      );

      // Act
      final updatedSettings = originalSettings.copyWith();

      // Assert
      expect(updatedSettings.macAddress, equals('00:1A:2B:3C:4D:5E'));
      expect(updatedSettings.name, equals('Test Printer'));
      expect(updatedSettings.paperSize, equals(80));
      expect(updatedSettings.autoPrintEnabled, isTrue);
    });

    test('copyWith should preserve nullable fields when not provided', () {
      // Arrange
      const originalSettings = PrinterSettings(
        macAddress: '00:1A:2B:3C:4D:5E',
        name: 'Printer',
        paperSize: 58,
        autoPrintEnabled: false,
      );

      // Act - calling copyWith without updating nullable fields
      final updatedSettings = originalSettings.copyWith();

      // Assert - nullable fields should be preserved
      expect(updatedSettings.macAddress, equals('00:1A:2B:3C:4D:5E'));
      expect(updatedSettings.name, equals('Printer'));
      expect(updatedSettings.paperSize, equals(58));
      expect(updatedSettings.autoPrintEnabled, isFalse);
    });
  });

  group('PrinterSettings Entity - Validations', () {
    test('should accept valid paper sizes', () {
      // Arrange & Act & Assert
      expect(() => PrinterSettings(paperSize: 58), returnsNormally);
      expect(() => PrinterSettings(paperSize: 80), returnsNormally);
    });

    test('should accept other paper size values', () {
      // Arrange
      final customSize = PrinterSettings(paperSize: 72);

      // Assert
      expect(customSize.paperSize, equals(72));
    });

    test('should handle invalid MAC address format', () {
      // Arrange
      final invalidMac = PrinterSettings(macAddress: 'invalid-mac');

      // Assert
      expect(invalidMac.macAddress, equals('invalid-mac'));
    });

    test('should handle empty printer name', () {
      // Arrange
      final emptyName = PrinterSettings(name: '');

      // Assert
      expect(emptyName.name, equals(''));
    });

    test('should handle both boolean values for auto print', () {
      // Arrange
      final enabled = PrinterSettings(autoPrintEnabled: true);
      final disabled = PrinterSettings(autoPrintEnabled: false);

      // Assert
      expect(enabled.autoPrintEnabled, isTrue);
      expect(disabled.autoPrintEnabled, isFalse);
    });
  });

  group('PrinterSettings Entity - Edge Cases', () {
    test('should handle multiple copyWith calls', () {
      // Arrange
      const originalSettings = PrinterSettings(
        macAddress: 'AA:BB:CC:DD:EE:FF',
        name: 'Original',
        paperSize: 58,
        autoPrintEnabled: false,
      );

      // Act
      final step1 = originalSettings.copyWith(paperSize: 80);
      final step2 = step1.copyWith(autoPrintEnabled: true);
      final step3 = step2.copyWith(name: 'Updated');

      // Assert
      expect(step3.macAddress, equals('AA:BB:CC:DD:EE:FF'));
      expect(step3.name, equals('Updated'));
      expect(step3.paperSize, equals(80));
      expect(step3.autoPrintEnabled, isTrue);
    });

    test('should handle zero paper size', () {
      // Arrange
      final zeroPaper = PrinterSettings(paperSize: 0);

      // Assert
      expect(zeroPaper.paperSize, equals(0));
    });

    test('should handle very long printer name', () {
      // Arrange
      final longName = 'A' * 200;
      final longNameSettings = PrinterSettings(name: longName);

      // Assert
      expect(longNameSettings.name?.length, equals(200));
    });

    test('should maintain immutability with copyWith', () {
      // Arrange
      const originalSettings = PrinterSettings(
        macAddress: '00:11:22:33:44:55',
        name: 'Original',
        paperSize: 58,
        autoPrintEnabled: false,
      );

      // Act
      final updatedSettings = originalSettings.copyWith(
        name: 'Modified',
      );

      // Assert
      expect(originalSettings.name, equals('Original'));
      expect(updatedSettings.name, equals('Modified'));
      expect(originalSettings.autoPrintEnabled, isFalse);
      expect(updatedSettings.autoPrintEnabled, isFalse);
    });
  });
}
