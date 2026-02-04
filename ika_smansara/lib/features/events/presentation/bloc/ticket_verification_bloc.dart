import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/event_booking_ticket.dart';
import '../../domain/repositories/event_repository.dart';

// Events
abstract class TicketVerificationEvent extends Equatable {
  const TicketVerificationEvent();
}

class VerifyTicket extends TicketVerificationEvent {
  final String qrData;

  const VerifyTicket(this.qrData);

  @override
  List<Object> get props => [qrData];
}

class ResetVerification extends TicketVerificationEvent {
  @override
  List<Object> get props => [];
}

// States
abstract class TicketVerificationState extends Equatable {
  const TicketVerificationState();

  @override
  List<Object> get props => [];
}

class TicketVerificationInitial extends TicketVerificationState {}

class TicketVerificationLoading extends TicketVerificationState {}

class TicketVerificationValid extends TicketVerificationState {
  final EventBookingTicket ticket;

  const TicketVerificationValid(this.ticket);

  @override
  List<Object> get props => [ticket];
}

class TicketVerificationInvalid extends TicketVerificationState {
  final String message;

  const TicketVerificationInvalid(this.message);

  @override
  List<Object> get props => [message];
}

class TicketVerificationBloc
    extends Bloc<TicketVerificationEvent, TicketVerificationState> {
  final EventRepository _repository;

  TicketVerificationBloc(this._repository)
    : super(TicketVerificationInitial()) {
    on<VerifyTicket>(_onVerifyTicket);
    on<ResetVerification>((event, emit) => emit(TicketVerificationInitial()));
  }

  Future<void> _onVerifyTicket(
    VerifyTicket event,
    Emitter<TicketVerificationState> emit,
  ) async {
    emit(TicketVerificationLoading());
    try {
      // Expected format: RECORD_ID:TICKET_CODE or just RECORD_ID depending on QR gen.
      // Based on previous conv, it seems we use "id:ticket_id".
      // Let's split and verify.

      final parts = event.qrData.split(':');
      if (parts.isEmpty) {
        emit(const TicketVerificationInvalid('Format QR Code tidak valid'));
        return;
      }

      final recordId = parts[0];
      // We could also verify parts[1] (ticketCode) matches the fetched record.

      final ticket = await _repository.verifyTicket(recordId);

      // If parts has ticket code, verify it matches
      if (parts.length > 1) {
        if (ticket.ticketCode != parts[1]) {
          emit(
            const TicketVerificationInvalid(
              'Kode tiket tidak cocok dengan data',
            ),
          );
          return;
        }
      }

      emit(TicketVerificationValid(ticket));
    } catch (e) {
      log.error('TicketVerificationBloc: Verification failed', error: e);
      emit(
        const TicketVerificationInvalid(
          'Tiket tidak ditemukan atau tidak valid',
        ),
      );
    }
  }
}
