/// Register Alumni Page
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/widgets/inputs.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class RegisterAlumniPage extends StatefulWidget {
  const RegisterAlumniPage({super.key});

  @override
  State<RegisterAlumniPage> createState() => _RegisterAlumniPageState();
}

class _RegisterAlumniPageState extends State<RegisterAlumniPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _companyController = TextEditingController();
  final _domisiliController = TextEditingController();

  // Form values
  int? _selectedAngkatan;
  JobStatus? _selectedJobStatus;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _companyController.dispose();
    _domisiliController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAngkatan == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pilih tahun lulus')));
      return;
    }

    context.read<AuthBloc>().add(
      AuthRegisterAlumniRequested(
        RegisterAlumniParams(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
          passwordConfirm: _confirmPasswordController.text,
          angkatan: _selectedAngkatan!,
          jobStatus: _selectedJobStatus,
          company: _companyController.text.trim(),
          domisili: _domisiliController.text.trim(),
        ),
      ),
    );
  }

  List<int> get _angkatanList {
    final currentYear = DateTime.now().year;
    return List.generate(
      currentYear - 1970 + 1,
      (index) => currentYear - index,
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
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/role-selection'),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  const Text(
                    'Pendaftaran Alumni',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Lengkapi data untuk mendaftar sebagai alumni SMANSA',
                    style: TextStyle(fontSize: 14, color: AppColors.textGrey),
                  ),

                  const SizedBox(height: 24),

                  // Section: Data Akun
                  _buildSectionTitle('Data Akun'),
                  const SizedBox(height: 16),

                  AppTextField(
                    label: 'Nama Lengkap',
                    hint: 'Sesuai ijazah',
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

                  const SizedBox(height: 16),

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

                  const SizedBox(height: 16),

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

                  const SizedBox(height: 16),

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

                  const SizedBox(height: 16),

                  AppPasswordField(
                    label: 'Konfirmasi Password',
                    hint: 'Ulangi password',
                    controller: _confirmPasswordController,
                    textInputAction: TextInputAction.next,
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

                  const SizedBox(height: 24),

                  // Section: Data Sekolah
                  _buildSectionTitle('Data Sekolah'),
                  const SizedBox(height: 16),

                  _buildDropdownField(
                    label: 'Tahun Lulus (Angkatan)',
                    value: _selectedAngkatan,
                    items: _angkatanList
                        .map(
                          (year) => DropdownMenuItem(
                            value: year,
                            child: Text(year.toString()),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedAngkatan = value);
                    },
                  ),

                  const SizedBox(height: 24),

                  // Section: Profil Saat Ini
                  _buildSectionTitle('Profil Saat Ini (Opsional)'),
                  const SizedBox(height: 16),

                  _buildDropdownField(
                    label: 'Status Pekerjaan',
                    value: _selectedJobStatus,
                    items: JobStatus.values
                        .map(
                          (status) => DropdownMenuItem(
                            value: status,
                            child: Text(status.displayName),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedJobStatus = value);
                    },
                  ),

                  const SizedBox(height: 16),

                  AppTextField(
                    label: 'Instansi/Perusahaan',
                    hint: 'Tempat bekerja',
                    controller: _companyController,
                    prefixIcon: const Icon(Icons.business_outlined),
                    textInputAction: TextInputAction.next,
                  ),

                  const SizedBox(height: 16),

                  AppTextField(
                    label: 'Domisili',
                    hint: 'Kota tempat tinggal',
                    controller: _domisiliController,
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    textInputAction: TextInputAction.done,
                  ),

                  const SizedBox(height: 32),

                  // Submit Button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return PrimaryButton(
                        text: 'Daftar Sekarang',
                        isLoading: state is AuthLoading,
                        onPressed: _submit,
                      );
                    },
                  ),

                  const SizedBox(height: 16),

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

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          initialValue: value,
          items: items,
          onChanged: onChanged,
          decoration: const InputDecoration(hintText: 'Pilih...'),
        ),
      ],
    );
  }
}
