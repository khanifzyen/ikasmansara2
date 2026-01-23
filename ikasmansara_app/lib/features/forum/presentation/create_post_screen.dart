import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ikasmansara_app/common_widgets/buttons/primary_button.dart';
import 'package:ikasmansara_app/common_widgets/inputs/custom_text_field.dart';
import 'package:ikasmansara_app/common_widgets/inputs/dropdown_field.dart';
import 'package:ikasmansara_app/core/theme/app_colors.dart';
import 'package:ikasmansara_app/features/forum/presentation/forum_controller.dart';
import 'package:image_picker/image_picker.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();

  String _selectedCategory = 'Umum';
  File? _selectedImage;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        await ref
            .read(forumControllerProvider.notifier)
            .createPost(
              content: _contentController.text,
              category: _selectedCategory,
              images: _selectedImage != null ? [_selectedImage!] : null,
            );

        if (mounted) {
          context.pop(); // Go back to feed
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Postingan berhasil dibuat!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal membuat postingan: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Postingan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                label: 'Isi Postingan',
                controller: _contentController,
                maxLines: 5,
                hint: 'Apa yang ingin Anda bagikan?',
                validator: (value) => value == null || value.isEmpty
                    ? 'Konten tidak boleh kosong'
                    : null,
              ),
              const SizedBox(height: 16),
              DropdownField(
                label: 'Kategori',
                value: _selectedCategory,
                items: const [
                  DropdownMenuItem(value: 'Umum', child: Text('Umum')),
                  DropdownMenuItem(value: 'Karir', child: Text('Karir')),
                  DropdownMenuItem(value: 'Event', child: Text('Event')),
                  DropdownMenuItem(value: 'Diskusi', child: Text('Diskusi')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),
              const SizedBox(height: 16),

              // Image Picker
              InkWell(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(_selectedImage!, fit: BoxFit.cover),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.add_a_photo,
                              size: 40,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Tambahkan Foto',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                ),
              ),
              if (_selectedImage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextButton.icon(
                    onPressed: () => setState(() => _selectedImage = null),
                    icon: const Icon(Icons.delete, color: AppColors.error),
                    label: const Text(
                      'Hapus Foto',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                ),

              const SizedBox(height: 32),
              PrimaryButton(
                text: 'Posting',
                isLoading: _isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
