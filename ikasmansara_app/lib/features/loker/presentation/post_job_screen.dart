import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ikasmansara_app/common_widgets/buttons/primary_button.dart';
import 'package:ikasmansara_app/common_widgets/inputs/custom_text_field.dart';
import 'package:ikasmansara_app/core/theme/app_colors.dart';
import 'package:ikasmansara_app/features/loker/presentation/post_job_controller.dart';
import '../../auth/presentation/providers/auth_providers.dart';

class PostJobScreen extends ConsumerStatefulWidget {
  const PostJobScreen({super.key});

  @override
  ConsumerState<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends ConsumerState<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _locationController = TextEditingController();
  final _salaryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _linkController = TextEditingController();

  String _selectedType = 'Fulltime';

  final List<String> _jobTypes = [
    'Fulltime',
    'Parttime',
    'Contract',
    'Internship',
    'Freelance',
    'Remote',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _locationController.dispose();
    _salaryController.dispose();
    _descriptionController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final userState = ref.read(currentUserProvider);
      final user = userState.value;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Anda harus login terlebih dahulu')),
        );
        return;
      }

      final success = await ref
          .read(postJobControllerProvider.notifier)
          .createJob(
            title: _titleController.text,
            company: _companyController.text,
            type: _selectedType,
            location: _locationController.text,
            salary: _salaryController.text,
            description: _descriptionController.text,
            link: _linkController.text,
            authorId: user.id,
          );

      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lowongan berhasil diposting!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop(); // Back to list
        // Typically the list auto-refreshes if using Riverpod correctly (invalidate on success)
        // But for now context.pop is enough
      } else if (mounted) {
        final error = ref.read(postJobControllerProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memposting: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postJobControllerProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pasang Lowongan',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => context.pop(),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionLabel('Info Pekerjaan'),
              CustomTextField(
                label: 'Posisi / Judul Pekerjaan',
                controller: _titleController,
                hint: 'Contoh: Senior Flutter Developer',
                validator: (v) => v?.isEmpty == true ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Nama Perusahaan',
                controller: _companyController,
                hint: 'Contoh: PT. Teknologi Maju',
                validator: (v) => v?.isEmpty == true ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              const Text(
                'Tipe Pekerjaan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.neutral200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.neutral200),
                  ),
                ),
                items: _jobTypes.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedType = val);
                  }
                },
              ),

              const SizedBox(height: 16),
              CustomTextField(
                label: 'Lokasi',
                controller: _locationController,
                hint: 'Contoh: Jakarta Selatan (atau Remote)',
                validator: (v) => v?.isEmpty == true ? 'Wajib diisi' : null,
              ),

              const SizedBox(height: 24),
              _buildSectionLabel('Detail Tambahan'),

              CustomTextField(
                label: 'Kisaran Gaji (Opsional)',
                controller: _salaryController,
                hint: 'Contoh: Rp 8.000.000 - Rp 12.000.000',
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Deskripsi Pekerjaan',
                controller: _descriptionController,
                maxLines: 5,
                hint: 'Jelaskan tanggung jawab dan kualifikasi...',
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Link Lamaran / Email (Opsional)',
                controller: _linkController,
                hint: 'Contoh: https://linkedin.com/... atau hr@company.com',
                keyboardType: TextInputType.url,
              ),

              const SizedBox(height: 32),
              PrimaryButton(
                text: 'Posting Lowongan',
                isLoading: isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
