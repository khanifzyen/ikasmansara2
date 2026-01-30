import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/pb_client.dart';
import '../../../auth/data/models/user_model.dart';
import '../../domain/repositories/profile_repository.dart';

abstract class ProfileRemoteDataSource {
  Future<UserModel> getProfile();
  Future<UserModel> updateProfile(ProfileUpdateParams params);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final PBClient pbClient;

  ProfileRemoteDataSourceImpl(this.pbClient);

  @override
  Future<UserModel> getProfile() async {
    try {
      // Use authRefresh to get the latest user data and update auth store
      final record = await pbClient.pb.collection('users').authRefresh();
      return UserModel.fromRecord(record.record);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel> updateProfile(ProfileUpdateParams params) async {
    try {
      final userId = pbClient.pb.authStore.record!.id;
      final record = await pbClient.pb
          .collection('users')
          .update(userId, body: params.toJson());
      // Also refresh auth store to reflect changes locally if needed,
      // but update returns the updated record.
      // Ideally we sync the auth store too.
      // pbClient.pb.collection('users').authRefresh(); // Optional but good practice

      return UserModel.fromRecord(record);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
