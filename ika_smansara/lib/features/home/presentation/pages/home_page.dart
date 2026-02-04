import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../donations/presentation/bloc/donation_list_bloc.dart';
import '../../../events/presentation/bloc/events_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../news/presentation/bloc/news_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<DonationListBloc>()..add(FetchDonations()),
        ),
        BlocProvider(
          create: (context) => getIt<EventsBloc>()..add(const FetchEvents()),
        ),
        BlocProvider(
          create: (context) => getIt<NewsBloc>()..add(const FetchNewsList()),
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  String name = 'User SMANSARA';
                  String? avatar;
                  if (state is AuthAuthenticated) {
                    name = state.user.name;
                    avatar = state.user.avatar;
                  }

                  final avatarUrl = (avatar != null && avatar.isNotEmpty)
                      ? '${AppConstants.pocketBaseUrl}/api/files/users/${(state as AuthAuthenticated).user.id}/$avatar'
                      : null;

                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Halo, Alumni!',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textGrey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => context.push('/ticket-scanner'),
                              icon: const Icon(
                                Icons.qr_code_scanner,
                                color: AppColors.primary,
                              ),
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.primaryLight
                                    .withValues(alpha: 0.1),
                                shape: const CircleBorder(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                color: AppColors.border,
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: avatarUrl != null
                                      ? CachedNetworkImageProvider(avatarUrl)
                                      : const AssetImage(
                                              'assets/images/logo-ika.png',
                                            )
                                            as ImageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),

              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    context.read<DonationListBloc>().add(FetchDonations());
                    context.read<EventsBloc>().add(const FetchEvents());
                    context.read<NewsBloc>().add(const FetchNewsList());
                    context.read<AuthBloc>().add(const AuthCheckRequested());
                    await Future.delayed(const Duration(seconds: 1));
                  },
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      // E-KTA Preview
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          String angkatanText = 'ANGKATAN -';
                          String ektaDisplay =
                              'XXXX.XXXX.XXX'; // Placeholder matching schema structure

                          if (state is AuthAuthenticated) {
                            angkatanText =
                                'ANGKATAN ${state.user.angkatan ?? '-'}';

                            // UserEntity.nomorEkta returns '-' if data is incomplete
                            if (state.user.nomorEkta != '-') {
                              ektaDisplay = state.user.nomorEkta;
                            }
                          }
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  Color(0xFF004D38),
                                ], // Darker green
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.2,
                                  ),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      angkatanText,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    Icon(
                                      Icons.school,
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                      size: 20,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  ektaDisplay,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Courier',
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 30),

                      // Menu Grid
                      const _MenuGrid(),

                      const SizedBox(height: 30),
                      // Agenda Section
                      _SectionHeader(
                        title: 'Agenda Kegiatan',
                        onViewAll: () {
                          context.push('/events');
                        },
                      ),
                      const SizedBox(height: 16),
                      BlocBuilder<EventsBloc, EventsState>(
                        builder: (context, state) {
                          if (state is EventsLoaded) {
                            if (state.events.isEmpty) {
                              return const Center(
                                child: Text('Belum ada agenda kegiatan'),
                              );
                            }
                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: state.events.map((event) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 16),
                                    child: InkWell(
                                      onTap: () => context.push(
                                        '/event-detail',
                                        extra: event.id,
                                      ),
                                      child: _AgendaCard(
                                        day: DateFormat(
                                          'EEEE',
                                          'id',
                                        ).format(event.date),
                                        time: event.time,
                                        title: event.title,
                                        date: DateFormat(
                                          'dd MMMM yyyy',
                                          'id',
                                        ).format(event.date),
                                        location: event.location,
                                        isRegisterOpen:
                                            event.isRegistrationOpen,
                                        imageUrl: event.banner,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            );
                          }
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      ),

                      const SizedBox(height: 30),

                      // Donation Slider
                      _SectionHeader(
                        title: 'Program Donasi',
                        onViewAll: () {
                          context.push('/donation-list');
                        },
                      ),
                      const SizedBox(height: 16),
                      BlocBuilder<DonationListBloc, DonationListState>(
                        builder: (context, state) {
                          if (state is DonationListLoaded) {
                            if (state.donations.isEmpty) {
                              return const Center(
                                child: Text('Belum ada program donasi'),
                              );
                            }
                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: state.donations.map((donation) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 16),
                                    child: InkWell(
                                      onTap: () => context.push(
                                        '/donation-detail',
                                        extra: donation.id,
                                      ),
                                      child: _DonationCard(
                                        title: donation.title,
                                        amount: NumberFormat.currency(
                                          locale: 'id_ID',
                                          symbol: 'Rp ',
                                          decimalDigits: 0,
                                        ).format(donation.collectedAmount),
                                        percent: donation.progress,
                                        isUrgent: donation.priority == 'urgent',
                                        imageUrl: donation.banner,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            );
                          }
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      ),

                      const SizedBox(height: 30),

                      // News Section
                      _SectionHeader(
                        title: 'Kabar SMANSARA',
                        onViewAll: () {
                          context.push('/news');
                        },
                      ),
                      const SizedBox(height: 16),
                      BlocBuilder<NewsBloc, NewsState>(
                        builder: (context, state) {
                          if (state is NewsLoaded) {
                            if (state.newsList.isEmpty) {
                              return const Center(
                                child: Text('Belum ada berita terbaru'),
                              );
                            }
                            return Column(
                              children: state.newsList.take(3).map((news) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: InkWell(
                                    onTap: () => context.push(
                                      '/news-detail',
                                      extra: news.id,
                                    ),
                                    child: _NewsCard(
                                      title: news.title,
                                      tag: news.category.toUpperCase(),
                                      imageUrl: news.thumbnail,
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          }
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      ),
                      const SizedBox(height: 80), // Bottom padding
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuGrid extends StatelessWidget {
  const _MenuGrid();

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      _MenuItem(
        icon: Icons.volunteer_activism_outlined,
        label: 'Donasi',
        onTap: () => context.push('/donation-list'),
      ),
      _MenuItem(
        icon: Icons.confirmation_number_outlined,
        label: 'Kegiatan',
        onTap: () => context.push('/events'),
      ),
      _MenuItem(
        icon: Icons.newspaper_outlined,
        label: 'Berita',
        onTap: () => context.push('/news'),
      ),
      _MenuItem(
        icon: Icons.work_outline,
        label: 'Loker',
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fitur Loker akan segera hadir!')),
          );
        },
      ),
      _MenuItem(
        icon: Icons.shopping_bag_outlined,
        label: 'Market',
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fitur Market akan segera hadir!')),
          );
        },
      ),
      _MenuItem(
        icon: Icons.forum_outlined,
        label: 'Forum',
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fitur Forum akan segera hadir!')),
          );
        },
      ),
      _MenuItem(
        icon: Icons.people_outline,
        label: 'Direktori',
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fitur Direktori akan segera hadir!')),
          );
        },
      ),
      _MenuItem(
        icon: Icons.person_outline,
        label: 'Profil',
        onTap: () => context.push('/profile'),
      ),
    ];

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 0.75,
      children: menuItems,
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onViewAll;

  const _SectionHeader({required this.title, required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        TextButton(
          onPressed: onViewAll,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text('Lihat Semua'),
        ),
      ],
    );
  }
}

