import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<UserEntity> getProfile() async {
    // Exceptions are propagated to BLoC
    final userModel = await remoteDataSource.getProfile();
    return userModel.toEntity();
  }

  @override
  Future<UserEntity> updateProfile(ProfileUpdateParams params) async {
    final userModel = await remoteDataSource.updateProfile(params);
    return userModel.toEntity();
  }
}
