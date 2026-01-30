import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_input_formatter.dart';
import '../../domain/entities/donation.dart';
import '../bloc/donation_detail_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class DonationPaymentSheet extends StatefulWidget {
  final Donation donation;
  const DonationPaymentSheet({super.key, required this.donation});

  @override
  State<DonationPaymentSheet> createState() => _DonationPaymentSheetState();
}

class _DonationPaymentSheetState extends State<DonationPaymentSheet> {
  final _amountController = TextEditingController();
  final _nameController = TextEditingController(); // Only if not anonymous
  String? _selectedPaymentMethod;
  bool _isAnonymous = false;
  final List<double> _presetAmounts = [10000, 20000, 50000, 100000, 500000];
  final List<String> _paymentMethods = ['QRIS', 'Virtual Account'];

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _nameController.text = authState.user.name;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur pembayaran donasi akan segera hadir'),
      ),
    );
    return;

    /*
    final amountString = _amountController.text.replaceAll('.', '');
    final amount = double.tryParse(amountString) ?? 0;

    if (amount < 10000) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Minimal donasi Rp 10.000')));
      return;
    }

    if (!_isAnonymous && _nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Mohon isi nama donatur')));
      return;
    }

    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pilih metode pembayaran')));
      return;
    }

    context.read<DonationDetailBloc>().add(
      CreateTransactionEvent(
        donationId: widget.donation.id,
        amount: amount,
        donorName: _isAnonymous ? 'Hamba Allah' : _nameController.text,
        isAnonymous: _isAnonymous,
        paymentMethod: _selectedPaymentMethod,
      ),
    );
    */
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle Bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 24),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Donasi untuk ${widget.donation.title}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Amount Input
                    const Text(
                      'Nominal Donasi',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [CurrencyInputFormatter()],
                      decoration: InputDecoration(
                        prefixText: 'Rp ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        hintText: '0',
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Presets
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _presetAmounts.map((amount) {
                        final isSelected =
                            double.tryParse(
                              _amountController.text.replaceAll('.', ''),
                            ) ==
                            amount;
                        return ChoiceChip(
                          label: Text(
                            currencyFormat.format(amount).replaceAll('Rp ', ''),
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          backgroundColor: Colors.grey[200],
                          checkmarkColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.transparent,
                            ),
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _amountController.text = currencyFormat
                                    .format(amount)
                                    .replaceAll('Rp ', '')
                                    .trim();
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // Anonymous Checkbox
                    SwitchListTile(
                      title: const Text('Sembunyikan nama saya (Hamba Allah)'),
                      value: _isAnonymous,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) {
                        setState(() {
                          _isAnonymous = val;
                        });
                      },
                    ),

                    // Name Input (if not anonymous)
                    if (!_isAnonymous) ...[
                      const SizedBox(height: 12),
                      const Text(
                        'Nama Donatur',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          hintText: 'Nama lengkap Anda',
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Payment Method
                    const Text(
                      'Metode Pembayaran',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Column(
                      children: _paymentMethods.map((method) {
                        return RadioListTile<String>(
                          title: Row(
                            children: [
                              Icon(
                                method == 'QRIS'
                                    ? Icons.qr_code
                                    : Icons.credit_card,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 12),
                              Text(method),
                            ],
                          ),
                          value: method,
                          // ignore: deprecated_member_use
                          groupValue: _selectedPaymentMethod,
                          // ignore: deprecated_member_use
                          onChanged: (val) {
                            setState(() {
                              _selectedPaymentMethod = val;
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                          activeColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: _selectedPaymentMethod == method
                                  ? AppColors.primary
                                  : Colors.grey[300]!,
                            ),
                          ),
                          tileColor: _selectedPaymentMethod == method
                              ? AppColors.primary.withValues(alpha: 0.1)
                              : Colors.transparent,
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Submit Button
            Padding(
              padding: const EdgeInsets.all(24),
              child: BlocBuilder<DonationDetailBloc, DonationDetailState>(
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: state is TransactionLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: state is TransactionLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Lanjut Pembayaran'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
