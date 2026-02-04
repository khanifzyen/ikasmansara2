import 'package:equatable/equatable.dart';

class AppSettings extends Equatable {
  final bool notificationsEnabled;
  final String themeMode; // 'system', 'light', 'dark'

  const AppSettings({
    this.notificationsEnabled = true,
    this.themeMode = 'system',
  });

  AppSettings copyWith({bool? notificationsEnabled, String? themeMode}) {
    return AppSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  @override
  List<Object?> get props => [notificationsEnabled, themeMode];
}
