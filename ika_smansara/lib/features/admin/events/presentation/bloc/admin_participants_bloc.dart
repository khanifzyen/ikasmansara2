import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../events/domain/entities/event_booking.dart';
import '../../../../events/domain/entities/event_booking_ticket.dart';
import '../../../../events/domain/entities/event_ticket.dart';
import '../../domain/repositories/admin_events_repository.dart';
import '../../data/datasources/admin_events_remote_data_source.dart';
import '../../data/repositories/admin_events_repository_impl.dart';

// Events
abstract class AdminParticipantsEvent extends Equatable {
  const AdminParticipantsEvent();
  @override
  List<Object?> get props => [];
}

class LoadParticipants extends AdminParticipantsEvent {
  final String eventId;
  const LoadParticipants(this.eventId);
  @override
  List<Object?> get props => [eventId];
}

class UpdateParticipantStatus extends AdminParticipantsEvent {
  final String eventId;
  final String bookingId;
  final String status;
  const UpdateParticipantStatus({
    required this.eventId,
    required this.bookingId,
    required this.status,
  });
  @override
  List<Object?> get props => [eventId, bookingId, status];
}

class CreateManualBookingAction extends AdminParticipantsEvent {
  final String eventId;
  final Map<String, dynamic> data;
  const CreateManualBookingAction({required this.eventId, required this.data});
  @override
  List<Object?> get props => [eventId, data];
}

class LoadBookingTickets extends AdminParticipantsEvent {
  final String bookingId;
  const LoadBookingTickets(this.bookingId);
  @override
  List<Object?> get props => [bookingId];
}

class LoadTickets extends AdminParticipantsEvent {
  final String eventId;
  const LoadTickets(this.eventId);
  @override
  List<Object?> get props => [eventId];
}

// States
abstract class AdminParticipantsState extends Equatable {
  const AdminParticipantsState();
  @override
  List<Object?> get props => [];
}

class AdminParticipantsInitial extends AdminParticipantsState {}

class AdminParticipantsLoading extends AdminParticipantsState {}

class AdminParticipantsLoaded extends AdminParticipantsState {
  final List<EventBooking> bookings;
  final List<EventBookingTicket>? selectedBookingTickets;
  final String? loadingBookingId;
  final List<EventTicket>? availableTickets;

  const AdminParticipantsLoaded({
    required this.bookings,
    this.selectedBookingTickets,
    this.loadingBookingId,
    this.availableTickets,
  });

  @override
  List<Object?> get props => [
    bookings,
    selectedBookingTickets,
    loadingBookingId,
    availableTickets,
  ];

  AdminParticipantsLoaded copyWith({
    List<EventBooking>? bookings,
    List<EventBookingTicket>? selectedBookingTickets,
    String? loadingBookingId,
    List<EventTicket>? availableTickets,
  }) {
    return AdminParticipantsLoaded(
      bookings: bookings ?? this.bookings,
      selectedBookingTickets:
          selectedBookingTickets ?? this.selectedBookingTickets,
      loadingBookingId: loadingBookingId ?? this.loadingBookingId,
      availableTickets: availableTickets ?? this.availableTickets,
    );
  }
}

class AdminParticipantsError extends AdminParticipantsState {
  final String message;
  const AdminParticipantsError(this.message);
  @override
  List<Object?> get props => [message];
}

class AdminParticipantsActionSuccess extends AdminParticipantsState {
  final String message;
  const AdminParticipantsActionSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class AdminParticipantsBloc
    extends Bloc<AdminParticipantsEvent, AdminParticipantsState> {
  final AdminEventsRepository _repository;

  AdminParticipantsBloc()
    : _repository = AdminEventsRepositoryImpl(AdminEventsRemoteDataSource()),
      super(AdminParticipantsInitial()) {
    on<LoadParticipants>(_onLoadParticipants);
    on<UpdateParticipantStatus>(_onUpdateParticipantStatus);
    on<CreateManualBookingAction>(_onCreateManualBooking);
    on<LoadBookingTickets>(_onLoadBookingTickets);
    on<LoadTickets>(_onLoadTickets);
  }

  Future<void> _onLoadParticipants(
    LoadParticipants event,
    Emitter<AdminParticipantsState> emit,
  ) async {
    emit(AdminParticipantsLoading());
    try {
      final bookings = await _repository.getEventBookings(event.eventId);
      emit(AdminParticipantsLoaded(bookings: bookings));
    } catch (e) {
      emit(AdminParticipantsError(e.toString()));
    }
  }

  Future<void> _onUpdateParticipantStatus(
    UpdateParticipantStatus event,
    Emitter<AdminParticipantsState> emit,
  ) async {
    final currentState = state;
    if (currentState is AdminParticipantsLoaded) {
      emit(currentState.copyWith(loadingBookingId: event.bookingId));
    }

    try {
      await _repository.updateBookingStatus(event.bookingId, event.status);
      emit(
        AdminParticipantsActionSuccess('Status pembayaran berhasil diperbarui'),
      );
      add(LoadParticipants(event.eventId));
    } catch (e) {
      emit(AdminParticipantsError(e.toString()));
    }
  }

  Future<void> _onCreateManualBooking(
    CreateManualBookingAction event,
    Emitter<AdminParticipantsState> emit,
  ) async {
    emit(AdminParticipantsLoading());
    try {
      await _repository.createManualBooking(event.data);
      emit(
        const AdminParticipantsActionSuccess(
          'Pendaftaran manual berhasil dibuat',
        ),
      );
      add(LoadParticipants(event.eventId));
    } catch (e) {
      emit(AdminParticipantsError(e.toString()));
    }
  }

  Future<void> _onLoadBookingTickets(
    LoadBookingTickets event,
    Emitter<AdminParticipantsState> emit,
  ) async {
    final currentState = state;
    if (currentState is AdminParticipantsLoaded) {
      try {
        final tickets = await _repository.getEventBookingTickets(
          event.bookingId,
        );
        emit(currentState.copyWith(selectedBookingTickets: tickets));
      } catch (e) {
        emit(AdminParticipantsError(e.toString()));
      }
    }
  }

  Future<void> _onLoadTickets(
    LoadTickets event,
    Emitter<AdminParticipantsState> emit,
  ) async {
    final currentState = state;
    if (currentState is AdminParticipantsLoaded) {
      try {
        final tickets = await _repository.getEventTickets(event.eventId);
        emit(currentState.copyWith(availableTickets: tickets));
      } catch (e) {
        emit(AdminParticipantsError(e.toString()));
      }
    }
  }
}
