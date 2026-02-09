import 'package:flutter/material.dart';

class EventDonationTab extends StatelessWidget {
  EventDonationTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ... (children will be preserved)

        // Summary
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF006D4E), Color(0xFF004D38)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Donasi Terkumpul',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              SizedBox(height: 8),
              Text(
                'Rp 0',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.surface,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.people, color: Theme.of(context).colorScheme.surface, size: 14),
                    SizedBox(width: 6),
                    Text(
                      '0 Donatur',
                      style: TextStyle(color: Theme.of(context).colorScheme.surface, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 24),
        Text(
          'Donasi Personal',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'Dukungan sukarela untuk operasional acara.',
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        SizedBox(height: 20),

        // Form placeholder
        TextField(
          decoration: InputDecoration(
            labelText: 'Nominal Donasi',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            labelText: 'Pesan / Doa (Opsional)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          maxLines: 3,
        ),
        SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF006D4E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Lanjut Pembayaran'),
          ),
        ),
      ],
    );
  }
}
