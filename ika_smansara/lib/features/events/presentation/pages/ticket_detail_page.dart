import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TicketDetailPage extends StatelessWidget {
  const TicketDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail Tiket',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Tunjukkan QR Code ini ke panitia.',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 24),

            // Ticket Content
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  // QR Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.border,
                          style: BorderStyle.solid,
                        ),
                      ), // Should be dashed ideally
                    ),
                    child: Column(
                      children: [
                        QrImageView(
                          data: 'JS-2026-XXXX',
                          version: QrVersions.auto,
                          size: 200.0,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Kode Booking: JS-2026-XXXX',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'BELUM CHECK-IN',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Info Section
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _InfoRow(
                          label: 'Event',
                          value: 'Jalan Sehat & Reuni Akbar 2026',
                        ),
                        const SizedBox(height: 12),
                        _InfoRow(
                          label: 'Waktu',
                          value: '20 Agustus 2026 • 06:00 WIB',
                        ),
                        const SizedBox(height: 12),
                        _InfoRow(
                          label: 'Lokasi',
                          value: 'Lapangan Utama SMAN 1 Jepara',
                        ),
                        const SizedBox(height: 12),
                        _InfoRow(label: 'Tiket', value: '1 Tiket'),

                        const SizedBox(height: 24),

                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Rincian Kaos:',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textGrey,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Row(
                          children: [
                            Chip(
                              label: Text(
                                'Size L',
                                style: TextStyle(fontSize: 12),
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
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.textGrey),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ),
      ],
    );
  }
}
