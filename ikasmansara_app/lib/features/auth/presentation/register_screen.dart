import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../common_widgets/buttons/primary_button.dart';
import '../../../common_widgets/buttons/outline_button.dart';
import '../../../common_widgets/inputs/custom_text_field.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'register_controller.dart';

class RegisterScreen extends ConsumerWidget {
  const RegisterScreen({super.key});

  @override
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Optimization: Only rebuild when step or loading changes, not when text changes.
    final currentStep = ref.watch(
      registerControllerProvider.select((state) => state.currentStep),
    );
    final isLoading = ref.watch(
      registerControllerProvider.select((state) => state.isLoading),
    );
    final controller = ref.read(registerControllerProvider.notifier);

    // Initial state for app bar back button logic (need to know if step > 0)
    // currentStep covers this.

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (currentStep > 0) {
              controller.previousStep();
            } else {
              context.pop();
            }
          },
        ),
        title: const Text('Daftar Akun'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Indicator
            LinearProgressIndicator(
              value: (currentStep + 1) / 3,
              backgroundColor: AppColors.background,
              color: AppColors.primary,
              minHeight: 4,
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_getStepTitle(currentStep), style: AppTextStyles.h2),
                    const SizedBox(height: 8),
                    Text(
                      _getStepDescription(currentStep),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textGrey,
                      ),
                    ),
                    const SizedBox(height: 32),

                    _RegisterForm(step: currentStep),
                  ],
                ),
              ),
            ),

            // Fixed Bottom Buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  if (currentStep > 0) ...[
                    Expanded(
                      flex: 1,
                      child: OutlineButton(
                        text: 'KEMBALI',
                        onPressed: controller.previousStep,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],

                  Expanded(
                    flex: 2,
                    child: PrimaryButton(
                      text: currentStep == 2 ? 'DAFTAR SEKARANG' : 'LANJUT',
                      isLoading: isLoading,
                      onPressed: () async {
                        if (currentStep < 2) {
                          // TODO: Validate current step form
                          // For now we assume valid or logic inside Form widget
                          // Ideally use a GlobalKey<FormState> for each step or a single one
                          controller.nextStep();
                        } else {
                          try {
                            await controller.submit();
                            if (context.mounted) {
                              context.go('/login');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Registrasi berhasil! Silakan login.',
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Registrasi gagal: $e')),
                              );
                            }
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return 'Data Diri';
      case 1:
        return 'Kontak';
      case 2:
        return 'Info Alumni';
      default:
        return '';
    }
  }

  String _getStepDescription(int step) {
    switch (step) {
      case 0:
        return 'Lengkapi identitas dasar Anda.';
      case 1:
        return 'Informasi kontak yang bisa dihubungi.';
      case 2:
        return 'Verifikasi data kelulusan Anda.';
      default:
        return '';
    }
  }
}

class _RegisterForm extends ConsumerStatefulWidget {
  final int step;
  const _RegisterForm({required this.step});

  @override
  ConsumerState<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends ConsumerState<_RegisterForm> {
  // We use text controllers to bind to state
  // In a real app, initialize with values from provider state

  late TextEditingController nameCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController passCtrl;
  late TextEditingController confPassCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController yearCtrl;

  @override
  void initState() {
    super.initState();
    // Initialize with empty or existing state
    final state = ref.read(registerControllerProvider);
    nameCtrl = TextEditingController(text: state.name);
    emailCtrl = TextEditingController(text: state.email);
    passCtrl = TextEditingController(text: state.password);
    confPassCtrl = TextEditingController(
      text: state.password,
    ); // No explicit confirm state store yet
    phoneCtrl = TextEditingController(text: state.phone);
    yearCtrl = TextEditingController(text: state.graduationYear);
  }

  @override
  void didUpdateWidget(_RegisterForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If we wanted to keep controllers in sync with external changes
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    confPassCtrl.dispose();
    phoneCtrl.dispose();
    yearCtrl.dispose();
    super.dispose();
  }

  void _updateState() {
    ref
        .read(registerControllerProvider.notifier)
        .updateData(
          name: nameCtrl.text,
          email: emailCtrl.text,
          password: passCtrl.text,
          phone: phoneCtrl.text,
          graduationYear: yearCtrl.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    // Listen to changes to update state immediately or on blur?
    // For simplicity, we can update onChanged

    switch (widget.step) {
      case 0:
        return Column(
          children: [
            CustomTextField(
              label: 'Nama Lengkap',
              hint: 'Sesuai ijazah',
              controller: nameCtrl,
              onChanged: (_) => _updateState(),
              prefixIcon: const Icon(LucideIcons.user),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Email',
              hint: 'email@example.com',
              controller: emailCtrl,
              onChanged: (_) => _updateState(),
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(LucideIcons.mail),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Kata Sandi',
              hint: 'Minimal 8 karakter',
              controller: passCtrl,
              onChanged: (_) => _updateState(),
              isPassword: true,
              prefixIcon: const Icon(LucideIcons.lock),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Ulangi Kata Sandi',
              hint: 'Konfirmasi kata sandi',
              controller: confPassCtrl,
              isPassword: true,
              prefixIcon: const Icon(LucideIcons.lock),
            ),
          ],
        );
      case 1:
        return Column(
          children: [
            CustomTextField(
              label: 'Nomor WhatsApp',
              hint: '0812xxxx (Aktif)',
              controller: phoneCtrl,
              onChanged: (_) => _updateState(),
              keyboardType: TextInputType.phone,
              prefixIcon: const Icon(LucideIcons.phone),
            ),
          ],
        );
      case 2:
        return Column(
          children: [
            CustomTextField(
              label: 'Tahun Lulus',
              hint: 'Contoh: 2015',
              controller: yearCtrl,
              onChanged: (_) => _updateState(),
              keyboardType: TextInputType.number,
              prefixIcon: const Icon(LucideIcons.graduationCap),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.info, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Data kelulusan akan diverifikasi secara manual oleh Admin IKA SMANSARA sebelum akun aktif.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
