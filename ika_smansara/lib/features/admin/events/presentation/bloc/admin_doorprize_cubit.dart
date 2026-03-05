import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/event_prize_entity.dart';
import '../../domain/entities/event_winner_entity.dart';
import '../../data/data_sources/event_doorprize_remote_data_source.dart';
import '../../data/models/event_prize_model.dart';
import '../../data/models/event_winner_model.dart';

part 'admin_doorprize_cubit.freezed.dart';

// ============ State ============

@freezed
sealed class AdminDoorprizeState with _$AdminDoorprizeState {
  const factory AdminDoorprizeState.initial() = _Initial;
  const factory AdminDoorprizeState.loading() = _Loading;
  const factory AdminDoorprizeState.loaded({
    required List<EventPrizeEntity> prizes,
    required List<EventWinnerEntity> winners,
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
      final prizes = await _dataSource.getPrizesByEvent(eventId);
      final winners = await _dataSource.getWinnersByEvent(eventId);
      emit(
        AdminDoorprizeState.loaded(
          prizes: prizes.map((m) => m.toEntity()).toList(),
          winners: winners.map((m) => m.toEntity()).toList(),
        ),
      );
    } catch (e) {
      emit(AdminDoorprizeState.error(e.toString()));
    }
  }

  Future<void> addPrize({
    required String name,
    required int quantity,
    String? imagePath,
  }) async {
    try {
      final model = EventPrizeModel(
        id: '',
        event: eventId,
        name: name,
        quantity: quantity,
      );
      await _dataSource.createPrize(model, imagePath: imagePath);
      await loadData();
    } catch (e) {
      emit(AdminDoorprizeState.error('Gagal menambahkan hadiah: $e'));
    }
  }

  Future<void> updatePrize({
    required String prizeId,
    required String name,
    required int quantity,
    String? imagePath,
  }) async {
    try {
      final model = EventPrizeModel(
        id: prizeId,
        event: eventId,
        name: name,
        quantity: quantity,
      );
      await _dataSource.updatePrize(prizeId, model, imagePath: imagePath);
      await loadData();
    } catch (e) {
      emit(AdminDoorprizeState.error('Gagal mengupdate hadiah: $e'));
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

  Future<void> recordWinner({
    required String prizeId,
    required String bookingTicketId,
  }) async {
    try {
      final model = EventWinnerModel(
        id: '',
        event: eventId,
        prize: prizeId,
        booking_ticket: bookingTicketId,
      );
      await _dataSource.createWinner(model);
      await loadData();
    } catch (e) {
      emit(AdminDoorprizeState.error('Gagal menyimpan pemenang: $e'));
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
}
