import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/event.dart';
import '../../domain/usecases/get_events.dart';

// Events
abstract class EventsEvent extends Equatable {
  const EventsEvent();
  @override
  List<Object> get props => [];
}

class FetchEvents extends EventsEvent {
  final String? category;
  const FetchEvents({this.category});
  @override
  List<Object> get props => [category ?? ''];
}

// States
abstract class EventsState extends Equatable {
  const EventsState();
  @override
  List<Object> get props => [];
}

class EventsInitial extends EventsState {}

class EventsLoading extends EventsState {}

class EventsLoaded extends EventsState {
  final List<Event> events;
  const EventsLoaded(this.events);
  @override
  List<Object> get props => [events];
}

class EventsError extends EventsState {
  final String message;
  const EventsError(this.message);
  @override
  List<Object> get props => [message];
}

// BLoC
class EventsBloc extends Bloc<EventsEvent, EventsState> {
  final GetEvents getEvents;

  EventsBloc(this.getEvents) : super(EventsInitial()) {
    on<FetchEvents>((event, emit) async {
      log.debug(
        'EventsBloc - FetchEvents received. Category: ${event.category}',
      );
      emit(EventsLoading());
      try {
        final events = await getEvents(category: event.category);
        log.debug('EventsBloc - Successfully fetched ${events.length} events');
        emit(EventsLoaded(events));
      } catch (e) {
        log.error('EventsBloc - Error fetching events', error: e);
        emit(const EventsError('Gagal memuat daftar event.'));
      }
    });
  }
}
