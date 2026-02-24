import 'package:flutter_test/flutter_test.dart';
import 'package:ika_smansara/features/settings/domain/entities/app_settings.dart';
import 'package:ika_smansara/features/settings/domain/repositories/settings_repository.dart';
import 'package:ika_smansara/features/settings/domain/usecases/get_app_settings.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<SettingsRepository>()])
import 'get_app_settings_test.mocks.dart';

void main() {
  late GetAppSettings useCase;
  late MockSettingsRepository mockRepository;

  setUp(() {
    mockRepository = MockSettingsRepository();
    useCase = GetAppSettings(mockRepository);
  });

  group('GetAppSettings UseCase', () {
    const tAppSettings = AppSettings(
      notificationsEnabled: true,
      themeMode: 'dark',
    );

    test('should get app settings from repository', () async {
      // Arrange
      when(mockRepository.getAppSettings())
          .thenAnswer((_) async => tAppSettings);

      // Act
      final result = await useCase();

      // Assert
      expect(result, equals(tAppSettings));
      expect(result.notificationsEnabled, isTrue);
      expect(result.themeMode, equals('dark'));
      verify(mockRepository.getAppSettings());
      verifyNoMoreInteractions(mockRepository);
    });

    test('should get default settings when none saved', () async {
      // Arrange
      const defaultSettings = AppSettings(
        notificationsEnabled: true,
        themeMode: 'system',
      );
      when(mockRepository.getAppSettings())
          .thenAnswer((_) async => defaultSettings);

      // Act
      final result = await useCase();

      // Assert
      expect(result.notificationsEnabled, isTrue);
      expect(result.themeMode, equals('system'));
      verify(mockRepository.getAppSettings());
      verifyNoMoreInteractions(mockRepository);
    });

    test('should propagate repository error', () async {
      // Arrange
      final exception = Exception('Failed to load settings');
      when(mockRepository.getAppSettings()).thenThrow(exception);

      // Act & Assert
      expect(
        () => useCase(),
        throwsA(exception),
      );
      verify(mockRepository.getAppSettings());
      verifyNoMoreInteractions(mockRepository);
    });

    test('should get settings with notifications disabled', () async {
      // Arrange
      const disabledNotifSettings = AppSettings(
        notificationsEnabled: false,
        themeMode: 'light',
      );
      when(mockRepository.getAppSettings())
          .thenAnswer((_) async => disabledNotifSettings);

      // Act
      final result = await useCase();

      // Assert
      expect(result.notificationsEnabled, isFalse);
      expect(result.themeMode, equals('light'));
    });

    test('should get settings with different theme modes', () async {
      // Arrange
      final themeModes = ['system', 'light', 'dark'];

      for (final theme in themeModes) {
        when(mockRepository.getAppSettings())
            .thenAnswer((_) async => AppSettings(themeMode: theme));

        // Act
        final result = await useCase();

        // Assert
        expect(result.themeMode, equals(theme));
      }
      verify(mockRepository.getAppSettings()).called(themeModes.length);
    });
  });

  group('GetAppSettings UseCase - Edge Cases', () {
    test('should handle custom theme mode', () async {
      // Arrange
      const customSettings = AppSettings(
        notificationsEnabled: true,
        themeMode: 'custom',
      );
      when(mockRepository.getAppSettings())
          .thenAnswer((_) async => customSettings);

      // Act
      final result = await useCase();

      // Assert
      expect(result.themeMode, equals('custom'));
    });

    test('should call repository only once', () async {
      // Arrange
      when(mockRepository.getAppSettings())
          .thenAnswer((_) async => const AppSettings());

      // Act
      await useCase();

      // Assert
      verify(mockRepository.getAppSettings()).called(1);
    });
  });
}
