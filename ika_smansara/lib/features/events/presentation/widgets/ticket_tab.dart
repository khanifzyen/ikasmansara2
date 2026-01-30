import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/event_ticket.dart';
import '../../domain/entities/event_ticket_option.dart';
import '../bloc/event_booking_bloc.dart';

class TicketTab extends StatefulWidget {
  final List<EventTicket> tickets;
  final bool enableScroll;

  const TicketTab({super.key, required this.tickets, this.enableScroll = true});

  @override
  State<TicketTab> createState() => _TicketTabState();
}

class _TicketTabState extends State<TicketTab> {
  // Map to track quantity for each ticket type
  final Map<String, int> _quantities = {};

  // Map to track selected options: ticketId -> index -> optionId -> selectedChoice
  final Map<String, Map<int, Map<String, TicketOptionChoice>>>
  _selectedOptions = {};

  String _selectedPaymentMethod = 'other_qris'; // Default payment method

  @override
  void initState() {
    super.initState();
    for (var ticket in widget.tickets) {
      _quantities[ticket.id] = 0;
    }
    // Default select 1 for the first available ticket
    if (widget.tickets.isNotEmpty) {
      _updateQuantity(widget.tickets.first.id, 1);
    }
  }

  void _updateQuantity(String ticketId, int change) {
    setState(() {
      final current = _quantities[ticketId] ?? 0;
      final newQuantity = current + change;

      if (newQuantity >= 0) {
        _quantities[ticketId] = newQuantity;

        // Initialize or remove options storage for the new quantity
        if (change > 0) {
          _selectedOptions.putIfAbsent(ticketId, () => {});
          // Initialize options for the new item index
          // Default choices could be set here if needed
        } else if (change < 0 && _selectedOptions.containsKey(ticketId)) {
          // Remove options for the removed item index
          _selectedOptions[ticketId]?.remove(newQuantity);
        }

        // Ensure default options are selected for new items
        if (change > 0) {
          final ticket = widget.tickets.firstWhere((t) => t.id == ticketId);
          for (int i = current; i < newQuantity; i++) {
            _selectedOptions[ticketId]![i] = {};
            for (var option in ticket.options) {
              if (option.choices.isNotEmpty) {
                _selectedOptions[ticketId]![i]![option.id] =
                    option.choices.first;
              }
            }
          }
        }
      }
    });
  }

