import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../bloc/printer_bloc.dart';

class PrinterSettingsPage extends StatelessWidget {
  const PrinterSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<PrinterBloc>()..add(LoadPrinterSettings()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            'Konfigurasi Printer',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocConsumer<PrinterBloc, PrinterState>(
          listener: (context, state) {
            if (state is PrinterError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            // Safe access to settings
            final settings = (state is PrinterLoaded)
                ? state.settings
                : (state is PrinterScanning)
                ? state.settings
                : (state is PrinterScanResult)
                ? state.settings
                : null;

            if (state is PrinterInitial ||
                state is PrinterLoading && settings == null) {
              return const Center(child: CircularProgressIndicator());
            }

            // Default fallback if logic fails but shouldn't happens often
            if (settings == null) return const SizedBox.shrink();

            final isConnected = (state is PrinterLoaded) && state.isConnected;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSectionHeader('Preferensi Cetak'),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: Text(
                          'Cetak Otomatis',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          'Langsung cetak struk setelah transaksi',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textGrey,
                          ),
                        ),
                        value: settings.autoPrintEnabled,
                        onChanged: (value) {
                          context.read<PrinterBloc>().add(
                            UpdatePrinterConfig(
                              autoPrintEnabled: value,
                              paperSize: settings.paperSize,
                            ),
                          );
                        },
                        activeColor: AppColors.primary,
                      ),
                      const Divider(height: 1),
                      ListTile(
                        title: Text(
                          'Ukuran Kertas',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                        ),
                        trailing: DropdownButton<int>(
                          value: settings.paperSize,
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(value: 58, child: Text("58mm")),
                            DropdownMenuItem(value: 80, child: Text("80mm")),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              context.read<PrinterBloc>().add(
                                UpdatePrinterConfig(
                                  paperSize: val,
                                  autoPrintEnabled: settings.autoPrintEnabled,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildSectionHeader('Perangkat Terhubung'),
                if (settings.macAddress != null)
                  Card(
                    color: isConnected ? Colors.green.shade50 : Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isConnected
                            ? Colors.green
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: ListTile(
                      leading: Icon(
                        Icons.print,
                        color: isConnected ? Colors.green : Colors.grey,
                      ),
                      title: Text(settings.name ?? "Unknown Device"),
                      subtitle: Text(settings.macAddress!),
                      trailing: TextButton(
                        onPressed: () {
                          context.read<PrinterBloc>().add(DisconnectDevice());
                        },
                        child: const Text(
                          'Putuskan',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'Belum ada printer terhubung',
                        style: GoogleFonts.inter(color: AppColors.textGrey),
                      ),
                    ),
                  ),

                const SizedBox(height: 16),
                if (isConnected)
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<PrinterBloc>().add(TestPrint());
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Test Print dikirim...")),
                      );
                    },
                    icon: const Icon(Icons.print),
                    label: const Text('Test Print'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),

                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionHeader('Perangkat Tersedia'),
                    if (state is! PrinterScanning)
                      TextButton.icon(
                        onPressed: () {
                          context.read<PrinterBloc>().add(ScanDevices());
                        },
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Scan Ulang'),
                      ),
                  ],
                ),

                if (state is PrinterScanning)
                  const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state is PrinterScanResult)
                  ...state.devices.map(
                    (device) => Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.bluetooth),
                        title: Text(device['name'] ?? 'Unknown'),
                        subtitle: Text(device['mac'] ?? ''),
                        trailing: ElevatedButton(
                          onPressed: () {
                            context.read<PrinterBloc>().add(
                              ConnectDevice(
                                name: device['name'] ?? 'Unknown',
                                macAddress: device['mac'] ?? '',
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: const StadiumBorder(),
                          ),
                          child: const Text('Hubungkan'),
                        ),
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          color: AppColors.textGrey,
          fontSize: 14,
        ),
      ),
    );
  }
}
