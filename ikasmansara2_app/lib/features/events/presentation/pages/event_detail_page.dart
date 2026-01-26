import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/event.dart';
import '../../domain/entities/event_ticket.dart';
import '../../domain/entities/event_sub_event.dart';
import '../../domain/entities/event_sponsor.dart';
import '../../domain/usecases/get_event_detail.dart';
import '../../domain/usecases/get_event_tickets.dart';
import '../../domain/usecases/get_event_sub_events.dart';
import '../../domain/usecases/get_event_sponsors.dart';
import '../widgets/ticket_tab.dart';
import '../widgets/sub_event_tab.dart';
import '../widgets/sponsor_tab.dart';
import '../widgets/event_donation_tab.dart';

class EventDetailPage extends StatefulWidget {
  final String eventId;

  const EventDetailPage({super.key, required this.eventId});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<_EventData> _dataFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _dataFuture = _fetchData();
  }

  Future<_EventData> _fetchData() async {
    final eventId = widget.eventId;
    final results = await Future.wait([
      GetIt.I<GetEventDetail>().call(eventId),
      GetIt.I<GetEventTickets>().call(eventId),
      GetIt.I<GetEventSubEvents>().call(eventId),
      GetIt.I<GetEventSponsors>().call(eventId),
    ]);

    return _EventData(
      event: results[0] as Event,
      tickets: results[1] as List<EventTicket>,
      subEvents: results[2] as List<EventSubEvent>,
      sponsors: results[3] as List<EventSponsor>,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<_EventData>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Event not found'));
          }

          final data = snapshot.data!;
          final event = data.event;
          final dayName = DateFormat('EEEE', 'id').format(event.date);
          final dateStr = DateFormat('d MMMM yyyy', 'id').format(event.date);
          final fullDateString = '$dayName, $dateStr';

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 220,
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: event.banner != null && event.banner!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: event.banner!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) => Image.asset(
                            'assets/images/placeholder_event.png',
                            fit: BoxFit.cover,
                          ),
                        )
                      : Image.asset(
                          'assets/images/placeholder_event.png',
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  transform: Matrix4.translationValues(0, -20, 0),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          fullDateString.toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 16,
                            color: AppColors.textGrey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            event.time,
                            style: const TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: AppColors.textGrey,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textGrey,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        event.description,
                        style: const TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Tabs
                      TabBar(
                        controller: _tabController,
                        labelColor: AppColors.primary,
                        unselectedLabelColor: AppColors.textGrey,
                        indicatorColor: AppColors.primary,
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                        tabs: const [
                          Tab(text: 'Tiket'),
                          Tab(text: 'Sub-event'),
                          Tab(text: 'Sponsorship'),
                          Tab(text: 'Donasi'),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 600,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            TicketTab(tickets: data.tickets),
                            SubEventTab(subEvents: data.subEvents),
                            SponsorTab(sponsors: data.sponsors),
                            const EventDonationTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EventData {
  final Event event;
  final List<EventTicket> tickets;
  final List<EventSubEvent> subEvents;
  final List<EventSponsor> sponsors;

  _EventData({
    required this.event,
    required this.tickets,
    required this.subEvents,
    required this.sponsors,
  });
}
