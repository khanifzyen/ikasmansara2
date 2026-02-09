import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../events/domain/entities/event.dart';
import '../../../core/presentation/widgets/admin_responsive_scaffold.dart';
import '../../../core/presentation/widgets/admin_stat_card.dart';
import '../bloc/admin_events_bloc.dart';
import '../widgets/event_edit_form_tab.dart';
import '../widgets/participants_tab.dart';
import '../widgets/finance_placeholder_tab.dart';
import '../widgets/tickets_placeholder_tab.dart';

class AdminEventDetailPage extends StatefulWidget {
  final String eventId;

  const AdminEventDetailPage({super.key, required this.eventId});

  @override
  State<AdminEventDetailPage> createState() => _AdminEventDetailPageState();
}

class _AdminEventDetailPageState extends State<AdminEventDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AdminEventsBloc()..add(LoadEventDetail(widget.eventId)),
      child: AdminResponsiveScaffold(
        title: 'Event Dashboard',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => context.pop(),
        ),
        actions: [
          BlocBuilder<AdminEventsBloc, AdminEventsState>(
            builder: (context, state) {
              return IconButton(
                icon: const Icon(Icons.refresh, color: AppColors.textGrey),
                onPressed: () => context.read<AdminEventsBloc>().add(
                  LoadEventDetail(widget.eventId),
                ),
              );
            },
          ),
        ],
        body: BlocBuilder<AdminEventsBloc, AdminEventsState>(
          builder: (context, state) {
            final isDesktop = MediaQuery.of(context).size.width >= 768;

            if (state is AdminEventsLoading ||
                state is AdminEventsActionSuccess) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is AdminEventsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${state.message}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<AdminEventsBloc>().add(
                        LoadEventDetail(widget.eventId),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is AdminEventLoaded) {
              return _buildBody(isDesktop, state.event, state.stats);
            }

            return const Center(child: Text('Event tidak ditemukan'));
          },
        ),
      ),
    );
  }

  Widget _buildBody(bool isDesktop, Event event, Map<String, dynamic>? stats) {
    final totalParticipants = stats?['totalParticipants']?.toString() ?? '0';
    final totalIncome = stats?['totalIncome'] ?? 0;
    final formatter = NumberFormat.compactCurrency(
      locale: 'id',
      symbol: 'Rp',
      decimalDigits: 1,
    );

    return Column(
      children: [
        // Stats Cards
        Container(
          color: AppColors.background,
          padding: EdgeInsets.fromLTRB(
            isDesktop ? 24 : 16,
            isDesktop ? 16 : 12,
            isDesktop ? 24 : 16,
            0,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = isDesktop ? 4 : 2;
              final spacing = isDesktop ? 16.0 : 12.0;
              final totalSpacing = spacing * (crossAxisCount - 1);
              final cardWidth =
                  (constraints.maxWidth - totalSpacing) / crossAxisCount;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  SizedBox(
                    width: cardWidth,
                    child: AdminStatCard(
                      icon: '👥',
                      value: totalParticipants,
                      label: 'Pendaftar',
                      backgroundColor: const Color(0xFFE0F2FE),
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: AdminStatCard(
                      icon: '💰',
                      value: formatter.format(totalIncome),
                      label: 'Pemasukan',
                      backgroundColor: const Color(0xFFD1FAE5),
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: AdminStatCard(
                      icon: '💸',
                      value: 'Rp 0',
                      label: 'Pengeluaran',
                      backgroundColor: const Color(0xFFFEE2E2),
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: AdminStatCard(
                      icon: '⚖️',
                      value: formatter.format(totalIncome),
                      label: 'Saldo',
                      backgroundColor: const Color(0xFFFEF3C7),
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        // Custom Tab Pills
        Container(
          color: Theme.of(context).colorScheme.surface,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTabPill(0, 'Deskripsi'),
                const SizedBox(width: 8),
                _buildTabPill(1, 'Peserta'),
                const SizedBox(width: 8),
                _buildTabPill(2, 'Keuangan'),
                const SizedBox(width: 8),
                _buildTabPill(3, 'Tiket'),
              ],
            ),
          ),
        ),

        // TabBarView
        Expanded(
          child: Container(
            color: AppColors.background,
            child: TabBarView(
              controller: _tabController,
              children: [
                EventEditFormTab(event: event),
                ParticipantsTab(eventId: widget.eventId),
                const FinancePlaceholderTab(),
                const TicketsPlaceholderTab(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabPill(int index, String label) {
    final isSelected = _currentTabIndex == index;
    return GestureDetector(
      onTap: () {
        _tabController.animateTo(index);
        setState(() => _currentTabIndex = index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textDark,
          ),
        ),
      ),
    );
  }
}
