import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../auth/domain/entities/user_entity.dart';
import '../../data/datasources/admin_users_remote_data_source.dart';
import '../../data/repositories/admin_users_repository_impl.dart';

// Events
abstract class AdminUsersEvent extends Equatable {
  const AdminUsersEvent();
  @override
  List<Object?> get props => [];
}

class LoadAllUsers extends AdminUsersEvent {
  final String? filter;
  const LoadAllUsers({this.filter});
  @override
  List<Object?> get props => [filter];
}

class LoadPendingUsers extends AdminUsersEvent {
  const LoadPendingUsers();
}

class SearchUsersEvent extends AdminUsersEvent {
  final String query;
  const SearchUsersEvent(this.query);
  @override
  List<Object?> get props => [query];
}

class LoadMoreUsers extends AdminUsersEvent {
  const LoadMoreUsers();
}

class VerifyUserEvent extends AdminUsersEvent {
  final String userId;
  const VerifyUserEvent(this.userId);
  @override
  List<Object?> get props => [userId];
}

class RejectUserEvent extends AdminUsersEvent {
  final String userId;
  const RejectUserEvent(this.userId);
  @override
  List<Object?> get props => [userId];
}

// States
abstract class AdminUsersState extends Equatable {
  const AdminUsersState();
  @override
  List<Object?> get props => [];
}

class AdminUsersInitial extends AdminUsersState {}

class AdminUsersLoading extends AdminUsersState {}

class AdminUsersLoaded extends AdminUsersState {
  final List<UserEntity> users;
  final String? currentFilter;
  final bool hasMore;
  final int currentPage;
  final bool isLoadingMore;

  const AdminUsersLoaded({
    required this.users,
    this.currentFilter,
    this.hasMore = true,
    this.currentPage = 1,
    this.isLoadingMore = false,
  });

  AdminUsersLoaded copyWith({
    List<UserEntity>? users,
    String? currentFilter,
    bool? hasMore,
    int? currentPage,
    bool? isLoadingMore,
  }) {
    return AdminUsersLoaded(
      users: users ?? this.users,
      currentFilter: currentFilter ?? this.currentFilter,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
    users,
    currentFilter,
    hasMore,
    currentPage,
    isLoadingMore,
  ];
}

class AdminUsersError extends AdminUsersState {
  final String message;
  const AdminUsersError(this.message);
  @override
  List<Object?> get props => [message];
}

class AdminUsersActionSuccess extends AdminUsersState {
  final String message;
  const AdminUsersActionSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class AdminUsersBloc extends Bloc<AdminUsersEvent, AdminUsersState> {
  final AdminUsersRepositoryImpl _repository;
  String? _currentFilter;

  AdminUsersBloc()
    : _repository = AdminUsersRepositoryImpl(AdminUsersRemoteDataSource()),
      super(AdminUsersInitial()) {
    on<LoadAllUsers>(_onLoadAllUsers);
    on<LoadPendingUsers>(_onLoadPendingUsers);
    on<SearchUsersEvent>(_onSearchUsers);
    on<LoadMoreUsers>(_onLoadMoreUsers);
    on<VerifyUserEvent>(_onVerifyUser);
    on<RejectUserEvent>(_onRejectUser);
  }

  Future<void> _onLoadAllUsers(
    LoadAllUsers event,
    Emitter<AdminUsersState> emit,
  ) async {
    emit(AdminUsersLoading());
    try {
      _currentFilter = event.filter;
      final users = await _repository.getUsers(
        filter: event.filter,
        page: 1,
        perPage: 20,
      );
      emit(
        AdminUsersLoaded(
          users: users,
          currentFilter: event.filter,
          hasMore: users.length >= 20,
          currentPage: 1,
        ),
      );
    } catch (e) {
      emit(AdminUsersError(e.toString()));
    }
  }

  Future<void> _onLoadPendingUsers(
    LoadPendingUsers event,
    Emitter<AdminUsersState> emit,
  ) async {
    emit(AdminUsersLoading());
    try {
      _currentFilter = 'pending';
      final users = await _repository.getPendingUsers(page: 1, perPage: 20);
      emit(
        AdminUsersLoaded(
          users: users,
          currentFilter: 'pending',
          hasMore: users.length >= 20,
          currentPage: 1,
        ),
      );
    } catch (e) {
      emit(AdminUsersError(e.toString()));
    }
  }

  Future<void> _onSearchUsers(
    SearchUsersEvent event,
    Emitter<AdminUsersState> emit,
  ) async {
    emit(AdminUsersLoading());
    try {
      final users = await _repository.searchUsers(event.query);
      emit(
        AdminUsersLoaded(
          users: users,
          currentFilter: 'search:${event.query}',
          hasMore: false, // Search doesn't support pagination
        ),
      );
    } catch (e) {
      emit(AdminUsersError(e.toString()));
    }
  }

  Future<void> _onLoadMoreUsers(
    LoadMoreUsers event,
    Emitter<AdminUsersState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AdminUsersLoaded) return;
    if (!currentState.hasMore || currentState.isLoadingMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final nextPage = currentState.currentPage + 1;
      List<UserEntity> newUsers;

      if (_currentFilter == 'pending') {
        newUsers = await _repository.getPendingUsers(
          page: nextPage,
          perPage: 20,
        );
      } else {
        newUsers = await _repository.getUsers(
          filter: _currentFilter,
          page: nextPage,
          perPage: 20,
        );
      }

      final allUsers = [...currentState.users, ...newUsers];
      emit(
        currentState.copyWith(
          users: allUsers,
          currentPage: nextPage,
          hasMore: newUsers.length >= 20,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      emit(currentState.copyWith(isLoadingMore: false));
      emit(AdminUsersError(e.toString()));
    }
  }

  Future<void> _onVerifyUser(
    VerifyUserEvent event,
    Emitter<AdminUsersState> emit,
  ) async {
    try {
      await _repository.verifyUser(event.userId);
      emit(const AdminUsersActionSuccess('User berhasil diverifikasi'));
      // Reload users
      if (_currentFilter == 'pending') {
        add(const LoadPendingUsers());
      } else {
        add(LoadAllUsers(filter: _currentFilter));
      }
    } catch (e) {
      emit(AdminUsersError(e.toString()));
    }
  }

  Future<void> _onRejectUser(
    RejectUserEvent event,
    Emitter<AdminUsersState> emit,
  ) async {
    try {
      await _repository.rejectUser(event.userId);
      emit(const AdminUsersActionSuccess('User ditolak'));
      // Reload users
      if (_currentFilter == 'pending') {
        add(const LoadPendingUsers());
      } else {
        add(LoadAllUsers(filter: _currentFilter));
      }
    } catch (e) {
      emit(AdminUsersError(e.toString()));
    }
  }
}
