import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/get_profile.dart';
import '../../domain/usecases/update_profile.dart';

// Events
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class FetchProfile extends ProfileEvent {}

class UpdateProfileEvent extends ProfileEvent {
  final ProfileUpdateParams params;

  const UpdateProfileEvent(this.params);

  @override
  List<Object?> get props => [params];
}

// States
abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserEntity user;

  const ProfileLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProfileUpdateSuccess extends ProfileState {
  final UserEntity user;

  const ProfileUpdateSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

// Bloc
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfile getProfile;
  final UpdateProfile updateProfile;

  ProfileBloc({required this.getProfile, required this.updateProfile})
    : super(ProfileInitial()) {
    on<FetchProfile>(_onFetchProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
  }

  Future<void> _onFetchProfile(
    FetchProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final user = await getProfile();
      emit(ProfileLoaded(user));
    } catch (e) {
      debugPrint('ProfileBloc Error: $e');
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final user = await updateProfile(event.params);
      emit(ProfileUpdateSuccess(user));
      // Optionally emit loaded again to update UI
      emit(ProfileLoaded(user));
    } catch (e) {
      debugPrint('ProfileBloc Update Error: $e');
      emit(ProfileError(e.toString()));
    }
  }
}
