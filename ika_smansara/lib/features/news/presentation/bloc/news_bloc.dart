import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/news.dart';
import '../../domain/usecases/get_news_list.dart';

part 'news_event.dart';
part 'news_state.dart';

@injectable
class NewsBloc extends Bloc<NewsEvent, NewsState> {
  final GetNewsList _getNewsList;

  NewsBloc(this._getNewsList) : super(NewsInitial()) {
    on<FetchNewsList>(_onFetchNewsList);
    on<RefreshNewsList>(_onRefreshNewsList);
    on<LoadMoreNewsList>(_onLoadMoreNewsList);
  }

  Future<void> _onFetchNewsList(
    FetchNewsList event,
    Emitter<NewsState> emit,
  ) async {
    emit(NewsLoading());
    try {
      final newsList = await _getNewsList(category: event.category);
      emit(
        NewsLoaded(
          newsList: newsList,
          hasReachedMax: newsList.length < 10, // Assuming default perPage is 10
          currentPage: 1,
          selectedCategory: event.category,
        ),
      );
    } catch (e) {
      emit(NewsError(e.toString()));
    }
  }

  Future<void> _onRefreshNewsList(
    RefreshNewsList event,
    Emitter<NewsState> emit,
  ) async {
    try {
      final newsList = await _getNewsList(category: event.category);
      emit(
        NewsLoaded(
          newsList: newsList,
          hasReachedMax: newsList.length < 10,
          currentPage: 1,
          selectedCategory: event.category,
        ),
      );
    } catch (e) {
      emit(NewsError(e.toString()));
    }
  }

  Future<void> _onLoadMoreNewsList(
    LoadMoreNewsList event,
    Emitter<NewsState> emit,
  ) async {
    final currentState = state;
    if (currentState is NewsLoaded && !currentState.hasReachedMax) {
      try {
        final nextPage = currentState.currentPage + 1;
        final newNews = await _getNewsList(
          page: nextPage,
          category: currentState.selectedCategory,
        );

        if (newNews.isEmpty) {
          emit(currentState.copyWith(hasReachedMax: true));
        } else {
          emit(
            currentState.copyWith(
              newsList: List.of(currentState.newsList)..addAll(newNews),
              hasReachedMax: newNews.length < 10,
              currentPage: nextPage,
            ),
          );
        }
      } catch (e) {
        // Option: emit error or just ignore for pagination
        // For now, let's keep the current state but maybe show a snackbar (handled in UI)
      }
    }
  }
}
