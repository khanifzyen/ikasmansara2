import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/event_booking.dart';
import '../../domain/entities/event_booking_ticket.dart';
import '../../domain/usecases/get_user_event_bookings.dart';
import '../../domain/usecases/get_event_booking_tickets.dart';
import '../../domain/usecases/cancel_booking.dart';
import '../../domain/usecases/delete_booking.dart';

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

class CancelEventBooking extends MyTicketsEvent {
  final String bookingId;
  final String userId;
  const CancelEventBooking(this.bookingId, this.userId);
  @override
  List<Object?> get props => [bookingId, userId];
}

class DeleteEventBooking extends MyTicketsEvent {
  final String bookingId;
  final String userId;
  const DeleteEventBooking(this.bookingId, this.userId);
  @override
  List<Object?> get props => [bookingId, userId];
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
  final CancelBooking cancelBooking;
  final DeleteBooking deleteBooking;

  MyTicketsBloc({
    required this.getUserEventBookings,
    required this.getEventBookingTickets,
    required this.cancelBooking,
    required this.deleteBooking,
  }) : super(MyTicketsInitial()) {
    on<GetMyBookings>(_onGetMyBookings);
    on<GetMyBookingTickets>(_onGetMyBookingTickets);
    on<CancelEventBooking>(_onCancelEventBooking);
    on<DeleteEventBooking>(_onDeleteEventBooking);
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
      log.error('MyTicketsBloc: Failed to fetch user bookings', error: e);
      emit(const MyTicketsFailure('Gagal memuat tiket. Silakan coba lagi.'));
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
      log.error('MyTicketsBloc: Failed to fetch booking tickets', error: e);
      emit(const MyTicketsFailure('Gagal memuat detail tiket.'));
    }
  }

  Future<void> _onCancelEventBooking(
    CancelEventBooking event,
    Emitter<MyTicketsState> emit,
  ) async {
    // Optimistic or loading state? For simple lists, just reloading is safer.
    emit(MyTicketsLoading());
    try {
      await cancelBooking(event.bookingId);
      // Reload list
      add(GetMyBookings(event.userId));
    } catch (e) {
      log.error('MyTicketsBloc: Failed to cancel booking', error: e);
      emit(const MyTicketsFailure('Gagal membatalkan pesanan.'));
    }
  }

  Future<void> _onDeleteEventBooking(
    DeleteEventBooking event,
    Emitter<MyTicketsState> emit,
  ) async {
    emit(MyTicketsLoading());
    try {
      await deleteBooking(event.bookingId);
      // Reload list
      add(GetMyBookings(event.userId));
    } catch (e) {
      log.error('MyTicketsBloc: Failed to delete booking', error: e);
      emit(const MyTicketsFailure('Gagal menghapus pesanan.'));
    }
  }
}
