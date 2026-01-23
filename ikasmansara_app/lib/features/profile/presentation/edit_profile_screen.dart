import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ikasmansara_app/common_widgets/buttons/primary_button.dart';
import 'package:ikasmansara_app/common_widgets/inputs/custom_text_field.dart';
import 'package:ikasmansara_app/features/profile/presentation/profile_controller.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _jobController;
  late TextEditingController _phoneController;
  late TextEditingController _linkedinController;
  late TextEditingController _instagramController;
  late TextEditingController _angkatanController;
  File? _selectedAvatar;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileControllerProvider).value;
    _nameController = TextEditingController(text: profile?.name);
    _bioController = TextEditingController(text: profile?.bio);
    _jobController = TextEditingController(text: profile?.job);
    _phoneController = TextEditingController(text: profile?.phone);
    _linkedinController = TextEditingController(text: profile?.linkedin);
    _instagramController = TextEditingController(text: profile?.instagram);
    _angkatanController = TextEditingController(
      text: profile?.angkatan?.toString(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _jobController.dispose();
    _phoneController.dispose();
    _linkedinController.dispose();
    _instagramController.dispose();
    _angkatanController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedAvatar = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    await ref
        .read(profileControllerProvider.notifier)
        .updateProfile(
          name: _nameController.text,
          bio: _bioController.text,
          job: _jobController.text,
          phone: _phoneController.text,
          linkedin: _linkedinController.text,
          instagram: _instagramController.text,
          angkatan: int.tryParse(_angkatanController.text),
          avatar: _selectedAvatar,
        );

    // Check for error state logic or simple pop
    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileControllerProvider);
    final isLoading = profileState.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Avatar Picker
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _selectedAvatar != null
                      ? FileImage(_selectedAvatar!)
                      : (profileState.value?.avatarUrl != null
                            ? NetworkImage(profileState.value!.avatarUrl!)
                                  as ImageProvider
                            : null),
                  child:
                      (_selectedAvatar == null &&
                          profileState.value?.avatarUrl == null)
                      ? const Icon(Icons.add_a_photo, size: 30)
                      : null,
                ),
              ),
              const SizedBox(height: 8),
              const Text('Tap to change avatar'),
              const SizedBox(height: 24),

              CustomTextField(
                label: 'Nama Lengkap',
                hint: 'Nama lengkap Anda',
                controller: _nameController,
                validator: (v) => v!.isEmpty ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Pekerjaan',
                hint: 'Misal: Software Engineer',
                controller: _jobController,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Bio',
                hint: 'Ceritakan sedikit tentang Anda',
                controller: _bioController,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Angkatan',
                hint: 'Tahun lulus',
                controller: _angkatanController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'No. WhatsApp',
                hint: '0812...',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'LinkedIn URL',
                hint: 'https://linkedin.com/in/...',
                controller: _linkedinController,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Instagram Username',
                hint: '@username',
                controller: _instagramController,
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'Simpan Perubahan',
                onPressed: isLoading ? null : _saveProfile,
                isLoading: isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
