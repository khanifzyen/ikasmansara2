import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/event_booking.dart';
import '../../domain/usecases/create_event_booking.dart';

// Events
abstract class EventBookingEvent extends Equatable {
  const EventBookingEvent();

  @override
  List<Object> get props => [];
}

class CreateBooking extends EventBookingEvent {
  final String eventId;
  final List<Map<String, dynamic>> metadata;
  final int totalPrice;
  final String paymentMethod;

  const CreateBooking({
    required this.eventId,
    required this.metadata,
    required this.totalPrice,
    required this.paymentMethod,
  });

  @override
  List<Object> get props => [eventId, metadata, totalPrice, paymentMethod];
}

// States
abstract class EventBookingState extends Equatable {
  const EventBookingState();

  @override
  List<Object?> get props => [];
}

class EventBookingInitial extends EventBookingState {}

class EventBookingLoading extends EventBookingState {}

class EventBookingSuccess extends EventBookingState {
  final EventBooking booking;

  const EventBookingSuccess(this.booking);

  @override
  List<Object?> get props => [booking];
}

class EventBookingFailure extends EventBookingState {
  final String message;

  const EventBookingFailure(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class EventBookingBloc extends Bloc<EventBookingEvent, EventBookingState> {
  final CreateEventBooking createEventBooking;

  EventBookingBloc(this.createEventBooking) : super(EventBookingInitial()) {
    on<CreateBooking>(_onCreateBooking);
  }

  Future<void> _onCreateBooking(
    CreateBooking event,
    Emitter<EventBookingState> emit,
  ) async {
    emit(EventBookingLoading());
    try {
      final booking = await createEventBooking(
        eventId: event.eventId,
        metadata: event.metadata,
        totalPrice: event.totalPrice,
        paymentMethod: event.paymentMethod,
      );
      emit(EventBookingSuccess(booking));
    } catch (e) {
      emit(EventBookingFailure(e.toString()));
    }
  }
}
