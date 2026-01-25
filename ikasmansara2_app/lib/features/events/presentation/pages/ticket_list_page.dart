import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:go_router/go_router.dart';

class TicketListPage extends StatefulWidget {
  const TicketListPage({super.key});

  @override
  State<TicketListPage> createState() => _TicketListPageState();
}

class _TicketListPageState extends State<TicketListPage> {
  String _selectedFilter = 'Semua';

  final List<String> _filters = ['Semua', 'Lunas', 'Menunggu', 'Kadaluarsa'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Tiketku'),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: _filters.map((filter) {
                final isActive = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.primaryLight.withValues(alpha: 0.1)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isActive
                              ? AppColors.primary
                              : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: isActive
                              ? AppColors.primary
                              : AppColors.textGrey,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _TicketCard(
                  title: 'Jalan Sehat & Reuni Akbar 2026',
                  date: '20 Agus 2026',
                  count: 1,
                  price: 50000,
                  status: 'LUNAS',
                  onTap: () => context.push('/ticket-detail'),
                ),
                _TicketCard(
                  title: 'Workshop Digital Marketing',
                  date: '15 Sep 2026',
                  count: 1,
                  price: 150000,
                  status: 'MENUNGGU',
                  onTap: () {}, // Show payment modal logic
                ),
                _TicketCard(
                  title: 'Gala Dinner Alumni',
                  date: '01 Jan 2025',
                  count: 2,
                  price: 300000,
                  status: 'KADALUARSA',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final String title;
  final String date;
  final int count;
  final double price;
  final String status;
  final VoidCallback onTap;

  const _TicketCard({
    required this.title,
    required this.date,
    required this.count,
    required this.price,
    required this.status,
    required this.onTap,
  });

  Color _getStatusColor() {
    switch (status) {
      case 'LUNAS':
        return const Color(0xFF166534); // Green
      case 'MENUNGGU':
        return const Color(0xFFD97706); // Orange
      case 'KADALUARSA':
        return const Color(0xFF991B1B); // Red
      default:
        return AppColors.textGrey;
    }
  }

  Color _getStatusBgColor() {
    switch (status) {
      case 'LUNAS':
        return const Color(0xFFDCFCE7);
      case 'MENUNGGU':
        return const Color(0xFFFEF3C7);
      case 'KADALUARSA':
        return const Color(0xFFFEE2E2);
      default:
        return Colors.grey[200]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$date • $count Tiket',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusBgColor(),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rp ${price.toStringAsFixed(0)}', // Basic formatting
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      status == 'LUNAS' ? 'Lihat Tiket →' : 'Detail',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
