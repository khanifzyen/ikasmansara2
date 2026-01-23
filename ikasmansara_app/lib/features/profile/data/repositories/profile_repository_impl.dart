import 'dart:io';
import 'package:ikasmansara_app/core/network/network_exceptions.dart';
import 'package:ikasmansara_app/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:ikasmansara_app/features/profile/domain/entities/profile_entity.dart';
import 'package:ikasmansara_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:pocketbase/pocketbase.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<ProfileEntity> getUserProfile(String userId) async {
    try {
      return await remoteDataSource.getUserProfile(userId);
    } catch (e) {
      if (e is ClientException) {
        throw mapPocketBaseError(e);
      }
      throw Exception(e.toString());
    }
  }

  @override
  Future<ProfileEntity> updateProfile({
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
      return await remoteDataSource.updateProfile(
        userId: userId,
        name: name,
        bio: bio,
        job: job,
        phone: phone,
        linkedin: linkedin,
        instagram: instagram,
        angkatan: angkatan,
        avatar: avatar,
      );
    } catch (e) {
      if (e is ClientException) {
        throw mapPocketBaseError(e);
      }
      throw Exception(e.toString());
    }
  }
}
