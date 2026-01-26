import 'package:flutter/material.dart';
import '../../domain/entities/event_ticket.dart';

class TicketTab extends StatefulWidget {
  final List<EventTicket> tickets;

  const TicketTab({super.key, required this.tickets});

  @override
  State<TicketTab> createState() => _TicketTabState();
}

class _TicketTabState extends State<TicketTab> {
  // Map to track quantity for each ticket type if multiple types
  // For now, assuming single ticket type based on mocks, but flexible for list
  final Map<String, int> _quantities = {};

  @override
  void initState() {
    super.initState();
    for (var ticket in widget.tickets) {
      _quantities[ticket.id] = 0;
    }
    // Default select 1 for the first available ticket
    if (widget.tickets.isNotEmpty) {
      _quantities[widget.tickets.first.id] = 1;
    }
  }

  void _updateQuantity(String ticketId, int change) {
    setState(() {
      final current = _quantities[ticketId] ?? 0;
      final newQuantity = current + change;
      if (newQuantity >= 0) {
        _quantities[ticketId] = newQuantity;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tickets.isEmpty) {
      return const Center(child: Text('Belum ada tiket tersedia'));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pesan Tiket Baru',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...widget.tickets.map((ticket) {
            final quantity = _quantities[ticket.id] ?? 0;
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ticket.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              ticket.description,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Rp ${ticket.price}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF006D4E), // AppColors.primary
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          InkWell(
                            onTap: () => _updateQuantity(ticket.id, -1),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.white,
                              ),
                              child: const Icon(Icons.remove, size: 16),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '$quantity',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 12),
                          InkWell(
                            onTap: () => _updateQuantity(ticket.id, 1),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.white,
                              ),
                              child: const Icon(Icons.add, size: 16),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          }),

          // Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF006D4E).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Pembayaran',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Rp ${_calculateTotal()}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF006D4E),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Implement buy logic
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006D4E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Beli Tiket Sekarang'),
            ),
          ),
        ],
      ),
    );
  }

  int _calculateTotal() {
    int total = 0;
    for (var ticket in widget.tickets) {
      total += ticket.price * (_quantities[ticket.id] ?? 0);
    }
    return total;
  }
}
