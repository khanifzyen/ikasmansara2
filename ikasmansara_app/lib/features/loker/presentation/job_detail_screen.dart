import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ikasmansara_app/features/loker/presentation/providers/loker_providers.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../common_widgets/buttons/primary_button.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/entities/job_entity.dart';
import 'loker_list_controller.dart';

class JobDetailScreen extends ConsumerStatefulWidget {
  final String jobId;

  const JobDetailScreen({super.key, required this.jobId});

  @override
  ConsumerState<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends ConsumerState<JobDetailScreen> {
  @override
  Widget build(BuildContext context) {
    // We reuse the list controller to find the job, or we could fetch detail specifically
    // For simplicity, we can fetch detail if we don't have it, but for now let's rely on list
    // or add a specific provider for detail. Better to fetch detail to ensure fresh data.
    // However, since we don't have a specific detail provider yet, let's look it up from the list first
    // If not found (e.g. deep link), we should fetch.
    // For this iteration, let's assume it's in the list or show loading then error.

    // Better approach: Let's create a FutureProvider family for job detail in the controller file
    // But to respect the plan, I'll implement a simple fetch or lookup.

    final jobAsync = ref.watch(jobDetailProvider(widget.jobId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Detail Pekerjaan',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: jobAsync.when(
        data: (job) => _buildContent(context, job),
        loading: () => _buildLoading(),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      bottomNavigationBar: jobAsync.hasValue
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: PrimaryButton(
                text: 'Lamar Sekarang',
                onPressed: () => _applyJob(jobAsync.value!),
              ),
            )
          : null,
    );
  }

  Widget _buildContent(BuildContext context, JobEntity job) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Center(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    LucideIcons.briefcase,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  job.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  job.company,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Chips
          Wrap(
            spacing: 8,
            children: [
              _buildInfoChip(LucideIcons.mapPin, job.location),
              _buildInfoChip(LucideIcons.clock, job.type),
              if (job.salaryRange != null)
                _buildInfoChip(LucideIcons.banknote, job.salaryRange!),
            ],
          ),
          const SizedBox(height: 32),

          // Description
          const Text(
            'Deskripsi Pekerjaan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            job.description,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textDark,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),

          // Posted By
          if (job.postedBy != null) ...[
            const Text(
              'Diposting oleh',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(
                    job.postedBy!.name[0].toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.postedBy!.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      'Alumni Angkatan ${job.postedBy!.angkatan ?? "-"}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(width: 80, height: 80, color: Colors.white),
            const SizedBox(height: 16),
            Container(width: 200, height: 24, color: Colors.white),
            const SizedBox(height: 8),
            Container(width: 120, height: 16, color: Colors.white),
            const SizedBox(height: 32),
            Container(width: double.infinity, height: 200, color: Colors.white),
          ],
        ),
      ),
    );
  }

  void _applyJob(JobEntity job) async {
    if (job.link != null && job.link!.isNotEmpty) {
      final uri = Uri.parse(job.link!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tidak dapat membuka link')),
          );
        }
      }
    } else {
      // Show generic message if no link
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Silakan hubungi postingan ini untuk info lebih lanjut',
            ),
          ),
        );
      }
    }
  }
}

// Add the provider here for simplicity or move to controller file
final jobDetailProvider = FutureProvider.family<JobEntity, String>((
  ref,
  id,
) async {
  final repository = ref.watch(jobRepositoryProvider);
  return repository.getJobDetail(id);
});
