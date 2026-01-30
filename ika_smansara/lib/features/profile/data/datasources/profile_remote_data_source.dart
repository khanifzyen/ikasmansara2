import 'package:http/http.dart' as http;
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
      final body = params.toJson();

      final List<http.MultipartFile> files = [];
      if (params.avatarFile != null) {
        final multipartFile = await http.MultipartFile.fromPath(
          'avatar',
          params.avatarFile!.path,
        );
        files.add(multipartFile);
      }

      final record = await pbClient.pb
          .collection('users')
          .update(userId, body: body, files: files);
      return UserModel.fromRecord(record);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
