import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ikasmansara_app/core/constants/assets_path.dart';
import 'package:ikasmansara_app/core/theme/app_text_styles.dart';
import 'package:ikasmansara_app/features/profile/presentation/profile_controller.dart';
import 'package:qr_flutter/qr_flutter.dart';

class EKTAScreen extends ConsumerWidget {
  const EKTAScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileControllerProvider);
    final user = profileState.value;

    return Scaffold(
      backgroundColor: Colors.black, // Premium feel
      appBar: AppBar(
        title: const Text(
          'E-KTA IKA SMANSARA',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: user == null
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(24.0),
                child: AspectRatio(
                  aspectRatio: 1.58, // Standard ID Card ratio
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFB8860B),
                          Color(0xFFFFD700),
                          Color(0xFFB8860B),
                        ], // Gold Gradient
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Background Pattern (Optional)
                        Positioned.fill(
                          child: Opacity(
                            opacity: 0.1,
                            child: Image.asset(
                              AssetsPath.logo, // Assuming we have a logo
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const SizedBox(),
                            ),
                          ),
                        ),

                        // Content
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header
                              Row(
                                children: [
                                  Image.asset(
                                    AssetsPath.logo,
                                    width: 40,
                                    height: 40,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.school,
                                      size: 40,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'IKA SMANSARA',
                                        style: AppTextStyles.h3.copyWith(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'KARTU TANDA ANGGOTA',
                                        style: AppTextStyles.caption.copyWith(
                                          color: Colors.black87,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const Spacer(),

                              // User Info & QR
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'NAMA',
                                          style: AppTextStyles.caption.copyWith(
                                            color: Colors.black54,
                                          ),
                                        ),
                                        Text(
                                          user.name.toUpperCase(),
                                          style: AppTextStyles.h4.copyWith(
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'ANGKATAN',
                                          style: AppTextStyles.caption.copyWith(
                                            color: Colors.black54,
                                          ),
                                        ),
                                        Text(
                                          user.angkatan?.toString() ?? '-',
                                          style: AppTextStyles.bodyLarge
                                              .copyWith(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'ID ANGGOTA',
                                          style: AppTextStyles.caption.copyWith(
                                            color: Colors.black54,
                                          ),
                                        ),
                                        Text(
                                          user.id,
                                          style: AppTextStyles.caption.copyWith(
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: QrImageView(
                                      data: user.id,
                                      version: QrVersions.auto,
                                      size: 80.0,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
