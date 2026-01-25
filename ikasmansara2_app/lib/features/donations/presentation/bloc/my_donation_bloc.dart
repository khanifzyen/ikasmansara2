import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/donation_transaction.dart';
import '../../domain/usecases/get_my_donations.dart';

// Events
abstract class MyDonationEvent extends Equatable {
  const MyDonationEvent();
  @override
  List<Object> get props => [];
}

class FetchMyDonations extends MyDonationEvent {}

// States
abstract class MyDonationState extends Equatable {
  const MyDonationState();
  @override
  List<Object> get props => [];
}

class MyDonationInitial extends MyDonationState {}

class MyDonationLoading extends MyDonationState {}

class MyDonationLoaded extends MyDonationState {
  final List<DonationTransaction> transactions;
  const MyDonationLoaded(this.transactions);
  @override
  List<Object> get props => [transactions];
}

class MyDonationError extends MyDonationState {
  final String message;
  const MyDonationError(this.message);
  @override
  List<Object> get props => [message];
}

// BLoC
class MyDonationBloc extends Bloc<MyDonationEvent, MyDonationState> {
  final GetMyDonations getMyDonations;

  MyDonationBloc(this.getMyDonations) : super(MyDonationInitial()) {
    on<FetchMyDonations>((event, emit) async {
      emit(MyDonationLoading());
      try {
        final transactions = await getMyDonations();
        emit(MyDonationLoaded(transactions));
      } catch (e) {
        emit(MyDonationError(e.toString()));
      }
    });
  }
}
