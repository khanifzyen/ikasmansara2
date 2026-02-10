import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_colors.dart';

import '../../../core/presentation/widgets/admin_responsive_scaffold.dart';
import '../../../core/presentation/widgets/admin_list_card.dart';
import '../bloc/admin_events_bloc.dart';
import 'admin_event_wizard_page.dart';

class AdminEventsPage extends StatelessWidget {
  const AdminEventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdminEventsBloc()..add(const LoadAllEvents()),
      child: const _AdminEventsView(),
    );
  }
}

class _AdminEventsView extends StatefulWidget {
  const _AdminEventsView();

  @override
  State<_AdminEventsView> createState() => _AdminEventsViewState();
}

class _AdminEventsViewState extends State<_AdminEventsView> {
  String _selectedFilter = 'all';

  void _onFilterChanged(String filter) {
    setState(() => _selectedFilter = filter);

    if (filter == 'active') {
      context.read<AdminEventsBloc>().add(
        const LoadAllEvents(filter: 'status = "active"'),
      );
    } else if (filter == 'upcoming') {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      context.read<AdminEventsBloc>().add(
        LoadAllEvents(filter: 'date >= "$today"'),
      );
    } else if (filter == 'past') {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      context.read<AdminEventsBloc>().add(
        LoadAllEvents(filter: 'date < "$today"'),
      );
    } else if (filter == 'draft') {
      context.read<AdminEventsBloc>().add(
        const LoadAllEvents(filter: 'status = "draft"'),
      );
    } else {
      context.read<AdminEventsBloc>().add(const LoadAllEvents());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminResponsiveScaffold(
      title: 'Kelola Events',
      hideBackButton: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: AppColors.textGrey),
          onPressed: () => _onFilterChanged(_selectedFilter),
        ),
      ],
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminEventWizardPage()),
          );
          if (result == true) {
            if (mounted) {
              _onFilterChanged(_selectedFilter);
            }
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: BlocConsumer<AdminEventsBloc, AdminEventsState>(
        listener: (context, state) {
          if (state is AdminEventsActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state is AdminEventsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // Filter Chips
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'Semua',
                        isSelected: _selectedFilter == 'all',
                        onTap: () => _onFilterChanged('all'),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Aktif',
                        isSelected: _selectedFilter == 'active',
                        onTap: () => _onFilterChanged('active'),
                        badgeColor: AppColors.success,
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Upcoming',
                        isSelected: _selectedFilter == 'upcoming',
                        onTap: () => _onFilterChanged('upcoming'),
                        badgeColor: AppColors.info,
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Selesai',
                        isSelected: _selectedFilter == 'past',
                        onTap: () => _onFilterChanged('past'),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Draft',
                        isSelected: _selectedFilter == 'draft',
                        onTap: () => _onFilterChanged('draft'),
                        badgeColor: AppColors.warning,
                      ),
                    ],
                  ),
                ),
              ),

              // Event List
              Expanded(child: _buildEventList(state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEventList(AdminEventsState state) {
    if (state is AdminEventsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is AdminEventsLoaded) {
      if (state.events.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('📅', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              Text(
                'Tidak ada event',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: AppColors.textGrey,
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async => _onFilterChanged(_selectedFilter),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: state.events.length,
          itemBuilder: (context, index) {
            final event = state.events[index];
            final dateFormatted = DateFormat(
              'dd MMM yy',
              'id',
            ).format(event.date);
            final isActive = event.status == 'active';
            final isPast = event.date.isBefore(DateTime.now());

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AdminListCard(
                avatarText: '📅',
                avatarColor: isActive
                    ? AppColors.successLight
                    : AppColors.warningLight,
                title: event.title,
                subtitle: '$dateFormatted • ${event.time} • ${event.location}',
                badge: AdminBadge(
                  text: isPast ? 'Selesai' : (isActive ? 'Aktif' : 'Draft'),
                  type: isPast
                      ? AdminBadgeType.grey
                      : (isActive
                            ? AdminBadgeType.success
                            : AdminBadgeType.warning),
                ),
                onTap: () => context.push('/admin/events/${event.id}'),
              ),
            );
          },
        ),
      );
    }

    if (state is AdminEventsError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${state.message}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _onFilterChanged(_selectedFilter),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? badgeColor;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (badgeColor != null) ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
