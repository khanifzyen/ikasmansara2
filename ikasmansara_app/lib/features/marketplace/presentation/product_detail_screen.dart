import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ikasmansara_app/core/theme/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ikasmansara_app/core/network/api_endpoints.dart';
import 'dart:io';

import 'package:ikasmansara_app/features/marketplace/domain/entities/product_entity.dart';
import 'providers/marketplace_providers.dart';

// Provides the product detail.
// We can use a family provider or just fetch in the consumer widget.
final productDetailProvider = FutureProvider.family<ProductEntity, String>((
  ref,
  id,
) async {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getProductDetail(id);
});

class ProductDetailScreen extends ConsumerWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailProvider(productId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Detail Produk'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: productAsync.when(
        data: (product) => _ProductDetailContent(product: product),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      bottomNavigationBar: productAsync.when(
        data: (product) => _ContactSellerButton(product: product),
        loading: () => const SizedBox.shrink(),
        error: (_, _) => const SizedBox.shrink(),
      ),
    );
  }
}

class _ProductDetailContent extends StatelessWidget {
  final ProductEntity product;

  const _ProductDetailContent({required this.product});

  String _getImageUrl() {
    if (product.images.isEmpty) return 'https://via.placeholder.com/300';

    // Construct PocketBase Image URL
    final baseUrl = dotenv.env['POCKETBASE_URL'] ?? 'http://127.0.0.1:8090';

    String effectiveBaseUrl = baseUrl;
    // Basic fix for android emulator
    if (Platform.isAndroid && effectiveBaseUrl.contains('127.0.0.1')) {
      effectiveBaseUrl = effectiveBaseUrl.replaceFirst('127.0.0.1', '10.0.2.2');
    }

    return '$effectiveBaseUrl/api/files/${ApiEndpoints.products}/${product.id}/${product.images.first}';
  }

  @override
  Widget build(BuildContext context) {
    final formattedPrice = 'Rp ${product.price.toStringAsFixed(0)}';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          CachedNetworkImage(
            imageUrl: _getImageUrl(),
            width: double.infinity,
            height: 300,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              height: 300,
              color: Colors.grey[200],
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              height: 300,
              color: Colors.grey[200],
              child: const Icon(
                Icons.broken_image,
                size: 50,
                color: Colors.grey,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Chip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    product.category,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Title
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Price
                Text(
                  formattedPrice,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 24),

                // Seller Info Section
                const Divider(),
                const SizedBox(height: 12),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: product.seller?.avatar != null
                          ? NetworkImage(
                              product.seller!.avatar!,
                            ) // Simplified, assumes full URL in entity or need helper
                          : null,
                      child: product.seller?.avatar == null
                          ? const Icon(Icons.person, color: Colors.grey)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.seller?.name ?? 'Penjual',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Angkatan ${product.seller?.angkatan ?? "-"}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 16),

                // Description
                const Text(
                  'Deskripsi',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  product.description,
                  style: const TextStyle(height: 1.5, color: Colors.black87),
                ),
                const SizedBox(height: 80), // Bottom padding for FAB/Button
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactSellerButton extends ConsumerWidget {
  final ProductEntity product;

  const _ContactSellerButton({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton.icon(
          onPressed: () {
            ref
                .read(contactSellerProvider)
                .call(
                  whatsappNumber: product.whatsapp,
                  message:
                      'Halo, saya tertarik dengan produk ${product.name} di Aplikasi IKA SMANSARA.',
                );
          },
          icon: const Icon(Icons.chat), // WhatsApp icon ideally
          label: const Text('Hubungi Penjual (WhatsApp)'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green, // WhatsApp green
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
