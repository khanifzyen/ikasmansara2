import 'package:flutter_test/flutter_test.dart';
import 'package:ika_smansara/features/settings/domain/entities/app_settings.dart';

void main() {
  group('AppSettings Entity', () {
    test('should create AppSettings with default values', () {
      // Act
      final settings = AppSettings();

      // Assert
      expect(settings.notificationsEnabled, isTrue);
      expect(settings.themeMode, equals('system'));
    });

    test('should create AppSettings with custom values', () {
      // Act
      final settings = AppSettings(
        notificationsEnabled: false,
        themeMode: 'dark',
      );

      // Assert
      expect(settings.notificationsEnabled, isFalse);
      expect(settings.themeMode, equals('dark'));
    });

    test('should implement Equatable', () {
      // Arrange
      const settings1 = AppSettings(
        notificationsEnabled: true,
        themeMode: 'light',
      );
      const settings2 = AppSettings(
        notificationsEnabled: true,
        themeMode: 'light',
      );
      const settings3 = AppSettings(
        notificationsEnabled: false,
        themeMode: 'dark',
      );

      // Assert
      expect(settings1, equals(settings2));
      expect(settings1, isNot(equals(settings3)));
    });

    test('copyWith should update only provided values', () {
      // Arrange
      const originalSettings = AppSettings(
        notificationsEnabled: true,
        themeMode: 'system',
      );

      // Act
      final updatedSettings = originalSettings.copyWith(
        themeMode: 'dark',
      );

      // Assert
      expect(updatedSettings.notificationsEnabled, isTrue);
      expect(updatedSettings.themeMode, equals('dark'));
    });

    test('copyWith should update all values', () {
      // Arrange
      const originalSettings = AppSettings(
        notificationsEnabled: true,
        themeMode: 'system',
      );

      // Act
      final updatedSettings = originalSettings.copyWith(
        notificationsEnabled: false,
        themeMode: 'light',
      );

      // Assert
      expect(updatedSettings.notificationsEnabled, isFalse);
      expect(updatedSettings.themeMode, equals('light'));
    });

    test('copyWith should preserve original when null provided', () {
      // Arrange
      const originalSettings = AppSettings(
        notificationsEnabled: false,
        themeMode: 'dark',
      );

      // Act
      final updatedSettings = originalSettings.copyWith();

      // Assert
      expect(updatedSettings.notificationsEnabled, isFalse);
      expect(updatedSettings.themeMode, equals('dark'));
    });
  });

  group('AppSettings Entity - Validations', () {
    test('should accept valid theme modes', () {
      // Arrange & Act & Assert
      expect(() => AppSettings(themeMode: 'system'), returnsNormally);
      expect(() => AppSettings(themeMode: 'light'), returnsNormally);
      expect(() => AppSettings(themeMode: 'dark'), returnsNormally);
    });

    test('should accept custom theme mode strings', () {
      // Arrange
      final customTheme = AppSettings(themeMode: 'custom');

      // Assert
      expect(customTheme.themeMode, equals('custom'));
    });

    test('should handle both boolean values for notifications', () {
      // Arrange
      final enabled = AppSettings(notificationsEnabled: true);
      final disabled = AppSettings(notificationsEnabled: false);

      // Assert
      expect(enabled.notificationsEnabled, isTrue);
      expect(disabled.notificationsEnabled, isFalse);
    });
  });

  group('AppSettings Entity - Edge Cases', () {
    test('should handle multiple copyWith calls', () {
      // Arrange
      const originalSettings = AppSettings(
        notificationsEnabled: true,
        themeMode: 'system',
      );

      // Act
      final step1 = originalSettings.copyWith(themeMode: 'dark');
      final step2 = step1.copyWith(notificationsEnabled: false);
      final step3 = step2.copyWith(themeMode: 'light');

      // Assert
      expect(step3.notificationsEnabled, isFalse);
      expect(step3.themeMode, equals('light'));
    });

    test('should handle empty theme mode string', () {
      // Arrange
      final emptyTheme = AppSettings(themeMode: '');

      // Assert
      expect(emptyTheme.themeMode, equals(''));
    });

    test('should maintain immutability with copyWith', () {
      // Arrange
      const originalSettings = AppSettings(
        notificationsEnabled: true,
        themeMode: 'system',
      );

      // Act
      final updatedSettings = originalSettings.copyWith(
        notificationsEnabled: false,
      );

      // Assert
      expect(originalSettings.notificationsEnabled, isTrue);
      expect(updatedSettings.notificationsEnabled, isFalse);
    });
  });
}
