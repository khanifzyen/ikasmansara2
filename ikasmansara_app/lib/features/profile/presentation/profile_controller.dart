import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ikasmansara_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:ikasmansara_app/features/profile/domain/entities/profile_entity.dart';
import 'package:ikasmansara_app/features/profile/presentation/providers/profile_providers.dart';

class ProfileController extends StateNotifier<AsyncValue<ProfileEntity?>> {
  final Ref ref;

  ProfileController(this.ref) : super(const AsyncValue.loading()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    state = const AsyncValue.loading();
    try {
      final user = ref.read(currentUserProvider).value;
      if (user == null) {
        state = const AsyncValue.data(null);
        return;
      }

      final getUserProfile = ref.read(getUserProfileProvider);
      final profile = await getUserProfile(user.id);
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateProfile({
    String? name,
    String? bio,
    String? job,
    String? phone,
    String? linkedin,
    String? instagram,
    int? angkatan,
    File? avatar,
  }) async {
    final currentUser = state.value;
    if (currentUser == null) return;

    state = const AsyncValue.loading();
    try {
      final updateUserProfile = ref.read(updateUserProfileProvider);
      final updatedProfile = await updateUserProfile(
        userId: currentUser.id,
        name: name,
        bio: bio,
        job: job,
        phone: phone,
        linkedin: linkedin,
        instagram: instagram,
        angkatan: angkatan,
        avatar: avatar,
      );
      state = AsyncValue.data(updatedProfile);

      // Refresh Auth User Provider because name/avatar might change
      ref.invalidate(currentUserProvider);
    } catch (e, st) {
      // Restore old state on error, but wrapped in error to show snackbar
      // Or just set error state
      state = AsyncValue.error(e, st);
    }
  }
}

final profileControllerProvider =
    StateNotifierProvider<ProfileController, AsyncValue<ProfileEntity?>>((ref) {
      return ProfileController(ref);
    });
