part of 'news_bloc.dart';

abstract class NewsState extends Equatable {
  const NewsState();

  @override
  List<Object?> get props => [];
}

class NewsInitial extends NewsState {}

class NewsLoading extends NewsState {}

class NewsLoaded extends NewsState {
  final List<News> newsList;
  final bool hasReachedMax;
  final int currentPage;
  final String? selectedCategory;

  const NewsLoaded({
    required this.newsList,
    this.hasReachedMax = false,
    required this.currentPage,
    this.selectedCategory,
  });

  NewsLoaded copyWith({
    List<News>? newsList,
    bool? hasReachedMax,
    int? currentPage,
    String? selectedCategory,
  }) {
    return NewsLoaded(
      newsList: newsList ?? this.newsList,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }

  @override
  List<Object?> get props => [
    newsList,
    hasReachedMax,
    currentPage,
    selectedCategory,
  ];
}

class NewsError extends NewsState {
  final String message;

  const NewsError(this.message);

  @override
  List<Object?> get props => [message];
}
