import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../events/domain/entities/event.dart';
import '../../data/datasources/admin_events_remote_data_source.dart';
import '../../data/repositories/admin_events_repository_impl.dart';

// Events
abstract class AdminEventsEvent extends Equatable {
  const AdminEventsEvent();
  @override
  List<Object?> get props => [];
}

class LoadAllEvents extends AdminEventsEvent {
  final String? filter;
  const LoadAllEvents({this.filter});
  @override
  List<Object?> get props => [filter];
}

class UpdateEventStatus extends AdminEventsEvent {
  final String eventId;
  final String status;
  const UpdateEventStatus(this.eventId, this.status);
  @override
  List<Object?> get props => [eventId, status];
}

class DeleteEventAction extends AdminEventsEvent {
  final String eventId;
  const DeleteEventAction(this.eventId);
  @override
  List<Object?> get props => [eventId];
}

// States
abstract class AdminEventsState extends Equatable {
  const AdminEventsState();
  @override
  List<Object?> get props => [];
}

class AdminEventsInitial extends AdminEventsState {}

class AdminEventsLoading extends AdminEventsState {}

class AdminEventsLoaded extends AdminEventsState {
  final List<Event> events;
  final String? currentFilter;

  const AdminEventsLoaded({required this.events, this.currentFilter});

  @override
  List<Object?> get props => [events, currentFilter];
}

class AdminEventsError extends AdminEventsState {
  final String message;
  const AdminEventsError(this.message);
  @override
  List<Object?> get props => [message];
}

class AdminEventsActionSuccess extends AdminEventsState {
  final String message;
  const AdminEventsActionSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class AdminEventsBloc extends Bloc<AdminEventsEvent, AdminEventsState> {
  final AdminEventsRepositoryImpl _repository;
  String? _currentFilter;

  AdminEventsBloc()
    : _repository = AdminEventsRepositoryImpl(AdminEventsRemoteDataSource()),
      super(AdminEventsInitial()) {
    on<LoadAllEvents>(_onLoadAllEvents);
    on<UpdateEventStatus>(_onUpdateEventStatus);
    on<DeleteEventAction>(_onDeleteEvent);
  }

  Future<void> _onLoadAllEvents(
    LoadAllEvents event,
    Emitter<AdminEventsState> emit,
  ) async {
    emit(AdminEventsLoading());
    try {
      _currentFilter = event.filter;
      final events = await _repository.getEvents(filter: event.filter);
      emit(AdminEventsLoaded(events: events, currentFilter: event.filter));
    } catch (e) {
      emit(AdminEventsError(e.toString()));
    }
  }

  Future<void> _onUpdateEventStatus(
    UpdateEventStatus event,
    Emitter<AdminEventsState> emit,
  ) async {
    try {
      await _repository.updateEventStatus(event.eventId, event.status);
      emit(AdminEventsActionSuccess('Status event berhasil diupdate'));
      add(LoadAllEvents(filter: _currentFilter));
    } catch (e) {
      emit(AdminEventsError(e.toString()));
    }
  }

  Future<void> _onDeleteEvent(
    DeleteEventAction event,
    Emitter<AdminEventsState> emit,
  ) async {
    try {
      await _repository.deleteEvent(event.eventId);
      emit(const AdminEventsActionSuccess('Event berhasil dihapus'));
      add(LoadAllEvents(filter: _currentFilter));
    } catch (e) {
      emit(AdminEventsError(e.toString()));
    }
  }
}
