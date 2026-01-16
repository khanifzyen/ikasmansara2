import 'package:pocketbase/pocketbase.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    super.avatar,
    required super.role,
    super.isVerified,
  });

  factory UserModel.fromRecord(RecordModel record) {
    return UserModel(
      id: record.id,
      email: record.getStringValue('email'),
      name: record.getStringValue('name'),
      avatar: record.getStringValue('avatar').isNotEmpty
          ? record.getStringValue('avatar')
          : null,
      role: record.getStringValue('role'), // 'alumni' or 'guest'
      isVerified: record.getBoolValue('verified'),
    );
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      name: entity.name,
      avatar: entity.avatar,
      role: entity.role,
      isVerified: entity.isVerified,
    );
  }
}
