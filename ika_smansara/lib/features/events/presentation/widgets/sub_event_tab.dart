import 'package:flutter/material.dart';
import '../../domain/entities/event_sub_event.dart';

class SubEventTab extends StatelessWidget {
  final List<EventSubEvent> subEvents;

  const SubEventTab({super.key, required this.subEvents});

  @override
  Widget build(BuildContext context) {
    if (subEvents.isEmpty) {
      return const Center(child: Text('Belum ada kegiatan pendukung'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: subEvents.length,
      itemBuilder: (context, index) {
        final subEvent = subEvents[index];
        final isFull = subEvent.registered >= subEvent.quota;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey[200]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subEvent.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subEvent.description,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isFull ? Colors.red[50] : Colors.blue[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isFull
                            ? 'Kuota Penuh'
                            : 'Sisa Kuota: ${subEvent.quota - subEvent.registered}/${subEvent.quota}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isFull ? Colors.red : Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: isFull
                    ? null
                    : () {
                        // TODO: Implement register logic
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF006D4E),
                  side: const BorderSide(color: Color(0xFF006D4E)),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Daftar'),
              ),
            ],
          ),
        );
      },
    );
  }
}
