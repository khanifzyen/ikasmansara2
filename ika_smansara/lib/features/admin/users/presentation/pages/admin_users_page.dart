import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../core/presentation/widgets/admin_responsive_scaffold.dart';
import '../../../core/presentation/widgets/admin_list_card.dart';
import '../bloc/admin_users_bloc.dart';

class AdminUsersPage extends StatelessWidget {
  const AdminUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdminUsersBloc()..add(const LoadAllUsers()),
      child: const _AdminUsersView(),
    );
  }
}

class _AdminUsersView extends StatefulWidget {
  const _AdminUsersView();

  @override
  State<_AdminUsersView> createState() => _AdminUsersViewState();
}

class _AdminUsersViewState extends State<_AdminUsersView> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<AdminUsersBloc>().add(const LoadMoreUsers());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.8); // Trigger at 80%
  }

  void _onFilterChanged(String filter) {
    setState(() => _selectedFilter = filter);

    if (filter == 'pending') {
      context.read<AdminUsersBloc>().add(const LoadPendingUsers());
    } else if (filter == 'alumni') {
      context.read<AdminUsersBloc>().add(
        const LoadAllUsers(filter: 'role = "alumni"'),
      );
    } else if (filter == 'public') {
      context.read<AdminUsersBloc>().add(
        const LoadAllUsers(filter: 'role = "public"'),
      );
    } else if (filter == 'verified') {
      context.read<AdminUsersBloc>().add(
        const LoadAllUsers(filter: 'is_verified = true'),
      );
    } else {
      context.read<AdminUsersBloc>().add(const LoadAllUsers());
    }
  }

  void _onSearch(String query) {
    if (query.isEmpty) {
      _onFilterChanged(_selectedFilter);
    } else {
      context.read<AdminUsersBloc>().add(SearchUsersEvent(query));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminResponsiveScaffold(
      title: 'Kelola Users',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: AppColors.textGrey),
          onPressed: () => _onFilterChanged(_selectedFilter),
        ),
      ],
      body: BlocConsumer<AdminUsersBloc, AdminUsersState>(
        listener: (context, state) {
          if (state is AdminUsersActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state is AdminUsersError) {
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
              // Search Bar
              Container(
                color: Theme.of(context).colorScheme.surface,
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  onSubmitted: _onSearch,
                  decoration: InputDecoration(
                    hintText: 'Cari user...',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textLight,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.textLight,
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),

              // Filter Chips
              Container(
                color: Theme.of(context).colorScheme.surface,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                        label: 'Pending',
                        isSelected: _selectedFilter == 'pending',
                        onTap: () => _onFilterChanged('pending'),
                        badgeColor: AppColors.warning,
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Alumni',
                        isSelected: _selectedFilter == 'alumni',
                        onTap: () => _onFilterChanged('alumni'),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Umum',
                        isSelected: _selectedFilter == 'public',
                        onTap: () => _onFilterChanged('public'),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Verified',
                        isSelected: _selectedFilter == 'verified',
                        onTap: () => _onFilterChanged('verified'),
                        badgeColor: AppColors.success,
                      ),
                    ],
                  ),
                ),
              ),

              // User List
              Expanded(child: _buildUserList(state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUserList(AdminUsersState state) {
    if (state is AdminUsersLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is AdminUsersLoaded) {
      if (state.users.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('👤', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              Text(
                'Tidak ada user',
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
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: state.users.length + (state.hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= state.users.length) {
              // Loading indicator at bottom
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: state.isLoadingMore
                      ? const CircularProgressIndicator()
                      : const SizedBox.shrink(),
                ),
              );
            }

            final user = state.users[index];
            final avatarUrl = user.avatar != null && user.avatar!.isNotEmpty
                ? '${AppConstants.pocketBaseUrl}/api/files/users/${user.id}/${user.avatar}'
                : null;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AdminListCard(
                imageUrl: avatarUrl,
                avatarText: user.name.isNotEmpty
                    ? user.name[0].toUpperCase()
                    : '?',
                avatarColor: user.isAlumni
                    ? AppColors.primaryLight
                    : AppColors.infoLight,
                title: user.name,
                subtitle: '${user.email} • Angkatan ${user.angkatan ?? "-"}',
                badge: AdminBadge(
                  text: user.isVerified ? 'Verified' : 'Pending',
                  type: user.isVerified
                      ? AdminBadgeType.success
                      : AdminBadgeType.warning,
                ),
                onTap: () => context.push('/admin/users/${user.id}'),
              ),
            );
          },
        ),
      );
    }

    if (state is AdminUsersError) {
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