class _AgendaCard extends StatelessWidget {
  final String day;
  final String time;
  final String title;
  final String date;
  final String location;
  final bool isRegisterOpen;
  final String? imageUrl;

  const _AgendaCard({
    required this.day,
    required this.time,
    required this.title,
    required this.date,
    required this.location,
    required this.isRegisterOpen,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: imageUrl != null && imageUrl!.startsWith('http')
                      ? CachedNetworkImage(
                          imageUrl: imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.image, color: Colors.grey),
                          ),
                        )
                      : Image.asset(
                          imageUrl ?? 'assets/images/placeholder_event.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.event, color: Colors.grey),
                        ),
                ),
              ),
              if (isRegisterOpen)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'OPEN REGISTRATION',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$day, $date • $time',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '📍 $location',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  final String title;
  final String tag;
  final String? imageUrl;

  const _NewsCard({required this.title, required this.tag, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
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
      child: Row(
        children: [
          Container(
            width: 80,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: imageUrl != null && imageUrl!.startsWith('http')
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.image, size: 20),
                      ),
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      imageUrl ?? 'assets/images/placeholder_news.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        'assets/images/placeholder_news.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tag,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DonationCard extends StatelessWidget {
  final String title;
  final String amount;
  final double percent;
  final bool isUrgent;
  final String? imageUrl;

  const _DonationCard({
    required this.title,
    required this.amount,
    required this.percent,
    required this.isUrgent,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(12),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: (imageUrl != null && imageUrl!.startsWith('http'))
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.image),
                          ),
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          imageUrl ?? 'assets/images/placeholder_donation.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.volunteer_activism),
                        ),
                      ),
              ),
              if (isUrgent)
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'URGENT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percent,
            backgroundColor: Colors.grey[200],
            color: AppColors.primary,
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                amount,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: AppColors.primary,
                ),
              ),
              Text(
                '${(percent * 100).toInt()}%',
                style: const TextStyle(fontSize: 10, color: AppColors.textGrey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
