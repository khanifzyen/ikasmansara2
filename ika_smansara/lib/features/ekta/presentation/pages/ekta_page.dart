import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/adaptive/adaptive_container.dart';
import '../../../../core/utils/adaptive/adaptive_breakpoints.dart';

class EKTAPage extends StatelessWidget {
  const EKTAPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kartu Anggota Digital'),
        elevation: 0,
        surfaceTintColor: Colors.white,
      ),
      body: Padding(
        padding: AdaptiveBreakpoints.adaptivePadding(context),
        child: Column(
          children: [
            // E-KTA Card
            AdaptiveContainer(
              widthType: AdaptiveWidthType.card,
              child: Container(
                width: double.infinity,
                height: 220,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF006400), Color(0xFF004d00)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF006400).withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Pattern (simulated with icon opacity)
                    Positioned(
                      right: -20,
                      bottom: -20,
                      child: Icon(
                        Icons.school,
                        size: 150,
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'IKA SMANSARA',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.surface,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                              ),
                            ),
                            Container(
                              width: 50,
                              height: 35,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerHighest,
                                    Colors.grey[400] ?? const Color(0xFFBDBDBD),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color:
                                      Colors.grey[500] ??
                                      const Color(0xFF9E9E9E),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),

                        Text(
                          '1992.2010.045.8821',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.surface,
                            fontSize: 22,
                            fontFamily: 'Courier',
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            shadows: [
                              Shadow(
                                blurRadius: 2,
                                color: Colors.black26,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'NAMA ANGGOTA',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 10,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'BUDI SANTOSO',
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surface,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'ANGKATAN',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 10,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '2010',
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surface,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Icon(
                                Icons.qr_code,
                                size: 50,
                              ), // Placeholder QR
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: AdaptiveBreakpoints.adaptiveSpacing(context) * 6),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.download),
                    label: Text('Download'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: AdaptiveBreakpoints.adaptiveSpacing(context) / 2,
                ),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.share),
                    label: Text('Share'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: AdaptiveBreakpoints.adaptiveSpacing(context) * 6),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Catatan:\nKartu ini adalah bukti keanggotaan resmi IKA SMANSARA. Tunjukkan kartu ini untuk mendapatkan benefit khusus di merchant rekanan.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textGrey,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
