import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../../core/network/pb_client.dart';

// Events
abstract class AdminStatsEvent extends Equatable {
  const AdminStatsEvent();
  @override
  List<Object?> get props => [];
}

class LoadAdminStats extends AdminStatsEvent {
  const LoadAdminStats();
}

// States
abstract class AdminStatsState extends Equatable {
  const AdminStatsState();
  @override
  List<Object?> get props => [];
}

class AdminStatsInitial extends AdminStatsState {}

class AdminStatsLoading extends AdminStatsState {}

class AdminStatsLoaded extends AdminStatsState {
  final int totalUsers;
  final int pendingUsers;
  final int totalEvents;
  final int activeEvents;
  final int totalDonations;
  final int totalNews;
  final int pendingLokers;
  final int pendingMarkets;
  final int pendingMemories;

  const AdminStatsLoaded({
    required this.totalUsers,
    required this.pendingUsers,
    required this.totalEvents,
    required this.activeEvents,
    required this.totalDonations,
    required this.totalNews,
    required this.pendingLokers,
    required this.pendingMarkets,
    required this.pendingMemories,
  });

  @override
  List<Object?> get props => [
    totalUsers,
    pendingUsers,
    totalEvents,
    activeEvents,
    totalDonations,
    totalNews,
    pendingLokers,
    pendingMarkets,
    pendingMemories,
  ];
}

class AdminStatsError extends AdminStatsState {
  final String message;
  const AdminStatsError(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class AdminStatsBloc extends Bloc<AdminStatsEvent, AdminStatsState> {
  AdminStatsBloc() : super(AdminStatsInitial()) {
    on<LoadAdminStats>(_onLoadStats);
  }

  Future<void> _onLoadStats(
    LoadAdminStats event,
    Emitter<AdminStatsState> emit,
  ) async {
    emit(AdminStatsLoading());

    try {
      final pb = PBClient.instance.pb;

      // Fetch stats in parallel
      final results = await Future.wait([
        pb.collection('users').getList(page: 1, perPage: 1),
        pb
            .collection('users')
            .getList(page: 1, perPage: 1, filter: 'is_verified = false'),
        pb.collection('events').getList(page: 1, perPage: 1),
        pb
            .collection('events')
            .getList(page: 1, perPage: 1, filter: 'status = "active"'),
        pb.collection('donations').getList(page: 1, perPage: 1),
        pb.collection('news').getList(page: 1, perPage: 1),
        pb
            .collection('loker')
            .getList(page: 1, perPage: 1, filter: 'status = "pending"'),
        pb
            .collection('market')
            .getList(page: 1, perPage: 1, filter: 'status = "pending"'),
        pb
            .collection('memories')
            .getList(page: 1, perPage: 1, filter: 'is_approved = false'),
      ]);

      emit(
        AdminStatsLoaded(
          totalUsers: results[0].totalItems,
          pendingUsers: results[1].totalItems,
          totalEvents: results[2].totalItems,
          activeEvents: results[3].totalItems,
          totalDonations: results[4].totalItems,
          totalNews: results[5].totalItems,
          pendingLokers: results[6].totalItems,
          pendingMarkets: results[7].totalItems,
          pendingMemories: results[8].totalItems,
        ),
      );
    } catch (e) {
      emit(AdminStatsError(e.toString()));
    }
  }
}
