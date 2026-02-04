import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/donation.dart';
import '../../domain/usecases/get_donations.dart';

// Events
abstract class DonationListEvent extends Equatable {
  const DonationListEvent();
  @override
  List<Object> get props => [];
}

class FetchDonations extends DonationListEvent {}

// States
abstract class DonationListState extends Equatable {
  const DonationListState();
  @override
  List<Object> get props => [];
}

class DonationListInitial extends DonationListState {}

class DonationListLoading extends DonationListState {}

class DonationListLoaded extends DonationListState {
  final List<Donation> donations;
  const DonationListLoaded(this.donations);
  @override
  List<Object> get props => [donations];
}

class DonationListError extends DonationListState {
  final String message;
  const DonationListError(this.message);
  @override
  List<Object> get props => [message];
}

// BLoC
class DonationListBloc extends Bloc<DonationListEvent, DonationListState> {
  final GetDonations getDonations;

  DonationListBloc(this.getDonations) : super(DonationListInitial()) {
    on<FetchDonations>((event, emit) async {
      log.debug('DonationListBloc -> FetchDonations');
      emit(DonationListLoading());
      try {
        final donations = await getDonations();
        log.debug('DonationListBloc -> Loaded ${donations.length} items');
        emit(DonationListLoaded(donations));
      } catch (e) {
        log.error('DonationListBloc -> Error fetching donations', error: e);
        emit(const DonationListError('Gagal memuat daftar donasi.'));
      }
    });
  }
}
