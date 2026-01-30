part of 'news_bloc.dart';

abstract class NewsEvent extends Equatable {
  const NewsEvent();

  @override
  List<Object?> get props => [];
}

class FetchNewsList extends NewsEvent {
  final String? category;

  const FetchNewsList({this.category});

  @override
  List<Object?> get props => [category];
}

class RefreshNewsList extends NewsEvent {
  final String? category;

  const RefreshNewsList({this.category});

  @override
  List<Object?> get props => [category];
}

class LoadMoreNewsList extends NewsEvent {}
