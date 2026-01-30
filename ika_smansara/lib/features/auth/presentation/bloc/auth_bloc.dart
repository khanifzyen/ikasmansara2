/// Auth BLoC - Handle authentication state
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterAlumniRequested>(_onRegisterAlumniRequested);
    on<AuthRegisterPublicRequested>(_onRegisterPublicRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    if (!_authRepository.isAuthenticated) {
      emit(const AuthUnauthenticated());
      return;
    }

    final result = await _authRepository.getCurrentUser();
    if (result.failure != null) {
      emit(const AuthUnauthenticated());
    } else if (result.data != null) {
      emit(AuthAuthenticated(result.data!));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _authRepository.login(
      email: event.email,
      password: event.password,
    );

    if (result.failure != null) {
      emit(AuthError(result.failure!));
    } else if (result.data != null) {
      emit(AuthAuthenticated(result.data!));
    }
  }

  Future<void> _onRegisterAlumniRequested(
    AuthRegisterAlumniRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _authRepository.registerAlumni(event.params);

    if (result.failure != null) {
      emit(AuthError(result.failure!));
    } else {
      emit(AuthRegistrationSuccess(email: event.params.email));
    }
  }

  Future<void> _onRegisterPublicRequested(
    AuthRegisterPublicRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _authRepository.registerPublic(event.params);

    if (result.failure != null) {
      emit(AuthError(result.failure!));
    } else {
      emit(AuthRegistrationSuccess(email: event.params.email));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    await _authRepository.logout();
    emit(const AuthUnauthenticated());
  }
}