  void _updateOption(
    String ticketId,
    int itemIndex,
    String optionId,
    TicketOptionChoice choice,
  ) {
    setState(() {
      if (!_selectedOptions.containsKey(ticketId)) {
        _selectedOptions[ticketId] = {};
      }
      if (!_selectedOptions[ticketId]!.containsKey(itemIndex)) {
        _selectedOptions[ticketId]![itemIndex] = {};
      }
      _selectedOptions[ticketId]![itemIndex]![optionId] = choice;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tickets.isEmpty) {
      return const Center(child: Text('Belum ada tiket tersedia'));
    }

    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pesan Tiket Baru',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),

        // ... (rest of the children will be preserved by replace_file_content matching)
        const SizedBox(height: 16),
        ...widget.tickets.map((ticket) {
          final quantity = _quantities[ticket.id] ?? 0;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ticket.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                ticket.description,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 2),
                              if (ticket.includes.isNotEmpty)
                                Text(
                                  'Include: ${ticket.includes.join(", ")}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              Text(
                                NumberFormat.currency(
                                  locale: 'id_ID',
                                  symbol: 'Rp ',
                                  decimalDigits: 0,
                                ).format(ticket.price),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF006D4E),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            InkWell(
                              onTap: () => _updateQuantity(ticket.id, -1),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.white,
                                ),
                                child: const Icon(Icons.remove, size: 16),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '$quantity',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 12),
                            InkWell(
                              onTap: () => _updateQuantity(ticket.id, 1),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.white,
                                ),
                                child: const Icon(Icons.add, size: 16),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Render options for each quantity unit
                    if (quantity > 0 && ticket.options.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(quantity, (index) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[200]!),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Detail Tiket #${index + 1}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...ticket.options.map((option) {
                                    final selectedChoice =
                                        _selectedOptions[ticket
                                            .id]?[index]?[option.id];
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            option.name,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          DropdownButtonFormField<
                                            TicketOptionChoice
                                          >(
                                            initialValue:
                                                option.choices.contains(
                                                  selectedChoice,
                                                )
                                                ? selectedChoice
                                                : (option.choices.isNotEmpty
                                                      ? option.choices.first
                                                      : null),
                                            isDense: true,
                                            decoration: InputDecoration(
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: BorderSide(
                                                  color: Colors.grey[300]!,
                                                ),
                                              ),
                                            ),
                                            items: option.choices.map((choice) {
                                              final label =
                                                  choice.extraPrice > 0
                                                  ? '${choice.label} (+${choice.extraPrice ~/ 1000}rb)'
                                                  : choice.label;
                                              return DropdownMenuItem(
                                                value: choice,
                                                child: Text(
                                                  label,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                            onChanged: (value) {
                                              if (value != null) {
                                                _updateOption(
                                                  ticket.id,
                                                  index,
                                                  option.id,
                                                  value,
                                                );
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            );
                          }),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        }),

        // Payment Method Section
        const Text(
          'Metode Pembayaran',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: RadioGroup<String>(
            groupValue: _selectedPaymentMethod,
            onChanged: (val) {
              setState(() {
                _selectedPaymentMethod = val!;
              });
            },
            child: Column(
              children: [
                RadioListTile<String>(
                  value: 'other_qris',
                  title: Row(
                    children: [
                      const Icon(Icons.qr_code, color: Colors.black),
                      const SizedBox(width: 12),
                      const Text('QRIS'),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Instant',
                          style: TextStyle(fontSize: 10, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // RadioListTile<String>(
                //   value: 'bni_va',
                //   title: Row(
                //     children: [
                //       // You might want to use an asset image for BNI logo if available,
                //       // otherwise use a generic bank icon or text.
                //       // Assuming no assets, using Icon and Text.
                //       const Icon(Icons.account_balance, color: Colors.black),
                //       const SizedBox(width: 12),
                //       const Text('BNI Virtual Account'),
                //       const Spacer(),
                //     ],
                //   ),
                // ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF006D4E).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Harga Tiket',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  Text(
                    NumberFormat.currency(
                      locale: 'id_ID',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(_calculateTicketTotal()),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Biaya Layanan',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  Text(
                    NumberFormat.currency(
                      locale: 'id_ID',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(_calculateServiceFee()),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Pembayaran',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    NumberFormat.currency(
                      locale: 'id_ID',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(_calculateGrandTotal()),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF006D4E),
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: BlocBuilder<EventBookingBloc, EventBookingState>(
            builder: (context, state) {
              final isLoading = state is EventBookingLoading;

              return ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        final total = _calculateGrandTotal();
                        if (_calculateTicketTotal() == 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pilih minimal 1 tiket'),
                            ),
                          );
                          return;
                        }

                        // Build Metadata
                        final List<Map<String, dynamic>> metadata = [];
                        for (var ticket in widget.tickets) {
                          final quantity = _quantities[ticket.id] ?? 0;
                          if (quantity > 0) {
                            // For each item of this ticket type
                            for (int i = 0; i < quantity; i++) {
                              final options = <String, String>{};
                              if (_selectedOptions.containsKey(ticket.id) &&
                                  _selectedOptions[ticket.id]!.containsKey(i)) {
                                _selectedOptions[ticket.id]![i]!.forEach((
                                  key,
                                  choice,
                                ) {
                                  // We use the option ID as key, and choice label as value
                                  options[key] = choice.label;
                                });
                              }

                              metadata.add({
                                'ticket_type_id': ticket.id,
                                'quantity':
                                    1, // We break down per item for easier handling
                                'options': options,
                              });
                            }
                          }
                        }

                        // Determine Event ID
                        final eventId = widget.tickets.first.eventId;

                        // Dispatch
                        context.read<EventBookingBloc>().add(
                          CreateBooking(
                            eventId: eventId,
                            metadata: metadata,
                            totalPrice: total,
                            paymentMethod: _selectedPaymentMethod,
                          ),
                        );
                      },
                child: isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.grey,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Memproses...'),
                        ],
                      )
                    : const Text('Beli Tiket Sekarang'),
              );
            },
          ),
        ),
        const SizedBox(height: 32),
      ],
    );

    if (widget.enableScroll) {
      return SingleChildScrollView(child: content);
    }

    return content;
  }

  int _calculateTicketTotal() {
    int total = 0;
    for (var ticket in widget.tickets) {
      final quantity = _quantities[ticket.id] ?? 0;
      total += (ticket.price * quantity).toInt();

      // Add extra prices from options
      if (_selectedOptions.containsKey(ticket.id)) {
        _selectedOptions[ticket.id]!.forEach((index, optionsMap) {
          if (index < quantity) {
            optionsMap.forEach((optionId, choice) {
              total += choice.extraPrice.toInt();
            });
          }
        });
      }
    }
    return total;
  }

  int _calculateServiceFee() {
    // 1.5% service fee
    return (_calculateTicketTotal() * 0.015).ceil();
  }

  int _calculateGrandTotal() {
    return _calculateTicketTotal() + _calculateServiceFee();
  }
}
