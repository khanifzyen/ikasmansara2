import 'dart:io';
import 'package:http/http.dart' as http;
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

class UpdateEvent extends AdminEventsEvent {
  final String eventId;
  final Map<String, dynamic> data;
  final File? bannerFile;
  const UpdateEvent(this.eventId, this.data, {this.bannerFile});
  @override
  List<Object?> get props => [eventId, data, bannerFile];
}

class CreateEvent extends AdminEventsEvent {
  final Map<String, dynamic> eventData;
  final File? bannerFile;
  final List<Map<String, dynamic>> tickets;

  const CreateEvent({
    required this.eventData,
    this.bannerFile,
    required this.tickets,
  });

  @override
  List<Object?> get props => [eventData, bannerFile, tickets];
}

class LoadEventDetail extends AdminEventsEvent {
  final String eventId;
  const LoadEventDetail(this.eventId);
  @override
  List<Object?> get props => [eventId];
}

class AdminEventLoaded extends AdminEventsState {
  final Event event;
  const AdminEventLoaded(this.event);
  @override
  List<Object?> get props => [event];
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
    on<AdminEventsEvent>(
      (event, emit) {},
    ); // Placeholder for base if needed, but not common
    on<LoadAllEvents>(_onLoadAllEvents);
    on<UpdateEventStatus>(_onUpdateEventStatus);
    on<DeleteEventAction>(_onDeleteEvent);
    on<UpdateEvent>(_onUpdateEvent);
    on<CreateEvent>(_onCreateEvent);
    on<LoadEventDetail>(_onLoadEventDetail);
  }

  Future<void> _onCreateEvent(
    CreateEvent event,
    Emitter<AdminEventsState> emit,
  ) async {
    emit(AdminEventsLoading());
    try {
      final Map<String, dynamic> eventBody = Map.from(event.eventData);
      if (event.bannerFile != null) {
        eventBody['banner'] = await http.MultipartFile.fromPath(
          'banner',
          event.bannerFile!.path,
        );
      }

      final createdEvent = await _repository.createEvent(eventBody);

      for (final ticket in event.tickets) {
        final ticketBody = Map<String, dynamic>.from(ticket);
        ticketBody['event'] = createdEvent.id;
        await _repository.createEventTicket(ticketBody);
      }

      emit(const AdminEventsActionSuccess('Event berhasil dibuat'));
      add(LoadAllEvents(filter: _currentFilter));
    } catch (e) {
      emit(AdminEventsError(e.toString()));
    }
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

  Future<void> _onLoadEventDetail(
    LoadEventDetail event,
    Emitter<AdminEventsState> emit,
  ) async {
    emit(AdminEventsLoading());
    try {
      final eventDetail = await _repository.getEventById(event.eventId);
      emit(AdminEventLoaded(eventDetail));
    } catch (e) {
      emit(AdminEventsError(e.toString()));
    }
  }

  Future<void> _onUpdateEvent(
    UpdateEvent event,
    Emitter<AdminEventsState> emit,
  ) async {
    emit(AdminEventsLoading());
    try {
      final Map<String, dynamic> body = Map.from(event.data);
      if (event.bannerFile != null) {
        body['banner'] = await http.MultipartFile.fromPath(
          'banner',
          event.bannerFile!.path,
        );
      }
      await _repository.updateEvent(event.eventId, body);
      emit(const AdminEventsActionSuccess('Event berhasil diupdate'));
      add(LoadEventDetail(event.eventId));
    } catch (e) {
      emit(AdminEventsError(e.toString()));
    }
  }

  Future<void> _onUpdateEventStatus(
    UpdateEventStatus event,
    Emitter<AdminEventsState> emit,
  ) async {
    emit(AdminEventsLoading());
    try {
      await _repository.updateEventStatus(event.eventId, event.status);
      emit(const AdminEventsActionSuccess('Status event berhasil diupdate'));
      // If we are in detail view, we might want to refresh detail too,
      // but status change is usually from list view.
      // If it's from detail view, LoadEventDetail is better.
      // For now, let's refresh both to be safe or just LoadAll if list.
      add(LoadAllEvents(filter: _currentFilter));
    } catch (e) {
      emit(AdminEventsError(e.toString()));
    }
  }

  Future<void> _onDeleteEvent(
    DeleteEventAction event,
    Emitter<AdminEventsState> emit,
  ) async {
    emit(AdminEventsLoading());
    try {
      await _repository.deleteEvent(event.eventId);
      emit(const AdminEventsActionSuccess('Event berhasil dihapus'));
      add(LoadAllEvents(filter: _currentFilter));
    } catch (e) {
      emit(AdminEventsError(e.toString()));
    }
  }
}
