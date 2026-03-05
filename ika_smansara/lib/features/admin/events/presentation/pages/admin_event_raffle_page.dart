import 'dart:async';
import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../../../core/network/pb_client.dart';
import '../../domain/entities/event_prize_entity.dart';
import '../../data/data_sources/event_doorprize_remote_data_source.dart';
import '../../data/models/event_winner_model.dart';
import '../bloc/admin_doorprize_cubit.dart';

/// Data class representing a ticket eligible for raffle
class RaffleTicket {
  final String bookingTicketId;
  final String ticketId; // Display ticket number (e.g., TIX-REUNI26-001)
  final String userName;

  const RaffleTicket({
    required this.bookingTicketId,
    required this.ticketId,
    required this.userName,
  });
}

class AdminEventRafflePage extends StatefulWidget {
  final String eventId;
  final List<EventPrizeEntity> prizes;

  const AdminEventRafflePage({
    super.key,
    required this.eventId,
    required this.prizes,
  });

  @override
  State<AdminEventRafflePage> createState() => _AdminEventRafflePageState();
}

class _AdminEventRafflePageState extends State<AdminEventRafflePage>
    with TickerProviderStateMixin {
  late final ConfettiController _confettiController;
  late final EventDoorprizeRemoteDataSource _dataSource;

  // State
  List<RaffleTicket> _eligibleTickets = [];
  List<String> _usedTicketIds = []; // booking_ticket IDs already won
  Map<String, int> _winnerCountByPrize = {}; // prizeId -> winner count
  EventPrizeEntity? _selectedPrize;
  RaffleTicket? _winner;
  bool _isLoading = true;
  bool _isRolling = false;
  bool _showWinner = false;
  String _rollingText = '---';
  Timer? _rollingTimer;
  int _rollingSpeed = 30; // ms

  // Animation controllers
  late final AnimationController _pulseController;
  late final AnimationController _glowController;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 5),
    );
    _dataSource = EventDoorprizeRemoteDataSource(PBClient.instance.pb);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Set landscape + fullscreen for projector mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _loadData();
  }

  @override
  void dispose() {
    _rollingTimer?.cancel();
    _confettiController.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final pb = PBClient.instance.pb;

      // 1. Get all paid booking tickets for this event (using expand)
      final bookingTickets = await pb
          .collection('event_booking_tickets')
          .getFullList(
            filter:
                'booking.event = "${widget.eventId}" && booking.payment_status = "paid"',
            expand: 'booking.user',
          );

      final List<RaffleTicket> tickets = [];
      for (final bt in bookingTickets) {
        String userName = 'Unknown';
        try {
          final expandedBooking = bt.get<List<RecordModel>>('expand.booking');
          if (expandedBooking.isNotEmpty) {
            final bookingData = expandedBooking.first;

            // Try to get registered user's name first
            try {
              final expandedUser = bookingData.get<List<RecordModel>>(
                'expand.user',
              );
              if (expandedUser.isNotEmpty) {
                final name = expandedUser.first.getStringValue('name');
                if (name.isNotEmpty) userName = name;
              }
            } catch (_) {}

            // Fallback: Use coordinator_name if user is null/empty
            if (userName == 'Unknown') {
              final coordinatorName = bookingData.getStringValue(
                'coordinator_name',
              );
              if (coordinatorName.isNotEmpty) {
                userName = coordinatorName;
              }
            }
          }
        } catch (_) {}

        tickets.add(
          RaffleTicket(
            bookingTicketId: bt.id,
            ticketId: bt.data['ticket_id'] as String? ?? bt.id,
            userName: userName,
          ),
        );
      }

      // 2. Get already-won ticket IDs
      final winners = await pb
          .collection('event_winners')
          .getFullList(filter: 'event = "${widget.eventId}"');
      final usedIds = winners
          .map((w) => w.data['booking_ticket'] as String? ?? '')
          .where((id) => id.isNotEmpty)
          .toList();

      final Map<String, int> winnerCount = {};
      for (final w in winners) {
        final prizeId = w.data['prize'] as String? ?? '';
        if (prizeId.isNotEmpty) {
          winnerCount[prizeId] = (winnerCount[prizeId] ?? 0) + 1;
        }
      }

      setState(() {
        _eligibleTickets = tickets;
        _usedTicketIds = usedIds;
        _winnerCountByPrize = winnerCount;
        _isLoading = false;
        // Select first prize that still has remaining quota
        final available = widget.prizes.where((p) {
          final won = winnerCount[p.id] ?? 0;
          return won < p.quantity;
        }).toList();
        _selectedPrize = available.isNotEmpty ? available.first : null;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error memuat data: $e')));
      }
    }
  }

  List<RaffleTicket> get _availableTickets => _eligibleTickets
      .where((t) => !_usedTicketIds.contains(t.bookingTicketId))
      .toList();

  List<EventPrizeEntity> get _availablePrizes => widget.prizes.where((p) {
    final won = _winnerCountByPrize[p.id] ?? 0;
    return won < p.quantity;
  }).toList();

  void _startRolling() {
    if (_availableTickets.isEmpty || _selectedPrize == null) return;

    setState(() {
      _isRolling = true;
      _showWinner = false;
      _winner = null;
      _rollingSpeed = 30;
    });

    final random = Random();

    // Determine winner upfront
    final available = _availableTickets;
    final winnerIndex = random.nextInt(available.length);
    final selectedWinner = available[winnerIndex];

    // Start rolling animation
    int elapsed = 0;
    const totalDuration = 5000; // 5 seconds

    _rollingTimer = Timer.periodic(Duration(milliseconds: _rollingSpeed), (
      timer,
    ) {
      elapsed += _rollingSpeed;

      if (elapsed >= totalDuration) {
        // Stop - show winner
        timer.cancel();
        _revealWinner(selectedWinner);
        return;
      }

      // Gradually slow down: increase speed interval every second
      if (elapsed > 3500) {
        _rollingSpeed = 200;
      } else if (elapsed > 2500) {
        _rollingSpeed = 120;
      } else if (elapsed > 1500) {
        _rollingSpeed = 80;
      }

      // Show random ticket while rolling
      final randomTicket = available[random.nextInt(available.length)];
      setState(() {
        _rollingText = randomTicket.ticketId;
      });

      // Restart timer with new speed
      if (_rollingSpeed != 30 && elapsed > 1500) {
        timer.cancel();
        _rollingTimer = Timer.periodic(Duration(milliseconds: _rollingSpeed), (
          newTimer,
        ) {
          elapsed += _rollingSpeed;
          if (elapsed >= totalDuration) {
            newTimer.cancel();
            _revealWinner(selectedWinner);
            return;
          }
          final rt = available[random.nextInt(available.length)];
          setState(() => _rollingText = rt.ticketId);
        });
      }
    });
  }

  void _revealWinner(RaffleTicket winner) async {
    setState(() {
      _isRolling = false;
      _showWinner = true;
      _winner = winner;
      _rollingText = winner.ticketId;
    });

    _confettiController.play();

    // Save winner to PocketBase
    try {
      final model = EventWinnerModel(
        id: '',
        event: widget.eventId,
        prize: _selectedPrize!.id,
        booking_ticket: winner.bookingTicketId,
      );
      await _dataSource.createWinner(model);

      setState(() {
        _usedTicketIds.add(winner.bookingTicketId);
        // Update winner count
        if (_selectedPrize != null) {
          final prizeId = _selectedPrize!.id;
          _winnerCountByPrize[prizeId] =
              (_winnerCountByPrize[prizeId] ?? 0) + 1;
          // Auto-select next available prize if current is now full
          final stillAvailable = _availablePrizes;
          if (!stillAvailable.any((p) => p.id == prizeId)) {
            _selectedPrize = stillAvailable.isNotEmpty
                ? stillAvailable.first
                : null;
          }
        }
      });

      // Also refresh the cubit if it's in the tree
      if (mounted) {
        try {
          context.read<AdminDoorprizeCubit>().loadData();
        } catch (_) {}
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error menyimpan pemenang: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: Stack(
        children: [
          // Animated background
          _buildAnimatedBackground(),

          // Main content
          SafeArea(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : Column(
                    children: [
                      _buildTopBar(),
                      Expanded(child: _buildCenterContent()),
                      _buildBottomControls(),
                    ],
                  ),
          ),

          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              numberOfParticles: 50,
              maxBlastForce: 40,
              minBlastForce: 15,
              emissionFrequency: 0.06,
              gravity: 0.15,
              colors: const [
                Colors.amber,
                Colors.pink,
                Colors.cyan,
                Colors.purple,
                Colors.green,
                Colors.orange,
                Colors.red,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.2,
              colors: [
                Color.lerp(
                  const Color(0xFF1A1A2E),
                  const Color(0xFF16213E),
                  _glowAnimation.value,
                )!,
                const Color(0xFF0A0E21),
              ],
            ),
          ),
          child: CustomPaint(
            painter: _StarsPainter(opacity: _glowAnimation.value),
            size: Size.infinite,
          ),
        );
      },
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white70),
          ),
          const Spacer(),
          Text(
            '🎁 UNDIAN DOORPRIZE',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          const Spacer(),
          // Ticket count badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.confirmation_number,
                  color: Colors.amber,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  '${_availableTickets.length} tiket tersisa',
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Prize name
          if (_selectedPrize != null) ...[
            Text('🏆', style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            Text(
              _selectedPrize!.name.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.amber,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 32),
          ],

          // Main ticket display
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _isRolling ? _pulseAnimation.value : 1.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 32,
                  ),
                  decoration: BoxDecoration(
                    gradient: _showWinner
                        ? const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                          )
                        : LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.08),
                              Colors.white.withOpacity(0.03),
                            ],
                          ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: _showWinner
                          ? Colors.amber
                          : _isRolling
                          ? Colors.cyan.withOpacity(0.5)
                          : Colors.white24,
                      width: _showWinner ? 3 : 1.5,
                    ),
                    boxShadow: _isRolling || _showWinner
                        ? [
                            BoxShadow(
                              color: _showWinner
                                  ? Colors.amber.withOpacity(0.4)
                                  : Colors.cyan.withOpacity(0.3),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    children: [
                      Text(
                        _isRolling || _showWinner ? _rollingText : '???',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: _showWinner ? 56 : 48,
                          fontWeight: FontWeight.w700,
                          color: _showWinner
                              ? const Color(0xFF1A1A2E)
                              : Colors.white,
                          letterSpacing: 4,
                        ),
                      ),
                      if (_showWinner && _winner != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A2E).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _winner!.userName,
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1A1A2E),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),

          if (_showWinner) ...[
            const SizedBox(height: 24),
            Text(
              '🎉 SELAMAT! 🎉',
              style: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Colors.amber,
                letterSpacing: 4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          // Prize selector
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedPrize?.id,
                  hint: Text(
                    'Pilih Hadiah',
                    style: GoogleFonts.inter(color: Colors.white54),
                  ),
                  dropdownColor: const Color(0xFF1A1A2E),
                  iconEnabledColor: Colors.white70,
                  isExpanded: true,
                  items: _availablePrizes.map((prize) {
                    final won = _winnerCountByPrize[prize.id] ?? 0;
                    final remaining = prize.quantity - won;
                    return DropdownMenuItem(
                      value: prize.id,
                      child: Text(
                        '${prize.name} (sisa $remaining)',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: _isRolling
                      ? null
                      : (val) {
                          setState(() {
                            _selectedPrize = _availablePrizes.firstWhere(
                              (p) => p.id == val,
                            );
                            _showWinner = false;
                            _winner = null;
                          });
                        },
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // ACAK button
          SizedBox(
            height: 56,
            child: FilledButton.icon(
              onPressed: _isRolling || _availableTickets.isEmpty
                  ? null
                  : _startRolling,
              icon: Icon(
                _isRolling ? Icons.hourglass_top : Icons.shuffle,
                size: 24,
              ),
              label: Text(
                _isRolling
                    ? 'MENGACAK...'
                    : _showWinner
                    ? 'ACAK LAGI'
                    : 'ACAK PEMENANG',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: _isRolling
                    ? Colors.grey
                    : const Color(0xFFE91E63),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============ Stars Painter ============

class _StarsPainter extends CustomPainter {
  final double opacity;
  _StarsPainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(42); // Fixed seed for stable positions
    final paint = Paint()..color = Colors.white.withOpacity(0.15 * opacity);

    for (int i = 0; i < 80; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 1.5 + 0.5;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarsPainter oldDelegate) =>
      oldDelegate.opacity != opacity;
}
