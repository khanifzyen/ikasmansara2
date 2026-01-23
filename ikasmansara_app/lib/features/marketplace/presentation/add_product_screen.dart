import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../common_widgets/buttons/primary_button.dart';
import '../../../common_widgets/inputs/custom_text_field.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import '../../marketplace/presentation/providers/marketplace_providers.dart';
import '../../marketplace/domain/entities/product_entity.dart';
import '../../../core/network/pocketbase_service.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  const AddProductScreen({super.key});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _whatsappController = TextEditingController();

  String _selectedCategory = 'Makanan';
  final List<String> _categories = [
    'Makanan',
    'Minuman',
    'Jasa',
    'Pakaian',
    'Elektronik',
    'Lainnya',
  ];

  final List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_selectedImages.length >= 4) return;

    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImages.add(File(image.path));
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengambil gambar: $e')));
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon tambahkan minimal 1 foto produk')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Use PocketBaseService directly for synchronous auth check
      final pb = PocketBaseService().pb;

      if (!pb.authStore.isValid) {
        // Fallback to provider check if needed, but PB store is source of truth
        throw Exception("Sesi kadaluarsa. Silakan login kembali.");
      }

      final userId = pb.authStore.model.id;

      // Prepare Product Entity (ID created by server, images handled separately)
      final newProduct = ProductEntity(
        id: '', // Server generated
        name: _nameController.text,
        description: _descController.text,
        price: double.tryParse(_priceController.text) ?? 0,
        category: _selectedCategory,
        images: [], // Handled by repository upload
        whatsapp: _whatsappController.text,
        sellerId: userId,
        created: DateTime.now(),
      );

      // Call Repository using Manual Provider
      await ref
          .read(productRepositoryProvider)
          .createProduct(newProduct, _selectedImages);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produk berhasil ditayangkan!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop(); // Back to marketplace
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal upload: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Jual Produk',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: AppColors.textDark),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Image Picker Section ---
              Text('Foto Produk (Max 4)', style: _labelStyle),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    if (index == _selectedImages.length) {
                      return _buildAddImageButton();
                    }
                    return _buildImageThumbnail(index);
                  },
                ),
              ),
              const SizedBox(height: 24),

              // --- Form Fields ---
              CustomTextField(
                label: 'Nama Produk',
                controller: _nameController,
                hint: 'Contoh: Keripik Pisang Original',
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                label: 'Harga (Rp)',
                controller: _priceController,
                keyboardType: TextInputType.number,
                hint: '15000',
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              Text('Kategori', style: _labelStyle),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              CustomTextField(
                label: 'Nomor WhatsApp',
                controller: _whatsappController,
                keyboardType: TextInputType.phone,
                hint: '62812345678',
                validator: (v) =>
                    v!.isEmpty ? 'Wajib untuk dihubungi pembeli' : null,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                label: 'Deskripsi Produk',
                controller: _descController,
                maxLines: 5,
                hint: 'Jelaskan detail produkmu...',
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 32),

              PrimaryButton(
                text: 'Tayangkan Produk',
                isLoading: _isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddImageButton() {
    if (_selectedImages.length >= 4) return const SizedBox.shrink();
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.neutral300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.add_a_photo, color: AppColors.neutral400),
      ),
    );
  }

  Widget _buildImageThumbnail(int index) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            _selectedImages[index],
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: GestureDetector(
            onTap: () => _removeImage(index),
            child: Container(
              color: Colors.black54,
              child: const Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  TextStyle get _labelStyle => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textDark,
  );
}
