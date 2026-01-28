import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/event_booking.dart';
import '../../domain/entities/event_booking_ticket.dart';
import '../../domain/usecases/get_user_event_bookings.dart';
import '../../domain/usecases/get_event_booking_tickets.dart';

// Events
abstract class MyTicketsEvent extends Equatable {
  const MyTicketsEvent();
  @override
  List<Object?> get props => [];
}

class GetMyBookings extends MyTicketsEvent {
  final String userId;
  const GetMyBookings(this.userId);
  @override
  List<Object?> get props => [userId];
}

class GetMyBookingTickets extends MyTicketsEvent {
  final String bookingId;
  const GetMyBookingTickets(this.bookingId);
  @override
  List<Object?> get props => [bookingId];
}

// States
abstract class MyTicketsState extends Equatable {
  const MyTicketsState();
  @override
  List<Object?> get props => [];
}

class MyTicketsInitial extends MyTicketsState {}

class MyTicketsLoading extends MyTicketsState {}

class MyBookingsLoaded extends MyTicketsState {
  final List<EventBooking> bookings;
  const MyBookingsLoaded(this.bookings);
  @override
  List<Object?> get props => [bookings];
}

class MyBookingTicketsLoaded extends MyTicketsState {
  final List<EventBookingTicket> tickets;
  const MyBookingTicketsLoaded(this.tickets);
  @override
  List<Object?> get props => [tickets];
}

class MyTicketsFailure extends MyTicketsState {
  final String message;
  const MyTicketsFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class MyTicketsBloc extends Bloc<MyTicketsEvent, MyTicketsState> {
  final GetUserEventBookings getUserEventBookings;
  final GetEventBookingTickets getEventBookingTickets;

  MyTicketsBloc({
    required this.getUserEventBookings,
    required this.getEventBookingTickets,
  }) : super(MyTicketsInitial()) {
    on<GetMyBookings>(_onGetMyBookings);
    on<GetMyBookingTickets>(_onGetMyBookingTickets);
  }

  Future<void> _onGetMyBookings(
    GetMyBookings event,
    Emitter<MyTicketsState> emit,
  ) async {
    emit(MyTicketsLoading());
    try {
      final bookings = await getUserEventBookings(event.userId);
      emit(MyBookingsLoaded(bookings));
    } catch (e) {
      emit(MyTicketsFailure(e.toString()));
    }
  }

  Future<void> _onGetMyBookingTickets(
    GetMyBookingTickets event,
    Emitter<MyTicketsState> emit,
  ) async {
    emit(MyTicketsLoading());
    try {
      final tickets = await getEventBookingTickets(event.bookingId);
      emit(MyBookingTicketsLoaded(tickets));
    } catch (e) {
      emit(MyTicketsFailure(e.toString()));
    }
  }
}
