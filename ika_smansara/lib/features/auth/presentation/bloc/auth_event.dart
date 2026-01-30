/// Auth BLoC Events
library;

import 'package:equatable/equatable.dart';
import '../../domain/repositories/auth_repository.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Check current auth status on app start
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Login with email and password
class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// Register alumni
class AuthRegisterAlumniRequested extends AuthEvent {
  final RegisterAlumniParams params;

  const AuthRegisterAlumniRequested(this.params);

  @override
  List<Object?> get props => [params];
}

/// Register public user
class AuthRegisterPublicRequested extends AuthEvent {
  final RegisterPublicParams params;

  const AuthRegisterPublicRequested(this.params);

  @override
  List<Object?> get props => [params];
}

/// Logout current user
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}
