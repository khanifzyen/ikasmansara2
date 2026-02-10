import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../bloc/settings_bloc.dart';
import 'printer_settings_page.dart';
import 'change_password_page.dart';
import 'about_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<SettingsBloc>()..add(LoadAppSettings()),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Pengaturan',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () => context.pop(),
          ),
        ),
        body: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) {
            final isNotifEnabled = (state is SettingsLoaded)
                ? state.settings.notificationsEnabled
                : true;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSectionLabel(context, 'Perangkat'),
                _buildListTile(
                  context,
                  icon: Icons.print_outlined,
                  title: 'Konfigurasi Printer',
                  subtitle: 'Atur koneksi printer thermal',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PrinterSettingsPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                _buildSectionLabel(context, 'Akun & Keamanan'),
                _buildListTile(
                  context,
                  icon: Icons.lock_outline,
                  title: 'Ubah Kata Sandi',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ChangePasswordPage()),
                    );
                  },
                ),
                _buildListTile(
                  context,
                  icon: Icons.delete_forever_outlined,
                  title: 'Hapus Akun',
                  titleColor: AppColors.error,
                  onTap: () {
                    _showDeleteAccountDialog(context);
                  },
                ),
                const SizedBox(height: 24),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.blue,
                    ),
                  ),
                  title: Text(
                    'Notifikasi',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  value: isNotifEnabled,
                  onChanged: (value) {
                    context.read<SettingsBloc>().add(
                      ToggleNotifications(value),
                    );
                  },
                  activeThumbColor: AppColors.primary,
                ),

                //                 const Divider(height: 1),
                // Theme selection disabled - app locked to light theme
                // _buildListTile(
                //   context,
                //   icon: Icons.brightness_6_outlined,
                //   title: 'Tampilan',
                //   subtitle: _getThemeText(
                //     (state is SettingsLoaded)
                //         ? state.settings.themeMode
                //         : 'system',
                //   ),
                //   onTap: () {
                //     _showThemeSelectionDialog(
                //       context,
                //       (state is SettingsLoaded)
                //           ? state.settings.themeMode
                //           : 'system',
                //     );
                //   },
                // ),
                const SizedBox(height: 24),
                _buildSectionLabel(context, 'Informasi'),
                _buildListTile(
                  context,
                  icon: Icons.privacy_tip_outlined,
                  title: 'Kebijakan Privasi',
                  onTap: () async {
                    final Uri url = Uri.parse(
                      'https://ikasmansara.com/privacy-policy',
                    ); // Dummy URL
                    if (!await launchUrl(url)) {
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Tidak dapat membuka link"),
                        ),
                      );
                    }
                  },
                ),
                _buildListTile(
                  context,
                  icon: Icons.description_outlined,
                  title: 'Syarat & Ketentuan',
                  onTap: () async {
                    final Uri url = Uri.parse(
                      'https://ikasmansara.com/terms',
                    ); // Dummy URL
                    if (!await launchUrl(url)) {
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Tidak dapat membuka link"),
                        ),
                      );
                    }
                  },
                ),
                _buildListTile(
                  context,
                  icon: Icons.info_outline,
                  title: 'Tentang Aplikasi',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AboutPage()),
                    );
                  },
                ),
                const SizedBox(height: 40),
                Center(
                  child: Text(
                    'Versi 2.0.1+32',
                    style: GoogleFonts.inter(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: titleColor == AppColors.error
              ? AppColors.error
              : AppColors.primary,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: titleColor ?? Theme.of(context).colorScheme.onSurface,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            )
          : null,
      trailing: Icon(
        Icons.chevron_right,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
      ),
      onTap: onTap,
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Akun?'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus akun secara permanen? Data yang dihapus tidak dapat dikembalikan.\n\nUntuk saat ini, silakan hubungi Admin untuk pemrosesan penghapusan data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final Uri url = Uri.parse(
                'https://wa.me/6281234567890?text=Halo%20Admin%2C%20saya%20ingin%20mengajukan%20penghapusan%20akun%20IKA%20SMANSARA',
              );
              launchUrl(url);
            },
            child: const Text(
              'Hubungi Admin',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
