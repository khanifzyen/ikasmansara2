import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getLastUser();
  Future<void> clearUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences _prefs;

  static const String _prefix = 'user_';
  static const String _keyName = '${_prefix}name';
  static const String _keyEmail = '${_prefix}email';
  static const String _keyPhone = '${_prefix}phone';
  static const String _keyAvatar = '${_prefix}avatar';
  static const String _keyRole = '${_prefix}role';
  static const String _keyId = '${_prefix}id';
  static const String _keyAngkatan = '${_prefix}angkatan';
  static const String _keyNoUrutAngkatan = '${_prefix}no_urut_angkatan';
  static const String _keyNoUrutGlobal = '${_prefix}no_urut_global';
  static const String _keyVerified = '${_prefix}verified';

  AuthLocalDataSourceImpl(this._prefs);

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      await Future.wait([
        _prefs.setString(_keyId, user.id),
        _prefs.setString(_keyEmail, user.email),
        _prefs.setString(_keyName, user.name),
        _prefs.setString(_keyPhone, user.phone),
        _prefs.setString(_keyRole, user.role),
        if (user.avatar != null)
          _prefs.setString(_keyAvatar, user.avatar!)
        else
          _prefs.remove(_keyAvatar),
        if (user.angkatan != null)
          _prefs.setInt(_keyAngkatan, user.angkatan!)
        else
          _prefs.remove(_keyAngkatan),
        if (user.noUrutAngkatan != null)
          _prefs.setInt(_keyNoUrutAngkatan, user.noUrutAngkatan!)
        else
          _prefs.remove(_keyNoUrutAngkatan),
        if (user.noUrutGlobal != null)
          _prefs.setInt(_keyNoUrutGlobal, user.noUrutGlobal!)
        else
          _prefs.remove(_keyNoUrutGlobal),
        _prefs.setBool(_keyVerified, user.verified),
      ]);
      debugPrint('AuthLocalDataSource: User cached successfully');
    } catch (e) {
      debugPrint('AuthLocalDataSource: Cache user failed: $e');
    }
  }

  @override
  Future<UserModel?> getLastUser() async {
    try {
      final id = _prefs.getString(_keyId);
      final email = _prefs.getString(_keyEmail);
      final name = _prefs.getString(_keyName);
      final phone = _prefs.getString(_keyPhone) ?? '';
      final role = _prefs.getString(_keyRole);

      if (id == null || email == null || name == null || role == null) {
        return null;
      }

      return UserModel(
        id: id,
        email: email,
        name: name,
        phone: phone,
        role: role,
        avatar: _prefs.getString(_keyAvatar),
        angkatan: _prefs.getInt(_keyAngkatan),
        noUrutAngkatan: _prefs.getInt(_keyNoUrutAngkatan),
        noUrutGlobal: _prefs.getInt(_keyNoUrutGlobal),
        // Default values for fields not cached
        isVerified: false,
        verified: _prefs.getBool(_keyVerified) ?? false,
      );
    } catch (e) {
      debugPrint('AuthLocalDataSource: Get last user failed: $e');
      return null;
    }
  }

  @override
  Future<void> clearUser() async {
    try {
      await Future.wait([
        _prefs.remove(_keyId),
        _prefs.remove(_keyEmail),
        _prefs.remove(_keyName),
        _prefs.remove(_keyPhone),
        _prefs.remove(_keyRole),
        _prefs.remove(_keyAvatar),
        _prefs.remove(_keyAngkatan),
        _prefs.remove(_keyNoUrutAngkatan),
        _prefs.remove(_keyNoUrutGlobal),
        _prefs.remove(_keyVerified),
      ]);
    } catch (e) {
      debugPrint('AuthLocalDataSource: Clear user failed: $e');
    }
  }
}
