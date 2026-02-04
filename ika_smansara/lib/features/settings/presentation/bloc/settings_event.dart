part of 'settings_bloc.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object> get props => [];
}

class LoadAppSettings extends SettingsEvent {}

class ToggleTheme extends SettingsEvent {
  final String themeMode;

  const ToggleTheme(this.themeMode);

  @override
  List<Object> get props => [themeMode];
}

class ToggleNotifications extends SettingsEvent {
  final bool isEnabled;

  const ToggleNotifications(this.isEnabled);

  @override
  List<Object> get props => [isEnabled];
}
