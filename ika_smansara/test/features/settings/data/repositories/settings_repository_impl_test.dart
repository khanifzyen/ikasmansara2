import 'package:flutter_test/flutter_test.dart';
import 'package:ika_smansara/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:ika_smansara/features/settings/data/models/app_settings_model.dart';
import 'package:ika_smansara/features/settings/data/models/printer_settings_model.dart';
import 'package:ika_smansara/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:ika_smansara/features/settings/domain/entities/app_settings.dart';
import 'package:ika_smansara/features/settings/domain/entities/printer_settings.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<SettingsLocalDataSource>()])
import 'settings_repository_impl_test.mocks.dart';

void main() {
  late SettingsRepositoryImpl repository;
  late MockSettingsLocalDataSource mockLocalDataSource;

  setUp(() {
    mockLocalDataSource = MockSettingsLocalDataSource();
    repository = SettingsRepositoryImpl(mockLocalDataSource);
  });

  group('SettingsRepositoryImpl', () {
    group('getPrinterSettings', () {
      final tPrinterSettingsModel = PrinterSettingsModel(
        paperSize: 80,
        macAddress: '00:11:22:33:44:55',
        name: 'POS Printer',
        autoPrintEnabled: false,
      );

      final tPrinterSettingsEntity = tPrinterSettingsModel.toEntity();

      test('should return printer settings from local data source', () async {
        // Arrange
        when(mockLocalDataSource.getPrinterSettings())
            .thenAnswer((_) async => tPrinterSettingsModel);

        // Act
        final result = await repository.getPrinterSettings();

        // Assert
        expect(result, equals(tPrinterSettingsEntity));
        expect(result.paperSize, equals(80));
        expect(result.macAddress, equals('00:11:22:33:44:55'));
        expect(result.name, equals('POS Printer'));
        expect(result.autoPrintEnabled, isFalse);
        verify(mockLocalDataSource.getPrinterSettings());
        verifyNoMoreInteractions(mockLocalDataSource);
      });

      test('should propagate data source error', () async {
        // Arrange
        final exception = Exception('Failed to load printer settings');
        when(mockLocalDataSource.getPrinterSettings())
            .thenThrow(exception);

        // Act & Assert
        expect(
          () => repository.getPrinterSettings(),
          throwsA(exception),
        );
        verify(mockLocalDataSource.getPrinterSettings());
      });

      test('should call data source only once', () async {
        // Arrange
        when(mockLocalDataSource.getPrinterSettings())
            .thenAnswer((_) async => tPrinterSettingsModel);

        // Act
        await repository.getPrinterSettings();

        // Assert
        verify(mockLocalDataSource.getPrinterSettings()).called(1);
      });

      test('should convert model to entity correctly', () async {
        // Arrange
        when(mockLocalDataSource.getPrinterSettings())
            .thenAnswer((_) async => tPrinterSettingsModel);

        // Act
        final result = await repository.getPrinterSettings();

        // Assert
        expect(result, isA<PrinterSettings>());
        expect(result.paperSize, equals(tPrinterSettingsModel.paperSize));
        expect(result.macAddress, equals(tPrinterSettingsModel.macAddress));
        expect(result.name, equals(tPrinterSettingsModel.name));
        expect(result.autoPrintEnabled, equals(tPrinterSettingsModel.autoPrintEnabled));
      });
    });

    group('savePrinterSettings', () {
      final tPrinterSettingsEntity = PrinterSettings(
        paperSize: 58,
        macAddress: 'AA:BB:CC:DD:EE:FF',
        name: 'Thermal Printer',
        autoPrintEnabled: true,
      );

      test('should save printer settings to local data source', () async {
        // Arrange
        when(mockLocalDataSource.savePrinterSettings(any))
            .thenAnswer((_) async {});

        // Act
        await repository.savePrinterSettings(tPrinterSettingsEntity);

        // Assert
        verify(mockLocalDataSource.savePrinterSettings(
          argThat(isA<PrinterSettingsModel>()),
        ));
        verifyNoMoreInteractions(mockLocalDataSource);
      });

      test('should propagate data source error', () async {
        // Arrange
        final exception = Exception('Failed to save printer settings');
        when(mockLocalDataSource.savePrinterSettings(any))
            .thenThrow(exception);

        // Act & Assert
        expect(
          () => repository.savePrinterSettings(tPrinterSettingsEntity),
          throwsA(exception),
        );
        verify(mockLocalDataSource.savePrinterSettings(any));
      });

      test('should convert entity to model before saving', () async {
        // Arrange
        when(mockLocalDataSource.savePrinterSettings(any))
            .thenAnswer((_) async {});

        // Act
        await repository.savePrinterSettings(tPrinterSettingsEntity);

        // Assert
        final captured =
            verify(mockLocalDataSource.savePrinterSettings(captureAny))
                .captured.single as PrinterSettingsModel;
        expect(captured.paperSize, equals(tPrinterSettingsEntity.paperSize));
        expect(captured.macAddress,
            equals(tPrinterSettingsEntity.macAddress));
        expect(
            captured.name, equals(tPrinterSettingsEntity.name));
        expect(captured.autoPrintEnabled, equals(tPrinterSettingsEntity.autoPrintEnabled));
      });

      test('should handle empty mac address', () async {
        // Arrange
        final emptyMacSettings = PrinterSettings(
          paperSize: 80,
          macAddress: null,
          name: null,
        );
        when(mockLocalDataSource.savePrinterSettings(any))
            .thenAnswer((_) async {});

        // Act
        await repository.savePrinterSettings(emptyMacSettings);

        // Assert
        verify(mockLocalDataSource.savePrinterSettings(any));
      });

      test('should handle different paper sizes', () async {
        // Arrange
        final paperSizes = [58, 80];
        when(mockLocalDataSource.savePrinterSettings(any))
            .thenAnswer((_) async {});

        // Act & Assert
        for (final size in paperSizes) {
          final settings = PrinterSettings(
            paperSize: size,
            macAddress: '00:00:00:00:00:00',
          );
          await repository.savePrinterSettings(settings);

          final captured =
              verify(mockLocalDataSource.savePrinterSettings(captureAny))
                  .captured.single as PrinterSettingsModel;
          expect(captured.paperSize, equals(size));
        }
      });
    });

    group('getAppSettings', () {
      final tAppSettingsModel = AppSettingsModel(
        themeMode: 'dark',
        notificationsEnabled: true,
      );

      final tAppSettingsEntity = tAppSettingsModel.toEntity();

      test('should return app settings from local data source', () async {
        // Arrange
        when(mockLocalDataSource.getAppSettings())
            .thenAnswer((_) async => tAppSettingsModel);

        // Act
        final result = await repository.getAppSettings();

        // Assert
        expect(result, equals(tAppSettingsEntity));
        expect(result.themeMode, equals('dark'));
        expect(result.notificationsEnabled, isTrue);
        verify(mockLocalDataSource.getAppSettings());
        verifyNoMoreInteractions(mockLocalDataSource);
      });

      test('should propagate data source error', () async {
        // Arrange
        final exception = Exception('Failed to load app settings');
        when(mockLocalDataSource.getAppSettings()).thenThrow(exception);

        // Act & Assert
        expect(
          () => repository.getAppSettings(),
          throwsA(exception),
        );
        verify(mockLocalDataSource.getAppSettings());
      });

      test('should convert model to entity correctly', () async {
        // Arrange
        when(mockLocalDataSource.getAppSettings())
            .thenAnswer((_) async => tAppSettingsModel);

        // Act
        final result = await repository.getAppSettings();

        // Assert
        expect(result, isA<AppSettings>());
        expect(result.themeMode, equals(tAppSettingsModel.themeMode));
        expect(result.notificationsEnabled, equals(tAppSettingsModel.notificationsEnabled));
      });

      test('should handle different theme modes', () async {
        // Arrange
        final themeModes = ['system', 'light', 'dark'];

        // Act & Assert
        for (final mode in themeModes) {
          when(mockLocalDataSource.getAppSettings()).thenAnswer((_) async {
            return AppSettingsModel(themeMode: mode, notificationsEnabled: true);
          });
          final result = await repository.getAppSettings();
          expect(result.themeMode, equals(mode));
        }
      });
    });

    group('saveAppSettings', () {
      final tAppSettingsEntity = AppSettings(
        themeMode: 'light',
        notificationsEnabled: false,
      );

      test('should save app settings to local data source', () async {
        // Arrange
        when(mockLocalDataSource.saveAppSettings(any))
            .thenAnswer((_) async {});

        // Act
        await repository.saveAppSettings(tAppSettingsEntity);

        // Assert
        verify(mockLocalDataSource.saveAppSettings(
          argThat(isA<AppSettingsModel>()),
        ));
        verifyNoMoreInteractions(mockLocalDataSource);
      });

      test('should propagate data source error', () async {
        // Arrange
        final exception = Exception('Failed to save app settings');
        when(mockLocalDataSource.saveAppSettings(any)).thenThrow(exception);

        // Act & Assert
        expect(
          () => repository.saveAppSettings(tAppSettingsEntity),
          throwsA(exception),
        );
        verify(mockLocalDataSource.saveAppSettings(any));
      });

      test('should convert entity to model before saving', () async {
        // Arrange
        when(mockLocalDataSource.saveAppSettings(any))
            .thenAnswer((_) async {});

        // Act
        await repository.saveAppSettings(tAppSettingsEntity);

        // Assert
        final captured = verify(mockLocalDataSource.saveAppSettings(captureAny))
            .captured.single as AppSettingsModel;
        expect(captured.themeMode, equals(tAppSettingsEntity.themeMode));
        expect(captured.notificationsEnabled, equals(tAppSettingsEntity.notificationsEnabled));
      });

      test('should handle different notification settings', () async {
        // Arrange
        final notificationSettings = [true, false];
        when(mockLocalDataSource.saveAppSettings(any))
            .thenAnswer((_) async {});

        // Act & Assert
        for (final enabled in notificationSettings) {
          final settings = AppSettings(
            themeMode: 'system',
            notificationsEnabled: enabled,
          );
          await repository.saveAppSettings(settings);

          final captured = verify(mockLocalDataSource.saveAppSettings(captureAny))
              .captured.single as AppSettingsModel;
          expect(captured.notificationsEnabled, equals(enabled));
        }
      });
    });

    group('clearSettings', () {
      test('should clear all settings from local data source', () async {
        // Arrange
        when(mockLocalDataSource.clear()).thenAnswer((_) async {});

        // Act
        await repository.clearSettings();

        // Assert
        verify(mockLocalDataSource.clear());
        verifyNoMoreInteractions(mockLocalDataSource);
      });

      test('should propagate data source error', () async {
        // Arrange
        final exception = Exception('Failed to clear settings');
        when(mockLocalDataSource.clear()).thenThrow(exception);

        // Act & Assert
        expect(
          () => repository.clearSettings(),
          throwsA(exception),
        );
        verify(mockLocalDataSource.clear());
      });

      test('should call data source only once', () async {
        // Arrange
        when(mockLocalDataSource.clear()).thenAnswer((_) async {});

        // Act
        await repository.clearSettings();

        // Assert
        verify(mockLocalDataSource.clear()).called(1);
      });
    });
  });
}
