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

class SearchParticipants extends AdminParticipantsEvent {
  final String eventId;
  final String searchField;
  final String searchQuery;

  const SearchParticipants({
    required this.eventId,
    required this.searchField,
    required this.searchQuery,
  });
  @override
  List<Object?> get props => [eventId, searchField, searchQuery];
}

class LoadMoreParticipants extends AdminParticipantsEvent {
  final String eventId;
  const LoadMoreParticipants(this.eventId);
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
  final bool hasReachedMax;
  final int currentPage;
  final String searchField;
  final String searchQuery;

  const AdminParticipantsLoaded({
    required this.bookings,
    this.selectedBookingTickets,
    this.loadingBookingId,
    this.availableTickets,
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.searchField = 'name',
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [
    bookings,
    selectedBookingTickets,
    loadingBookingId,
    availableTickets,
    hasReachedMax,
    currentPage,
    searchField,
    searchQuery,
  ];

  AdminParticipantsLoaded copyWith({
    List<EventBooking>? bookings,
    List<EventBookingTicket>? selectedBookingTickets,
    String? loadingBookingId,
    List<EventTicket>? availableTickets,
    bool? hasReachedMax,
    int? currentPage,
    String? searchField,
    String? searchQuery,
  }) {
    return AdminParticipantsLoaded(
      bookings: bookings ?? this.bookings,
      selectedBookingTickets:
          selectedBookingTickets ?? this.selectedBookingTickets,
      loadingBookingId: loadingBookingId ?? this.loadingBookingId,
      availableTickets: availableTickets ?? this.availableTickets,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      searchField: searchField ?? this.searchField,
      searchQuery: searchQuery ?? this.searchQuery,
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
    on<SearchParticipants>(_onSearchParticipants);
    on<LoadMoreParticipants>(_onLoadMoreParticipants);
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
      final bookings = await _repository.getEventBookings(
        event.eventId,
        page: 1,
        perPage: 25,
      );
      emit(
        AdminParticipantsLoaded(
          bookings: bookings,
          hasReachedMax: bookings.length < 25,
          currentPage: 1,
        ),
      );
    } catch (e) {
      emit(AdminParticipantsError(e.toString()));
    }
  }

  Future<void> _onSearchParticipants(
    SearchParticipants event,
    Emitter<AdminParticipantsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AdminParticipantsLoaded) return;

    emit(AdminParticipantsLoading());
    try {
      final bookings = await _repository.getEventBookings(
        event.eventId,
        page: 1,
        perPage: 25,
        searchField: event.searchField,
        searchQuery: event.searchQuery,
      );
      emit(
        currentState.copyWith(
          bookings: bookings,
          hasReachedMax: bookings.length < 25,
          currentPage: 1,
          searchField: event.searchField,
          searchQuery: event.searchQuery,
        ),
      );
    } catch (e) {
      emit(AdminParticipantsError(e.toString()));
    }
  }

  Future<void> _onLoadMoreParticipants(
    LoadMoreParticipants event,
    Emitter<AdminParticipantsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AdminParticipantsLoaded) return;
    if (currentState.hasReachedMax) return;

    try {
      final nextPage = currentState.currentPage + 1;
      final newBookings = await _repository.getEventBookings(
        event.eventId,
        page: nextPage,
        perPage: 25,
        searchField: currentState.searchField,
        searchQuery: currentState.searchQuery,
      );

      if (newBookings.isEmpty) {
        emit(currentState.copyWith(hasReachedMax: true));
      } else {
        emit(
          currentState.copyWith(
            bookings: List.of(currentState.bookings)..addAll(newBookings),
            hasReachedMax: newBookings.length < 25,
            currentPage: nextPage,
          ),
        );
      }
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
