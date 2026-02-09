import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../bloc/my_donation_bloc.dart';

class MyDonationsPage extends StatelessWidget {
  const MyDonationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<MyDonationBloc>()..add(FetchMyDonations()),
      child: Scaffold(
        
        appBar: AppBar(
          title: const Text('Riwayat Donasi'),
          
          elevation: 0,
        ),
        body: BlocBuilder<MyDonationBloc, MyDonationState>(
          builder: (context, state) {
            if (state is MyDonationLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is MyDonationError) {
              return Center(child: Text('Error: ${state.message}'));
            } else if (state is MyDonationLoaded) {
              if (state.transactions.isEmpty) {
                return const Center(child: Text('Belum ada riwayat donasi.'));
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.transactions.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final trx = state.transactions[index];
                  final currencyFormat = NumberFormat.currency(
                    locale: 'id_ID',
                    symbol: 'Rp ',
                    decimalDigits: 0,
                  );

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: trx.isSuccess
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.orange.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        trx.isSuccess ? Icons.check : Icons.access_time,
                        color: trx.isSuccess ? Colors.green : Colors.orange,
                      ),
                    ),
                    title: Text(
                      trx.donationId != null
                          ? 'Donasi Program'
                          : 'Donasi Event', // Or fetch actual title if expanded
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      DateFormat('dd MMM yyyy, HH:mm').format(trx.created),
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          currencyFormat.format(trx.amount),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          trx.paymentStatus.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            color: trx.isSuccess ? Colors.green : Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
