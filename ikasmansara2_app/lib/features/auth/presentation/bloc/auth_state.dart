/// Auth BLoC States
library;

import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/failures/auth_failure.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state - before auth check
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Checking auth status
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// User is authenticated
class AuthAuthenticated extends AuthState {
  final UserEntity user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// User is not authenticated
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Auth operation failed
class AuthError extends AuthState {
  final AuthFailure failure;

  const AuthError(this.failure);

  String get message => failure.message;

  @override
  List<Object?> get props => [failure];
}

/// Registration successful - user needs to login
class AuthRegistrationSuccess extends AuthState {
  final String email;
  final String message;

  const AuthRegistrationSuccess({
    required this.email,
    this.message = 'Pendaftaran berhasil! Silakan login.',
  });

  @override
  List<Object?> get props => [email, message];
}
