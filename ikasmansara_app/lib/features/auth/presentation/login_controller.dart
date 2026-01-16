import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ikasmansara_app/features/auth/domain/entities/user_entity.dart';
import 'package:ikasmansara_app/features/auth/presentation/providers/auth_providers.dart';

part 'login_controller.g.dart';

@riverpod
class LoginController extends _$LoginController {
  @override
  Future<UserEntity?> build() async {
    return null;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final loginUser = ref.read(loginUserProvider);
      return await loginUser(email, password);
    });
  }
}
