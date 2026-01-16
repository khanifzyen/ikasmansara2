import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ikasmansara_app/core/network/pocketbase_service.dart';
import 'package:ikasmansara_app/core/network/providers.dart';
import 'package:ikasmansara_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:ikasmansara_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:ikasmansara_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:ikasmansara_app/features/auth/domain/usecases/login_user.dart';
import 'package:ikasmansara_app/features/auth/domain/usecases/register_alumni.dart';

part 'auth_providers.g.dart';

// Data Source
@riverpod
AuthRemoteDataSource authRemoteDataSource(Ref ref) {
  final pbService = ref.watch(pocketBaseServiceProvider);
  return AuthRemoteDataSourceImpl(pbService);
}

// Repository
@riverpod
AuthRepository authRepository(Ref ref) {
  final dataSource = ref.watch(authRemoteDataSourceProvider);
  return AuthRepositoryImpl(dataSource);
}

// UseCases
@riverpod
LoginUser loginUser(Ref ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginUser(repository);
}

@riverpod
RegisterAlumni registerAlumni(Ref ref) {
  final repository = ref.watch(authRepositoryProvider);
  return RegisterAlumni(repository);
}
