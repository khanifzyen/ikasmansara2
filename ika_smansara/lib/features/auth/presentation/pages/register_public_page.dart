/// Register Public Page
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/widgets/inputs.dart';
import '../../../../core/widgets/adaptive/adaptive_container.dart';
import '../../../../core/widgets/adaptive/adaptive_padding.dart';
import '../../../../core/widgets/adaptive/adaptive_spacing.dart';
import '../../domain/repositories/auth_repository.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class RegisterPublicPage extends StatefulWidget {
  const RegisterPublicPage({super.key});

  @override
  State<RegisterPublicPage> createState() => _RegisterPublicPageState();
}

class _RegisterPublicPageState extends State<RegisterPublicPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthBloc>().add(
      AuthRegisterPublicRequested(
        RegisterPublicParams(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
          passwordConfirm: _confirmPasswordController.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthRegistrationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
            ),
          );
          context.go('/login');
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/role-selection'),
          ),
        ),
        body: SafeArea(
          child: AdaptiveContainer(
            widthType: AdaptiveWidthType.form,
            child: AdaptivePaddingAll(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      const Text(
                        'Daftar Akun Umum',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const AdaptiveSpacingV(multiplier: 1.5),
                      const Text(
                        'Dapatkan akses berita sekolah dan informasi donasi.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textGrey,
                        ),
                      ),

                      const AdaptiveSpacingV(multiplier: 6.0),

                      // Form Fields
                      AppTextField(
                        label: 'Nama Lengkap',
                        hint: 'Masukkan nama lengkap',
                        controller: _nameController,
                        prefixIcon: const Icon(Icons.person_outline),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama wajib diisi';
                          }
                          return null;
                        },
                      ),

                      const AdaptiveSpacingV(multiplier: 3.0),

                      AppTextField(
                        label: 'Email',
                        hint: 'contoh@email.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.email_outlined),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email wajib diisi';
                          }
                          if (!value.contains('@')) {
                            return 'Email tidak valid';
                          }
                          return null;
                        },
                      ),

                      const AdaptiveSpacingV(multiplier: 3.0),

                      AppTextField(
                        label: 'No WhatsApp',
                        hint: '08123456789',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        prefixIcon: const Icon(Icons.phone_outlined),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'No WhatsApp wajib diisi';
                          }
                          return null;
                        },
                      ),

                      const AdaptiveSpacingV(multiplier: 3.0),

                      AppPasswordField(
                        label: 'Password',
                        hint: 'Minimal 8 karakter',
                        controller: _passwordController,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password wajib diisi';
                          }
                          if (value.length < 8) {
                            return 'Password minimal 8 karakter';
                          }
                          return null;
                        },
                      ),

                      const AdaptiveSpacingV(multiplier: 3.0),

                      AppPasswordField(
                        label: 'Konfirmasi Password',
                        hint: 'Ulangi password',
                        controller: _confirmPasswordController,
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Konfirmasi password wajib diisi';
                          }
                          if (value != _passwordController.text) {
                            return 'Password tidak cocok';
                          }
                          return null;
                        },
                      ),

                      const AdaptiveSpacingV(multiplier: 6.0),

                      // Submit Button
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          return PrimaryButton(
                            text: 'Buat Akun',
                            isLoading: state is AuthLoading,
                            onPressed: _submit,
                          );
                        },
                      ),

                      const AdaptiveSpacingV(multiplier: 3.0),

                      // Login link
                      Center(
                        child: TextButton(
                          onPressed: () => context.go('/login'),
                          child: const Text.rich(
                            TextSpan(
                              text: 'Sudah punya akun? ',
                              style: TextStyle(color: AppColors.textGrey),
                              children: [
                                TextSpan(
                                  text: 'Masuk',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
