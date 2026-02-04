import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/donation.dart';
import '../../domain/entities/donation_transaction.dart';
import '../../domain/usecases/get_donation_detail.dart';
import '../../domain/usecases/get_donation_transactions.dart';
import '../../domain/usecases/create_donation_transaction.dart';

// Events
abstract class DonationDetailEvent extends Equatable {
  const DonationDetailEvent();
  @override
  List<Object?> get props => [];
}

class FetchDonationDetail extends DonationDetailEvent {
  final String id;
  const FetchDonationDetail(this.id);
  @override
  List<Object?> get props => [id];
}

class CreateTransactionEvent extends DonationDetailEvent {
  final String donationId;
  final double amount;
  final String donorName;
  final bool isAnonymous;
  final String? message;
  final String? paymentMethod;

  const CreateTransactionEvent({
    required this.donationId,
    required this.amount,
    required this.donorName,
    required this.isAnonymous,
    this.message,
    this.paymentMethod,
  });

  @override
  List<Object?> get props => [
    donationId,
    amount,
    donorName,
    isAnonymous,
    message,
    paymentMethod,
  ];
}

// States
abstract class DonationDetailState extends Equatable {
  const DonationDetailState();
  @override
  List<Object?> get props => [];
}

class DonationDetailInitial extends DonationDetailState {}

class DonationDetailLoading extends DonationDetailState {}

class DonationDetailLoaded extends DonationDetailState {
  final Donation donation;
  final List<DonationTransaction> recentTransactions;

  const DonationDetailLoaded({
    required this.donation,
    required this.recentTransactions,
  });

  @override
  List<Object?> get props => [donation, recentTransactions];

  DonationDetailLoaded copyWith({
    Donation? donation,
    List<DonationTransaction>? recentTransactions,
  }) {
    return DonationDetailLoaded(
      donation: donation ?? this.donation,
      recentTransactions: recentTransactions ?? this.recentTransactions,
    );
  }
}

class DonationDetailError extends DonationDetailState {
  final String message;
  const DonationDetailError(this.message);
  @override
  List<Object?> get props => [message];
}

class TransactionSuccess extends DonationDetailState {
  final DonationTransaction transaction;
  const TransactionSuccess(this.transaction);
  @override
  List<Object?> get props => [transaction];
}

class TransactionLoading extends DonationDetailState {}

class TransactionError extends DonationDetailState {
  final String message;
  const TransactionError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class DonationDetailBloc
    extends Bloc<DonationDetailEvent, DonationDetailState> {
  final GetDonationDetail getDonationDetail;
  final GetDonationTransactions getDonationTransactions;
  final CreateDonationTransaction createDonationTransaction;

  DonationDetailBloc({
    required this.getDonationDetail,
    required this.getDonationTransactions,
    required this.createDonationTransaction,
  }) : super(DonationDetailInitial()) {
    on<FetchDonationDetail>((event, emit) async {
      log.debug('DonationDetailBloc -> FetchDonationDetail(${event.id})');
      emit(DonationDetailLoading());
      try {
        final donation = await getDonationDetail(event.id);
        final transactions = await getDonationTransactions(event.id);
        log.debug(
          'DonationDetailBloc -> Detail Loaded & ${transactions.length} trx',
        );
        emit(
          DonationDetailLoaded(
            donation: donation,
            recentTransactions: transactions,
          ),
        );
      } catch (e) {
        log.error('DonationDetailBloc -> Detail Error', error: e);
        emit(const DonationDetailError('Gagal memuat detail donasi.'));
      }
    });

    on<CreateTransactionEvent>((event, emit) async {
      log.debug('DonationDetailBloc -> CreateTransactionEvent');
      // Optimistically show loading or define a separate loading state for transaction
      // For simplicity, we assume the UI handles 'TransactionLoading' and then we might need to re-fetch to restore 'Loaded' state
      emit(TransactionLoading());
      try {
        final transaction = await createDonationTransaction(
          donationId: event.donationId,
          amount: event.amount,
          donorName: event.donorName,
          isAnonymous: event.isAnonymous,
          message: event.message,
          paymentMethod: event.paymentMethod,
        );
        log.debug(
          'DonationDetailBloc -> Transaction Success: ${transaction.transactionId}',
        );
        emit(TransactionSuccess(transaction));
        // Optionally, one could auto-refresh the detail here.
        // But better to let UI decide to dispatch FetchDonationDetail again.
      } catch (e) {
        log.error('DonationDetailBloc -> Transaction Error', error: e);
        emit(
          const TransactionError('Gagal memproses donasi. Silakan coba lagi.'),
        );
        // If we want to recover the previous loaded state, we'd need to store it.
        // But 'TransactionError' is specific enough.
      }
    });
  }
}
