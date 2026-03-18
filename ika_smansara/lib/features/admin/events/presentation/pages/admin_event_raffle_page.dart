import 'dart:async';
import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:pocketbase/pocketbase.dart';

import '../../../../../core/network/pb_client.dart';
import '../../data/data_sources/event_doorprize_remote_data_source.dart';
import '../../data/models/event_winner_model.dart';
import '../bloc/admin_doorprize_cubit.dart';

class RaffleTicket {
  final String bookingTicketId;
  final String ticketId;
  final String userName;

  const RaffleTicket({
    required this.bookingTicketId,
    required this.ticketId,
    required this.userName,
  });
}

class AdminEventRafflePage extends StatefulWidget {
  final String eventId;

  const AdminEventRafflePage({super.key, required this.eventId});

  @override
  State<AdminEventRafflePage> createState() => _AdminEventRafflePageState();
}

class _AdminEventRafflePageState extends State<AdminEventRafflePage>
    with TickerProviderStateMixin {
  late final ConfettiController _confettiController;
  late final EventDoorprizeRemoteDataSource _dataSource;

  // Settings state
  final _prizeNameController = TextEditingController();
  final _durationController = TextEditingController(text: '5');
  int _winnerCount = 1;

  // Data state
  List<RaffleTicket> _eligibleTickets = [];
  List<String> _usedTicketIds = [];
  bool _isLoading = true;

  // Rolling state
  bool _isRolling = false;
  bool _showWinners = false;
  List<RaffleTicket?> _currentWinners = [];
  List<String> _rollingTexts = [];
  Timer? _rollingTimer;

  // Error/Save state for winners
  final Map<String, bool> _savedWinnerStatus =
      {}; // ticketId -> true if successfully saved
  final Map<String, bool> _disqualifiedStatus =
      {}; // ticketId -> true if disqualified in the UI session

  // Animation controller
  late final AnimationController _glowController;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 5),
    );
    _dataSource = EventDoorprizeRemoteDataSource(PBClient.instance.pb);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _loadData();
  }

  @override
  void dispose() {
    _rollingTimer?.cancel();
    _confettiController.dispose();
    _glowController.dispose();
    _prizeNameController.dispose();
    _durationController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final pb = PBClient.instance.pb;

      // 1. Get all paid booking tickets
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

            try {
              final expandedUser = bookingData.get<List<RecordModel>>(
                'expand.user',
              );
              if (expandedUser.isNotEmpty) {
                final name = expandedUser.first.getStringValue('name');
                if (name.isNotEmpty) userName = name;
              }
            } catch (_) {}

            if (userName == 'Unknown' || userName.isEmpty) {
              final coordinatorName = bookingData.getStringValue(
                'coordinator_name',
              );
              if (coordinatorName.isNotEmpty) {
                userName = '(Koor) $coordinatorName';
              }
            }
          }
        } catch (e) {
          debugPrint('Error parsing expand fields: $e');
        }

        tickets.add(
          RaffleTicket(
            bookingTicketId: bt.id,
            ticketId: bt.data['ticket_id'] as String? ?? bt.id,
            userName: userName,
          ),
        );
      }

      // 2. Get used ticket IDs (all winners, including disqualified, won't be drawn again)
      final winners = await pb
          .collection('event_winners')
          .getFullList(filter: 'event = "${widget.eventId}"');
      final usedIds = winners
          .map((w) => w.data['booking_ticket'] as String? ?? '')
          .where((id) => id.isNotEmpty)
          .toList();

      setState(() {
        _eligibleTickets = tickets;
        _usedTicketIds = usedIds;
        _isLoading = false;
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

  void _startRolling() {
    final prizeName = _prizeNameController.text.trim();
    if (prizeName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap masukkan nama hadiah!')),
      );
      return;
    }

    final int rollDuration = int.tryParse(_durationController.text) ?? 5;
    if (rollDuration <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Durasi harus lebih dari 0 detik.')),
      );
      return;
    }

    final available = _availableTickets;
    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada tiket yang tersisa untuk diundi.'),
        ),
      );
      return;
    }

    // Prepare state
    int actualWinnerCount = min(_winnerCount, available.length);
    setState(() {
      _isRolling = true;
      _showWinners = false;
      _currentWinners = List.filled(actualWinnerCount, null);
      _rollingTexts = List.filled(actualWinnerCount, '---');
      _savedWinnerStatus.clear();
      _disqualifiedStatus.clear();
    });

    final random = Random();
    List<RaffleTicket> availableCopy = List.from(available);
    availableCopy.shuffle(random);
    List<RaffleTicket> selectedWinners = availableCopy
        .take(actualWinnerCount)
        .toList();

    int totalDurationMs = rollDuration * 1000;
    int elapsedMs = 0;
    int rollSpeed = 50;

    _rollingTimer = Timer.periodic(Duration(milliseconds: rollSpeed), (timer) {
      elapsedMs += rollSpeed;

      if (elapsedMs >= totalDurationMs) {
        timer.cancel();
        _revealWinners(selectedWinners, prizeName);
        return;
      }

      // Roll text update
      setState(() {
        for (int i = 0; i < actualWinnerCount; i++) {
          final randomTicket = available[random.nextInt(available.length)];
          _rollingTexts[i] = randomTicket.ticketId;
        }
      });
    });
  }

  void _revealWinners(List<RaffleTicket> winners, String prizeName) async {
    setState(() {
      _isRolling = false;
      _showWinners = true;
      _currentWinners = winners;
      for (int i = 0; i < winners.length; i++) {
        _rollingTexts[i] = winners[i].ticketId;
      }
    });

    _confettiController.play();

    // Save winners asynchronously to database
    for (int i = 0; i < winners.length; i++) {
      final w = winners[i];
      try {
        final model = EventWinnerModel(
          id: '',
          event: widget.eventId,
          prizeName: prizeName,
          bookingTicketId: w.bookingTicketId,
          status: 'won', // default won
        );

        await _dataSource.createWinner(model);

        if (mounted) {
          setState(() {
            _savedWinnerStatus[w.bookingTicketId] = true;
            _usedTicketIds.add(w.bookingTicketId); // Local cache update

            // Map the saved PocketBase ID so we can disqualify it if needed
            // Since we don't store the full object in state, we might need a workaround.
            // Actually, we'll just fetch again or rely on the cubit to refresh lists.
            // For simple disqualify logic, we can also use filter query by bookingTicketId.
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error menyimpan pemenang ${w.userName}: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    // Refresh the tab cubit implicitly in the background to update the overall list
    if (mounted) {
      try {
        context.read<AdminDoorprizeCubit>().loadData();
      } catch (_) {}
    }
  }

  Future<void> _disqualifyCurrentWinnerItem(RaffleTicket ticket) async {
    // To disqualify, we need the event_winner record ID.
    // We'll search for it via API and update its status.
    try {
      final pb = PBClient.instance.pb;
      final record = await pb
          .collection('event_winners')
          .getFirstListItem(
            'event = "${widget.eventId}" && booking_ticket = "${ticket.bookingTicketId}"',
          );
      await pb
          .collection('event_winners')
          .update(record.id, body: {'status': 'disqualified'});

      if (mounted) {
        setState(() {
          _disqualifiedStatus[ticket.bookingTicketId] = true;
        });
        context.read<AdminDoorprizeCubit>().loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mendiskualifikasi: $e'),
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
          _buildAnimatedBackground(),
          SafeArea(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : Column(
                    children: [
                      _buildTopBar(),
                      if (!_isRolling && !_showWinners) _buildSettingsBar(),
                      Expanded(child: _buildRaffleGrid()),
                      if (!_isRolling) _buildBottomControls(),
                    ],
                  ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              numberOfParticles: 80,
              maxBlastForce: 50,
              gravity: 0.15,
              colors: const [
                Colors.amber,
                Colors.pink,
                Colors.cyan,
                Colors.purple,
                Colors.green,
              ],
            ),
          ),
        ],
      ),
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

  Widget _buildSettingsBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // Prize Name Input
          SizedBox(
            width: 250,
            child: TextField(
              controller: _prizeNameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Nama Hadiah',
                labelStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          // Winner Count Dropdown
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Peserta/Pemenang',
                style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _winnerCount,
                    dropdownColor: const Color(0xFF1A1A2E),
                    style: GoogleFonts.inter(color: Colors.white),
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white70,
                    ),
                    items: List.generate(10, (index) {
                      return DropdownMenuItem(
                        value: index + 1,
                        child: Text('${index + 1} Orang'),
                      );
                    }),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _winnerCount = val);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          // Duration Input
          SizedBox(
            width: 120,
            child: TextField(
              controller: _durationController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Durasi (detik)',
                labelStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.black26,
                suffixText: 's',
                suffixStyle: const TextStyle(color: Colors.white54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int get _calculatedColumns {
    final count = _currentWinners.isNotEmpty
        ? _currentWinners.length
        : _winnerCount;
    if (count == 1) return 1;
    if (count <= 3) return count;
    if (count == 4) return 2;
    if (count <= 6) return 3;
    if (count <= 8) return 4;
    return 5;
  }

  Widget _buildRaffleGrid() {
    final actualCount = _isRolling || _showWinners
        ? _rollingTexts.length
        : _winnerCount;
    final cols = _calculatedColumns;

    // We want the grid objects to scale beautifully depending on how much space we have.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final spacing = 16.0;
          final runSpacing = 16.0;

          // Compute max width per cell
          final rows = (actualCount / cols).ceil();
          final cellWidth =
              (constraints.maxWidth - (spacing * (cols - 1))) / cols;
          // Compute max height per cell if we want to fill the height symmetrically
          final cellHeight =
              (constraints.maxHeight - (runSpacing * (rows - 1))) / rows;

          // Limit cell height to not stretch too thinly if few rows
          final finalCellHeight = actualCount == 1
              ? cellHeight * 0.8
              : min(cellHeight, 300.0);

          return Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: spacing,
              runSpacing: runSpacing,
              children: List.generate(actualCount, (index) {
                final isWinnerShowed =
                    _showWinners && _currentWinners[index] != null;
                final ticketText = _isRolling || _showWinners
                    ? _rollingTexts[index]
                    : '---';
                RaffleTicket? wonTicket = isWinnerShowed
                    ? _currentWinners[index]
                    : null;

                return _buildTicketBox(
                  context: context,
                  width: cellWidth,
                  height: finalCellHeight,
                  ticketCode: ticketText,
                  ticketData: wonTicket,
                  isRolling: _isRolling,
                  isWinner: isWinnerShowed,
                );
              }),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTicketBox({
    required BuildContext context,
    required double width,
    required double height,
    required String ticketCode,
    RaffleTicket? ticketData,
    required bool isRolling,
    required bool isWinner,
  }) {
    final bool isDisqualified =
        ticketData != null &&
        (_disqualifiedStatus[ticketData.bookingTicketId] ?? false);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: width,
      height: height,
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.05,
        vertical: height * 0.05,
      ),
      decoration: BoxDecoration(
        gradient: isWinner
            ? (isDisqualified
                  ? LinearGradient(
                      colors: [Colors.grey.shade800, Colors.grey.shade900],
                    )
                  : const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                    ))
            : LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.08),
                  Colors.white.withOpacity(0.03),
                ],
              ),
        borderRadius: BorderRadius.circular(height * 0.05),
        border: Border.all(
          color: isWinner
              ? (isDisqualified ? Colors.grey : Colors.amber)
              : (isRolling ? Colors.cyan.withOpacity(0.5) : Colors.white24),
          width: isWinner ? 3 : 1.5,
        ),
        boxShadow: (isRolling || isWinner) && !isDisqualified
            ? [
                BoxShadow(
                  color: isWinner
                      ? Colors.amber.withOpacity(0.4)
                      : Colors.cyan.withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          // Main Content centered
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  ticketCode,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: width * 0.08, // Dynamic sizing
                    fontWeight: FontWeight.w700,
                    color: isWinner
                        ? (isDisqualified
                              ? Colors.grey.shade400
                              : const Color(0xFF1A1A2E))
                        : Colors.white,
                    letterSpacing: 2,
                    decoration: isDisqualified
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (isWinner && ticketData != null) ...[
                  SizedBox(height: height * 0.05),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isDisqualified
                          ? Colors.grey.withOpacity(0.2)
                          : const Color(0xFF1A1A2E).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      ticketData.userName,
                      style: GoogleFonts.inter(
                        fontSize: width * 0.05,
                        fontWeight: FontWeight.w600,
                        color: isDisqualified
                            ? Colors.grey.shade500
                            : const Color(0xFF1A1A2E),
                        decoration: isDisqualified
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Corner icons / actions
          if (isWinner && ticketData != null && !isDisqualified)
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(
                  Icons.cancel,
                  color: Colors.redAccent,
                  size: 28,
                ),
                tooltip: 'Diskualifikasi',
                onPressed: () => _disqualifyCurrentWinnerItem(ticketData),
              ),
            ),

          if (isWinner && ticketData != null && isDisqualified)
            Positioned(
              top: 0,
              right: 0,
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.gavel, color: Colors.grey, size: 28),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24, top: 8),
      child: SizedBox(
        height: 80,
        width: double.infinity,
        child: Row(
          children: [
            if (_showWinners) ...[
              Expanded(
                child: SizedBox(
                  width: double.infinity,
                  height: 80,
                  child: FilledButton.icon(
                    onPressed: () {
                      setState(() {
                        _showWinners = false;
                        _isRolling = false;
                        _currentWinners = [];
                        _rollingTexts = [];
                        _prizeNameController.clear();
                      });
                    },
                    icon: const Icon(Icons.add_box, size: 28),
                    label: Text(
                      'UNDIAN BARU',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white24,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              flex: 2,
              child: SizedBox(
                width: double.infinity,
                height: 80,
                child: FilledButton.icon(
                  onPressed: _availableTickets.isEmpty ? null : _startRolling,
                  icon: Icon(
                    _showWinners ? Icons.refresh : Icons.play_arrow,
                    size: 28,
                  ),
                  label: Text(
                    _showWinners ? 'ACAK LAGI' : 'MULAI PENGACAKAN',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: _showWinners ? 1 : 2,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFE91E63),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
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
}

class _StarsPainter extends CustomPainter {
  final double opacity;
  _StarsPainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    autoPaintStars(canvas, size, opacity);
  }

  @override
  bool shouldRepaint(covariant _StarsPainter oldDelegate) =>
      oldDelegate.opacity != opacity;
}

void autoPaintStars(Canvas canvas, Size size, double opacity) {
  final random = Random(42);
  final paint = Paint()..color = Colors.white.withOpacity(0.15 * opacity);

  for (int i = 0; i < 80; i++) {
    final x = random.nextDouble() * size.width;
    final y = random.nextDouble() * size.height;
    final radius = random.nextDouble() * 1.5 + 0.5;
    canvas.drawCircle(Offset(x, y), radius, paint);
  }
}
