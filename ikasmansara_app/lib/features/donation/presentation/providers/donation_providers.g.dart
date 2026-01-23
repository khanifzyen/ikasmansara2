// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'donation_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$donationRemoteDataSourceHash() =>
    r'f4f0a07495d20deecc60ac920443e4a476e8f942';

/// See also [donationRemoteDataSource].
@ProviderFor(donationRemoteDataSource)
final donationRemoteDataSourceProvider =
    AutoDisposeProvider<DonationRemoteDataSource>.internal(
      donationRemoteDataSource,
      name: r'donationRemoteDataSourceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$donationRemoteDataSourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DonationRemoteDataSourceRef =
    AutoDisposeProviderRef<DonationRemoteDataSource>;
String _$donationRepositoryHash() =>
    r'7ca009c457c958f410233ce39620b0ddd420abb1';

/// See also [donationRepository].
@ProviderFor(donationRepository)
final donationRepositoryProvider =
    AutoDisposeProvider<DonationRepository>.internal(
      donationRepository,
      name: r'donationRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$donationRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DonationRepositoryRef = AutoDisposeProviderRef<DonationRepository>;
String _$getCampaignsHash() => r'18143d46a2e36b312566be5a98c0d52420b42437';

/// See also [getCampaigns].
@ProviderFor(getCampaigns)
final getCampaignsProvider = AutoDisposeProvider<GetCampaigns>.internal(
  getCampaigns,
  name: r'getCampaignsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getCampaignsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetCampaignsRef = AutoDisposeProviderRef<GetCampaigns>;
String _$getCampaignDetailHash() => r'3a0027c4b14dc181c9a1856176bb4aea5337df5c';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [getCampaignDetail].
@ProviderFor(getCampaignDetail)
const getCampaignDetailProvider = GetCampaignDetailFamily();

/// See also [getCampaignDetail].
class GetCampaignDetailFamily extends Family<AsyncValue<CampaignEntity>> {
  /// See also [getCampaignDetail].
  const GetCampaignDetailFamily();

  /// See also [getCampaignDetail].
  GetCampaignDetailProvider call(String id) {
    return GetCampaignDetailProvider(id);
  }

  @override
  GetCampaignDetailProvider getProviderOverride(
    covariant GetCampaignDetailProvider provider,
  ) {
    return call(provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'getCampaignDetailProvider';
}

/// See also [getCampaignDetail].
class GetCampaignDetailProvider
    extends AutoDisposeFutureProvider<CampaignEntity> {
  /// See also [getCampaignDetail].
  GetCampaignDetailProvider(String id)
    : this._internal(
        (ref) => getCampaignDetail(ref as GetCampaignDetailRef, id),
        from: getCampaignDetailProvider,
        name: r'getCampaignDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$getCampaignDetailHash,
        dependencies: GetCampaignDetailFamily._dependencies,
        allTransitiveDependencies:
            GetCampaignDetailFamily._allTransitiveDependencies,
        id: id,
      );

  GetCampaignDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    FutureOr<CampaignEntity> Function(GetCampaignDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GetCampaignDetailProvider._internal(
        (ref) => create(ref as GetCampaignDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<CampaignEntity> createElement() {
    return _GetCampaignDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GetCampaignDetailProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GetCampaignDetailRef on AutoDisposeFutureProviderRef<CampaignEntity> {
  /// The parameter `id` of this provider.
  String get id;
}

class _GetCampaignDetailProviderElement
    extends AutoDisposeFutureProviderElement<CampaignEntity>
    with GetCampaignDetailRef {
  _GetCampaignDetailProviderElement(super.provider);

  @override
  String get id => (origin as GetCampaignDetailProvider).id;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
