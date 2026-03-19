import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/event_winner_entity.dart';
import '../../domain/entities/event_prize_entity.dart';
import '../../data/data_sources/event_doorprize_remote_data_source.dart';
import '../../data/models/event_winner_model.dart';
import '../../data/models/event_prize_model.dart';

part 'admin_doorprize_cubit.freezed.dart';

// ============ State ============

@freezed
sealed class AdminDoorprizeState with _$AdminDoorprizeState {
  const factory AdminDoorprizeState.initial() = _Initial;
  const factory AdminDoorprizeState.loading() = _Loading;
  const factory AdminDoorprizeState.loaded({
    required List<EventWinnerEntity> winners,
    required List<EventPrizeEntity> prizes,
  }) = AdminDoorprizeLoaded;
  const factory AdminDoorprizeState.error(String message) = _Error;
}

// ============ Cubit ============

class AdminDoorprizeCubit extends Cubit<AdminDoorprizeState> {
  final EventDoorprizeRemoteDataSource _dataSource;
  final String eventId;

  AdminDoorprizeCubit({
    required EventDoorprizeRemoteDataSource dataSource,
    required this.eventId,
  }) : _dataSource = dataSource,
       super(const AdminDoorprizeState.initial());

  Future<void> loadData() async {
    emit(const AdminDoorprizeState.loading());
    try {
      final winners = await _dataSource.getWinnersByEvent(eventId);
      final prizes = await _dataSource.getPrizes(eventId);
      emit(
        AdminDoorprizeState.loaded(
          winners: winners.map((m) => m.toEntity()).toList(),
          prizes: prizes.map((m) => m.toEntity()).toList(),
        ),
      );
    } catch (e) {
      emit(AdminDoorprizeState.error(e.toString()));
    }
  }

  Future<void> recordWinner({
    required String prizeId,
    required String bookingTicketId,
  }) async {
    try {
      final model = EventWinnerModel(
        id: '',
        event: eventId,
        prizeId: prizeId,
        bookingTicketId: bookingTicketId,
        status: 'won',
      );
      await _dataSource.createWinner(model);
      await loadData();
    } catch (e) {
      emit(AdminDoorprizeState.error('Gagal menyimpan pemenang: $e'));
    }
  }

  Future<void> disqualifyWinner(String winnerId) async {
    try {
      await _dataSource.updateWinnerStatus(winnerId, 'disqualified');
      await loadData();
    } catch (e) {
      emit(AdminDoorprizeState.error('Gagal mendiskualifikasi pemenang: $e'));
    }
  }

  Future<void> deleteWinner(String winnerId) async {
    try {
      await _dataSource.deleteWinner(winnerId);
      await loadData();
    } catch (e) {
      emit(AdminDoorprizeState.error('Gagal menghapus pemenang: $e'));
    }
  }

  Future<void> addPrize({
    required String name,
    required int quantity,
  }) async {
    try {
      final model = EventPrizeModel(
        id: '',
        event: eventId,
        name: name,
        quantity: quantity,
      );
      await _dataSource.createPrize(model);
      await loadData();
    } catch (e) {
      emit(AdminDoorprizeState.error('Gagal menambah hadiah: $e'));
    }
  }

  Future<void> updatePrize({
    required String id,
    required String name,
    required int quantity,
  }) async {
    try {
      final model = EventPrizeModel(
        id: id,
        event: eventId,
        name: name,
        quantity: quantity,
      );
      await _dataSource.updatePrize(id, model);
      await loadData();
    } catch (e) {
      emit(AdminDoorprizeState.error('Gagal mengubah hadiah: $e'));
    }
  }

  Future<void> deletePrize(String prizeId) async {
    try {
      await _dataSource.deletePrize(prizeId);
      await loadData();
    } catch (e) {
      emit(AdminDoorprizeState.error('Gagal menghapus hadiah: $e'));
    }
  }
}
