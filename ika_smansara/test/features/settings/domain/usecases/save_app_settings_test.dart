import 'package:flutter_test/flutter_test.dart';
import 'package:ika_smansara/features/settings/domain/entities/app_settings.dart';
import 'package:ika_smansara/features/settings/domain/repositories/settings_repository.dart';
import 'package:ika_smansara/features/settings/domain/usecases/save_app_settings.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<SettingsRepository>()])
import 'save_app_settings_test.mocks.dart';

void main() {
  late SaveAppSettings useCase;
  late MockSettingsRepository mockRepository;

  setUp(() {
    mockRepository = MockSettingsRepository();
    useCase = SaveAppSettings(mockRepository);
  });

  group('SaveAppSettings UseCase', () {
    const tAppSettings = AppSettings(
      notificationsEnabled: true,
      themeMode: 'dark',
    );

    test('should save app settings to repository', () async {
      // Arrange
      when(mockRepository.saveAppSettings(tAppSettings))
          .thenAnswer((_) async {});

      // Act
      await useCase(tAppSettings);

      // Assert
      verify(mockRepository.saveAppSettings(tAppSettings));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should save settings with notifications enabled', () async {
      // Arrange
      const enabledSettings = AppSettings(
        notificationsEnabled: true,
        themeMode: 'system',
      );
      when(mockRepository.saveAppSettings(enabledSettings))
          .thenAnswer((_) async {});

      // Act
      await useCase(enabledSettings);

      // Assert
      verify(mockRepository.saveAppSettings(enabledSettings));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should save settings with notifications disabled', () async {
      // Arrange
      const disabledSettings = AppSettings(
        notificationsEnabled: false,
        themeMode: 'light',
      );
      when(mockRepository.saveAppSettings(disabledSettings))
          .thenAnswer((_) async {});

      // Act
      await useCase(disabledSettings);

      // Assert
      verify(mockRepository.saveAppSettings(disabledSettings));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should propagate repository error', () async {
      // Arrange
      final exception = Exception('Failed to save settings');
      when(mockRepository.saveAppSettings(tAppSettings))
          .thenThrow(exception);

      // Act & Assert
      expect(
        () => useCase(tAppSettings),
        throwsA(exception),
      );
      verify(mockRepository.saveAppSettings(tAppSettings));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should save all theme modes', () async {
      // Arrange
      final themeModes = ['system', 'light', 'dark'];

      for (final theme in themeModes) {
        final settings = AppSettings(themeMode: theme);
        when(mockRepository.saveAppSettings(settings))
            .thenAnswer((_) async {});

        // Act
        await useCase(settings);

        // Assert
        verify(mockRepository.saveAppSettings(settings));
      }
    });

    test('should handle void return type', () async {
      // Arrange
      when(mockRepository.saveAppSettings(tAppSettings))
          .thenAnswer((_) async {});

      // Act
      await useCase(tAppSettings);

      // Assert
      // Void function - just verify it was called
      verify(mockRepository.saveAppSettings(tAppSettings));
    });
  });

  group('SaveAppSettings UseCase - Validations', () {
    test('should save settings with copyWith created instance', () async {
      // Arrange
      final originalSettings = AppSettings(
        notificationsEnabled: true,
        themeMode: 'system',
      );
      final updatedSettings = originalSettings.copyWith(
        themeMode: 'dark',
      );
      when(mockRepository.saveAppSettings(updatedSettings))
          .thenAnswer((_) async {});

      // Act
      await useCase(updatedSettings);

      // Assert
      verify(mockRepository.saveAppSettings(updatedSettings));
    });

    test('should save settings with default values', () async {
      // Arrange
      const defaultSettings = AppSettings();
      when(mockRepository.saveAppSettings(defaultSettings))
          .thenAnswer((_) async {});

      // Act
      await useCase(defaultSettings);

      // Assert
      verify(mockRepository.saveAppSettings(
        const AppSettings(
          notificationsEnabled: true,
          themeMode: 'system',
        ),
      ));
    });

    test('should save multiple settings in sequence', () async {
      // Arrange
      const settings1 = AppSettings(themeMode: 'light');
      const settings2 = AppSettings(themeMode: 'dark');
      const settings3 = AppSettings(themeMode: 'system');

      when(mockRepository.saveAppSettings(settings1))
          .thenAnswer((_) async {});
      when(mockRepository.saveAppSettings(settings2))
          .thenAnswer((_) async {});
      when(mockRepository.saveAppSettings(settings3))
          .thenAnswer((_) async {});

      // Act
      await useCase(settings1);
      await useCase(settings2);
      await useCase(settings3);

      // Assert
      verifyInOrder([
        mockRepository.saveAppSettings(settings1),
        mockRepository.saveAppSettings(settings2),
        mockRepository.saveAppSettings(settings3),
      ]);
    });
  });
}
