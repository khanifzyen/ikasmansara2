import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
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
// import '../widgets/sub_event_tab.dart';
// import '../widgets/sponsor_tab.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/event_booking_bloc.dart';
// import '../widgets/event_donation_tab.dart';

class EventDetailPage extends StatefulWidget {
  final String eventId;

  const EventDetailPage({super.key, required this.eventId});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  late Future<_EventData> _dataFuture;
  bool _isTitleVisible = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _dataFuture = _fetchData();
  }

  void _scrollListener() {
    // 220 is expandedHeight. 160 is a threshold where title should appear.
    // Adjust kToolbarHeight equivalent (usually 56).
    // Let's say when offset > 220 - 60 = 160.
    if (_scrollController.hasClients) {
      final isVisible = _scrollController.offset > 160;
      if (isVisible != _isTitleVisible) {
        setState(() {
          _isTitleVisible = isVisible;
        });
      }
    }
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {});
    } else {
      setState(() {});
    }
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
    _scrollController.dispose();
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

          return BlocProvider(
            create: (_) => GetIt.I<EventBookingBloc>(),
            child: BlocListener<EventBookingBloc, EventBookingState>(
              listener: (context, state) async {
                // Added async here
                if (state is EventBookingSuccess) {
                  // Navigate to payment
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Pesanan berhasil dibuat, membuka pembayaran...',
                      ),
                    ),
                  );
                  if (state.booking.snapRedirectUrl != null) {
                    // Using a helper method or direct url launch.
                    // Since we can't import url_launcher here yet (dart analysis), let's assume we implement a method
                    // or import it at top (replace_file_content specific).
                    // I will add import in next step or use separate method.
                    _launchPaymentUrl(
                      context,
                      state.booking.snapRedirectUrl!,
                      state.booking.bookingId,
                    );
                  }
                } else if (state is EventBookingFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal membuat pesanan: ${state.message}'),
                    ),
                  );
                }
              },
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    expandedHeight: 220,
                    elevation: 0,
                    backgroundColor: Colors.white,
                    title: _isTitleVisible
                        ? Text(
                            event.title,
                            style: const TextStyle(
                              color: AppColors.textDark,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : null,
                    centerTitle: false,
                    leading: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _isTitleVisible
                              ? Colors.transparent
                              : Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_back,
                          color: _isTitleVisible
                              ? AppColors.textDark
                              : Colors.black,
                          size: 20,
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background:
                          event.banner != null && event.banner!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: event.banner!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
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
                              color: AppColors.primaryLight.withValues(
                                alpha: 0.1,
                              ),
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
                          Html(
                            data: event.description,
                            style: {
                              "body": Style(
                                color: AppColors.textGrey,
                                fontSize: FontSize(14),
                                lineHeight: LineHeight(1.5),
                                margin: Margins.zero,
                                padding: HtmlPaddings.zero,
                              ),
                            },
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
                              // Tab(text: 'Sub-event'),
                              // Tab(text: 'Sponsorship'),
                              // Tab(text: 'Donasi'),
                            ],
                          ),
                          const SizedBox(height: 24),
                          SizedBox(child: _buildTabContent(data)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _launchPaymentUrl(
    BuildContext context,
    String url,
    String bookingId,
  ) async {
    await context.push<bool>(
      '/payment',
      extra: {
        'paymentUrl': url,
        'bookingId': bookingId,
        'fromEventDetail': true,
      },
    );
  }

  Widget _buildTabContent(_EventData data) {
    switch (_tabController.index) {
      case 0:
        return TicketTab(tickets: data.tickets, enableScroll: false);
      /*
      case 1:
        return SubEventTab(subEvents: data.subEvents);
      case 2:
        return SponsorTab(sponsors: data.sponsors);
      case 3:
        return const EventDonationTab();
      */
      default:
        return const SizedBox.shrink();
    }
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
