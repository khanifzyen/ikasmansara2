// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$newsRemoteDataSourceHash() =>
    r'8fc00f1e72fe73add5d4aae9b0408379f2290fb7';

/// See also [newsRemoteDataSource].
@ProviderFor(newsRemoteDataSource)
final newsRemoteDataSourceProvider =
    AutoDisposeProvider<NewsRemoteDataSource>.internal(
      newsRemoteDataSource,
      name: r'newsRemoteDataSourceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$newsRemoteDataSourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NewsRemoteDataSourceRef = AutoDisposeProviderRef<NewsRemoteDataSource>;
String _$newsRepositoryHash() => r'ab04f00dbfa456592d7c9f6c7ef991a796510d18';

/// See also [newsRepository].
@ProviderFor(newsRepository)
final newsRepositoryProvider = AutoDisposeProvider<NewsRepository>.internal(
  newsRepository,
  name: r'newsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$newsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NewsRepositoryRef = AutoDisposeProviderRef<NewsRepository>;
String _$getNewsHash() => r'993f4d12b872dea75287250421847bff90e56ec5';

/// See also [getNews].
@ProviderFor(getNews)
final getNewsProvider = AutoDisposeProvider<GetNews>.internal(
  getNews,
  name: r'getNewsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getNewsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetNewsRef = AutoDisposeProviderRef<GetNews>;
String _$newsControllerHash() => r'a14a022b844fe2d07b367d5e210fe0b470cd83a0';

/// See also [NewsController].
@ProviderFor(NewsController)
final newsControllerProvider =
    AutoDisposeAsyncNotifierProvider<NewsController, List<NewsEntity>>.internal(
      NewsController.new,
      name: r'newsControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$newsControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$NewsController = AutoDisposeAsyncNotifier<List<NewsEntity>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
