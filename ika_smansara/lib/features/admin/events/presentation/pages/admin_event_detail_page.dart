import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../events/domain/entities/event.dart';
import '../../../core/presentation/widgets/admin_responsive_scaffold.dart';
import '../../../core/presentation/widgets/admin_stat_card.dart';
import '../../data/datasources/admin_events_remote_data_source.dart';
import '../../data/repositories/admin_events_repository_impl.dart';
import '../widgets/event_edit_form_tab.dart';
import '../widgets/participants_placeholder_tab.dart';
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
  final _repository = AdminEventsRepositoryImpl(AdminEventsRemoteDataSource());
  Event? _event;
  bool _isLoading = true;
  String? _error;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadEvent();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadEvent() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final event = await _repository.getEventById(widget.eventId);
      setState(() {
        _event = event;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    return AdminResponsiveScaffold(
      title: _event?.title ?? 'Event Dashboard',
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
        onPressed: () => context.pop(),
      ),
      actions: [
        if (_event != null && !isDesktop)
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textGrey),
            onPressed: _loadEvent,
          ),
      ],
      body: _buildBody(isDesktop),
    );
  }

  Widget _buildBody(bool isDesktop) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadEvent, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_event == null) {
      return const Center(child: Text('Event tidak ditemukan'));
    }

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
                      value: '856',
                      label: 'Pendaftar',
                      backgroundColor: const Color(0xFFE0F2FE),
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: AdminStatCard(
                      icon: '💰',
                      value: 'Rp 42.8jt',
                      label: 'Pemasukan',
                      backgroundColor: const Color(0xFFD1FAE5),
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: AdminStatCard(
                      icon: '💸',
                      value: 'Rp 12.5jt',
                      label: 'Pengeluaran',
                      backgroundColor: const Color(0xFFFEE2E2),
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: AdminStatCard(
                      icon: '⚖️',
                      value: 'Rp 30.3jt',
                      label: 'Saldo',
                      backgroundColor: const Color(0xFFFEF3C7),
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        // TabBar
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            isScrollable: !isDesktop,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textGrey,
            indicatorColor: AppColors.primary,
            labelStyle: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            tabs: const [
              Tab(text: 'Deskripsi'),
              Tab(text: 'Peserta'),
              Tab(text: 'Keuangan'),
              Tab(text: 'Tiket'),
            ],
          ),
        ),

        // TabBarView
        Expanded(
          child: Container(
            color: AppColors.background,
            child: TabBarView(
              controller: _tabController,
              children: [
                EventEditFormTab(event: _event!),
                const ParticipantsPlaceholderTab(),
                const FinancePlaceholderTab(),
                const TicketsPlaceholderTab(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
