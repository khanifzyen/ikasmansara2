import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ikasmansara_app/core/network/pocketbase_service.dart';
import 'package:ikasmansara_app/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:ikasmansara_app/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:ikasmansara_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:ikasmansara_app/features/profile/domain/usecases/get_user_profile.dart';
import 'package:ikasmansara_app/features/profile/domain/usecases/update_user_profile.dart';

// Data Source
final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>((
  ref,
) {
  return ProfileRemoteDataSourceImpl(PocketBaseService().pb);
});

// Repository
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final remoteDataSource = ref.watch(profileRemoteDataSourceProvider);
  return ProfileRepositoryImpl(remoteDataSource);
});

// Use Cases
final getUserProfileProvider = Provider<GetUserProfile>((ref) {
  return GetUserProfile(ref.watch(profileRepositoryProvider));
});

final updateUserProfileProvider = Provider<UpdateUserProfile>((ref) {
  return UpdateUserProfile(ref.watch(profileRepositoryProvider));
});
