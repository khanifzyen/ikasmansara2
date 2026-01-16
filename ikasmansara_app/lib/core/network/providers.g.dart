// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(pocketBaseService)
final pocketBaseServiceProvider = PocketBaseServiceProvider._();

final class PocketBaseServiceProvider
    extends
        $FunctionalProvider<
          PocketBaseService,
          PocketBaseService,
          PocketBaseService
        >
    with $Provider<PocketBaseService> {
  PocketBaseServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pocketBaseServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pocketBaseServiceHash();

  @$internal
  @override
  $ProviderElement<PocketBaseService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PocketBaseService create(Ref ref) {
    return pocketBaseService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PocketBaseService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PocketBaseService>(value),
    );
  }
}

String _$pocketBaseServiceHash() => r'4377595dd862b32814dff162538c7a2e1685fa5d';
