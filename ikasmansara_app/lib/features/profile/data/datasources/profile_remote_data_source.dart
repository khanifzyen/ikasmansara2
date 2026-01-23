import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:ikasmansara_app/core/network/api_endpoints.dart';
import 'package:ikasmansara_app/features/profile/data/models/profile_model.dart';
import 'package:pocketbase/pocketbase.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getUserProfile(String userId);
  Future<ProfileModel> updateProfile({
    required String userId,
    String? name,
    String? bio,
    String? job,
    String? phone,
    String? linkedin,
    String? instagram,
    int? angkatan,
    File? avatar,
  });
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final PocketBase pb;

  ProfileRemoteDataSourceImpl(this.pb);

  @override
  Future<ProfileModel> getUserProfile(String userId) async {
    try {
      final record = await pb.collection(ApiEndpoints.users).getOne(userId);
      return ProfileModel.fromRecord(record);
    } catch (e) {
      throw Exception('Failed to fetch profile: $e');
    }
  }

  @override
  Future<ProfileModel> updateProfile({
    required String userId,
    String? name,
    String? bio,
    String? job,
    String? phone,
    String? linkedin,
    String? instagram,
    int? angkatan,
    File? avatar,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (bio != null) body['bio'] = bio;
      if (job != null) body['job'] = job;
      if (phone != null) body['phone'] = phone;
      if (linkedin != null) body['linkedin'] = linkedin;
      if (instagram != null) body['instagram'] = instagram;
      if (angkatan != null) body['angkatan'] = angkatan;

      List<http.MultipartFile> files = [];
      if (avatar != null) {
        files.add(await http.MultipartFile.fromPath('avatar', avatar.path));
      }

      final record = await pb
          .collection(ApiEndpoints.users)
          .update(userId, body: body, files: files);
      return ProfileModel.fromRecord(record);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }
}
