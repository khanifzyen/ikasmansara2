import 'package:pocketbase/pocketbase.dart';
import '../../domain/entities/alumni_entity.dart';

class AlumniModel extends AlumniEntity {
  const AlumniModel({
    required super.id,
    required super.name,
    required super.email,
    super.avatar,
    required super.angkatan,
    required super.role,
    super.jobType,
    super.company,
    super.position,
    super.domicile,
  });

  factory AlumniModel.fromRecord(RecordModel record) {
    return AlumniModel(
      id: record.id,
      name: record.getStringValue('name'),
      email: record.getStringValue('email'),
      avatar: record.getStringValue('avatar'),
      angkatan: record.getIntValue('angkatan'),
      role: record.getStringValue('role'),
      jobType: record.getStringValue('job_type'),
      company: record.getStringValue('company'),
      position: record.getStringValue('position'),
      domicile: record.getStringValue('domicile'),
    );
  }

  /// Helper to get full avatar URL if needed, though usually handled by CachedNetworkImage with base URL
  String getAvatarUrl(String baseUrl, String collectionId) {
    if (avatar == null) return '';
    return '$baseUrl/api/files/$collectionId/$id/$avatar';
  }
}
