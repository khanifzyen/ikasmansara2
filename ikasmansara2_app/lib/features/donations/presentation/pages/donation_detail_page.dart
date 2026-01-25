import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class DonationDetailPage extends StatefulWidget {
  const DonationDetailPage({super.key});

  @override
  State<DonationDetailPage> createState() => _DonationDetailPageState();
}

class _DonationDetailPageState extends State<DonationDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 250,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                  size: 20,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/logo-ika.png', // Placeholder
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Text(
                        'URGENT',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Berakhir dalam 15 hari',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Renovasi Masjid Sekolah SMAN 1 Jepara',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Organizer
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.background,
                        child: Icon(
                          Icons.person,
                          size: 16,
                          color: AppColors.textGrey,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Oleh: Panitia Pembangunan Masjid',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Progress Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Rp 35.000.000',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              'dari Rp 50.000.000',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textGrey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: 0.7,
                          backgroundColor: Colors.grey[300],
                          color: AppColors.primary,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 8),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '70% Terkumpul',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textGrey,
                              ),
                            ),
                            Text(
                              '145 Donatur',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textGrey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Description
                  const Text(
                    'Masjid sekolah kita yang telah berdiri sejak tahun 1990 kini membutuhkan renovasi mendesak. Atap yang bocor dan kapasitas yang sudah tidak memadai menjadi alasan utama penggalangan dana ini.\n\nKami mengajak seluruh alumni SMAN 1 Jepara untuk bahu-membahu mewujudkan tempat ibadah yang nyaman bagi adik-adik kita yang sedang menuntut ilmu.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: AppColors.textDark,
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Text(
                    'Dana yang terkumpul akan digunakan untuk:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  _BulletPoint('Perbaikan atap dan plafon'),
                  _BulletPoint('Perluasan area sholat putri'),
                  _BulletPoint('Peremajaan tempat wudhu'),
                  _BulletPoint('Instalasi pendingin ruangan (AC)'),

                  const SizedBox(height: 32),

                  const Text(
                    'Donatur Terbaru',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _DonorItem(
                    name: "Budi Santoso '10",
                    amount: "Rp 500.000",
                    time: "2 jam yang lalu",
                    initials: "BS",
                    color: Colors.blue,
                  ),
                  _DonorItem(
                    name: "Hamba Allah",
                    amount: "Rp 1.000.000",
                    time: "5 jam yang lalu",
                    initials: "NN",
                    color: Colors.orange,
                  ),

                  const SizedBox(height: 80), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
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
        child: ElevatedButton(
          onPressed: () {
            // Show Payment Modal Logic
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Fitur Pembayaran Donasi akan segera hadir'),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 8,
            shadowColor: AppColors.primary.withValues(alpha: 0.3),
          ),
          child: const Text('Donasi Sekarang'),
        ),
      ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  final String text;
  const _BulletPoint(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(height: 1.5, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _DonorItem extends StatelessWidget {
  final String name;
  final String amount;
  final String time;
  final String initials;
  final MaterialColor color;

  const _DonorItem({
    required this.name,
    required this.amount,
    required this.time,
    required this.initials,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color[50],
            foregroundColor: color[700],
            radius: 20,
            child: Text(
              initials,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
