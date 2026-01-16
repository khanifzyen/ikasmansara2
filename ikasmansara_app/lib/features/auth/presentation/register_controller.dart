import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ikasmansara_app/features/auth/presentation/providers/auth_providers.dart';

part 'register_controller.g.dart';

class RegisterState {
  final int currentStep;
  final bool isLoading;

  // Data
  final String name;
  final String email;
  final String password;
  final String phone;
  final String graduationYear; // Input as string, parse later

  const RegisterState({
    this.currentStep = 0,
    this.isLoading = false,
    this.name = '',
    this.email = '',
    this.password = '',
    this.phone = '',
    this.graduationYear = '',
  });

  RegisterState copyWith({
    int? currentStep,
    bool? isLoading,
    String? name,
    String? email,
    String? password,
    String? phone,
    String? graduationYear,
  }) {
    return RegisterState(
      currentStep: currentStep ?? this.currentStep,
      isLoading: isLoading ?? this.isLoading,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      graduationYear: graduationYear ?? this.graduationYear,
    );
  }
}

@riverpod
class RegisterController extends _$RegisterController {
  @override
  RegisterState build() {
    return const RegisterState();
  }

  void updateData({
    String? name,
    String? email,
    String? password,
    String? phone,
    String? graduationYear,
  }) {
    state = state.copyWith(
      name: name,
      email: email,
      password: password,
      phone: phone,
      graduationYear: graduationYear,
    );
  }

  void nextStep() {
    if (state.currentStep < 2) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  Future<void> submit() async {
    state = state.copyWith(isLoading: true);

    try {
      final registerAlumni = ref.read(registerAlumniProvider);

      await registerAlumni(
        name: state.name,
        email: state.email,
        password: state.password,
        phone: state.phone,
        graduationYear: int.tryParse(state.graduationYear) ?? 0,
      );

      // Success is handled by UI listening to this future or state
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }
}
