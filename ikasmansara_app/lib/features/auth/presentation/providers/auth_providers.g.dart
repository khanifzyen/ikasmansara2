// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(authRemoteDataSource)
final authRemoteDataSourceProvider = AuthRemoteDataSourceProvider._();

final class AuthRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          AuthRemoteDataSource,
          AuthRemoteDataSource,
          AuthRemoteDataSource
        >
    with $Provider<AuthRemoteDataSource> {
  AuthRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRemoteDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<AuthRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AuthRemoteDataSource create(Ref ref) {
    return authRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRemoteDataSource>(value),
    );
  }
}

String _$authRemoteDataSourceHash() =>
    r'98ddb212478752873c2ad06ed8a33daadd2337be';

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'9fb3538d845a831c8d474086086bf8a0a39d1f59';

@ProviderFor(loginUser)
final loginUserProvider = LoginUserProvider._();

final class LoginUserProvider
    extends $FunctionalProvider<LoginUser, LoginUser, LoginUser>
    with $Provider<LoginUser> {
  LoginUserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loginUserProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loginUserHash();

  @$internal
  @override
  $ProviderElement<LoginUser> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LoginUser create(Ref ref) {
    return loginUser(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoginUser value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoginUser>(value),
    );
  }
}

String _$loginUserHash() => r'512eb4e6b41f9807de9c23699b764ca52b5e03b4';

@ProviderFor(registerAlumni)
final registerAlumniProvider = RegisterAlumniProvider._();

final class RegisterAlumniProvider
    extends $FunctionalProvider<RegisterAlumni, RegisterAlumni, RegisterAlumni>
    with $Provider<RegisterAlumni> {
  RegisterAlumniProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'registerAlumniProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$registerAlumniHash();

  @$internal
  @override
  $ProviderElement<RegisterAlumni> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RegisterAlumni create(Ref ref) {
    return registerAlumni(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RegisterAlumni value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RegisterAlumni>(value),
    );
  }
}

String _$registerAlumniHash() => r'0635b5ce3a1c9055be28939ce9bd9e8fa04b7dfa';
