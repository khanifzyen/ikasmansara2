import 'package:flutter/material.dart';
import '../../domain/entities/event_sponsor.dart';

class SponsorTab extends StatelessWidget {
  final List<EventSponsor> sponsors;

  const SponsorTab({super.key, required this.sponsors});

  @override
  Widget build(BuildContext context) {
    if (sponsors.isEmpty) {
      return const Center(child: Text('Belum ada paket sponsorship'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sponsors.length,
      itemBuilder: (context, index) {
        final sponsor = sponsors[index];
        Color badgeColor;
        Color badgeTextColor;

        switch (sponsor.type.toLowerCase()) {
          case 'platinum':
            badgeColor = const Color(0xFFE0F2FE);
            badgeTextColor = const Color(0xFF0369A1);
            break;
          case 'gold':
            badgeColor = const Color(0xFFFFF9E6);
            badgeTextColor = const Color(0xFFB45309);
            break;
          case 'silver':
            badgeColor = const Color(0xFFF3F4F6);
            badgeTextColor = const Color(0xFF4B5563);
            break;
          default:
            badgeColor = Theme.of(context).colorScheme.surfaceContainerHighest;
            badgeTextColor = Colors.black;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border.all(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  sponsor.type.toUpperCase(),
                  style: TextStyle(
                    color: badgeTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Rp ${sponsor.price}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 16),
              Column(
                children: sponsor.benefits.map((benefit) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Text('✅', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            benefit,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: index == 0
                        ? const Color(0xFF006D4E)
                        : Colors.white,
                    foregroundColor: index == 0
                        ? Colors.white
                        : const Color(0xFF006D4E),
                    side: BorderSide(
                      color: const Color(
                        0xFF006D4E,
                      ).withValues(alpha: index == 0 ? 0 : 1),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Pilih ${sponsor.type}'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
