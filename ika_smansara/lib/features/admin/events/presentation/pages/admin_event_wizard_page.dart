import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:ika_smansara/core/constants/app_colors.dart';
import 'package:ika_smansara/features/admin/events/presentation/widgets/wizard_step_indicator.dart';
import 'package:ika_smansara/features/admin/events/presentation/bloc/admin_events_bloc.dart';

class AdminEventWizardPage extends StatefulWidget {
  const AdminEventWizardPage({super.key});

  @override
  State<AdminEventWizardPage> createState() => _AdminEventWizardPageState();
}

class _AdminEventWizardPageState extends State<AdminEventWizardPage> {
  int _currentStep = 1;
  final int _totalSteps = 5;
  final PageController _pageController = PageController();

  // Form Controllers - Step 1: Configuration
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _bookingFormatController = TextEditingController(
    text: '{CODE}-{YEAR}-{SEQ}',
  );
  final TextEditingController _ticketFormatController = TextEditingController(
    text: 'TIX-{CODE}-{SEQ}',
  );

  // Form Controllers - Step 2: Basic Info
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  File? _bannerFile;
  final ImagePicker _picker = ImagePicker();

  // Form Controllers - Step 3: Ticketing
  // Using a simple list of maps for local state before submission
  List<Map<String, dynamic>> _ticketTypes = [];

  // Form Controllers - Step 4: Features
  bool _enableSponsorship = false;
  bool _enableDonation = false;
  final TextEditingController _donationTargetController =
      TextEditingController();
  final TextEditingController _donationDescriptionController =
      TextEditingController();

  // Preview variables
  String _bookingPreview = '...';
  String _ticketPreview = '...';

  @override
  void initState() {
    super.initState();
    _codeController.addListener(_updatePreviews);
    _bookingFormatController.addListener(_updatePreviews);
    _ticketFormatController.addListener(_updatePreviews);
    _updatePreviews();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _bookingFormatController.dispose();
    _ticketFormatController.dispose();
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _donationTargetController.dispose();
    _donationDescriptionController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _submitEvent(BuildContext context) {
    if (_titleController.text.isEmpty ||
        _codeController.text.isEmpty ||
        _locationController.text.isEmpty ||
        _selectedDate == null ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Judul, Kode, Lokasi, Tanggal & Waktu wajib diisi'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final eventData = {
      'title': _titleController.text,
      'code': _codeController.text.toUpperCase(),
      'date':
          DateFormat('yyyy-MM-dd').format(_selectedDate!) + ' 00:00:00.000Z',
      'time': _selectedTime!.format(context),
      'location': _locationController.text,
      'description': _descriptionController.text,
      'status': 'active',
      'enable_sponsorship': _enableSponsorship,
      'enable_donation': _enableDonation,
      'booking_id_format': _bookingFormatController.text,
      'ticket_id_format': _ticketFormatController.text,
    };

    if (_enableDonation) {
      eventData['donation_description'] = _donationDescriptionController.text;
      if (_donationTargetController.text.isNotEmpty) {
        eventData['donation_target'] =
            double.tryParse(_donationTargetController.text) ?? 0;
      }
    }

    context.read<AdminEventsBloc>().add(
      CreateEvent(
        eventData: eventData,
        bannerFile: _bannerFile,
        tickets: _ticketTypes,
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (pickedFile != null) {
        final File compressedFile = await _compressImage(File(pickedFile.path));
        setState(() {
          _bannerFile = compressedFile;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<File> _compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath = p.join(
      dir.path,
      'compressed_wizard_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      minWidth: 1024,
      minHeight: 1024,
      quality: 85,
    );

    if (result == null) {
      return file;
    }

    return File(result.path);
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _addTicketType() {
    setState(() {
      _ticketTypes.add({
        'name': '',
        'price': 0,
        'quota': 100,
        'description': '',
      });
    });
  }

  void _removeTicketType(int index) {
    setState(() {
      _ticketTypes.removeAt(index);
    });
  }

  void _updateTicketType(int index, String field, dynamic value) {
    setState(() {
      _ticketTypes[index][field] = value;
    });
  }

  void _updatePreviews() {
    final code = _codeController.text.toUpperCase();
    final year = DateTime.now().year.toString();
    const seq = '001';

    setState(() {
      _bookingPreview = _bookingFormatController.text
          .replaceAll('{CODE}', code.isEmpty ? 'CODE' : code)
          .replaceAll('{YEAR}', year)
          .replaceAll('{SEQ}', seq);

      _ticketPreview = _ticketFormatController.text
          .replaceAll('{CODE}', code.isEmpty ? 'CODE' : code)
          .replaceAll('{SEQ}', seq)
          .replaceAll('{RAND}', 'X7Z');
    });
  }

  void _nextStep() {
    if (_currentStep < _totalSteps) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep++);
    }
  }

  void _prevStep() {
    if (_currentStep > 1) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep--);
    }
  }

  void _insertTag(TextEditingController controller, String tag) {
    final text = controller.text;
    final selection = controller.selection;
    final newText = text.replaceRange(selection.start, selection.end, tag);
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: selection.start + tag.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdminEventsBloc(),
      child: BlocConsumer<AdminEventsBloc, AdminEventsState>(
        listener: (context, state) {
          if (state is AdminEventsActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Event berhasil dibuat! 🚀'),
                backgroundColor: AppColors.success,
              ),
            );
            context.pop(true);
          } else if (state is AdminEventsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            appBar: AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Buat Event Baru',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    'Admin Panel / Events / Create Wizard',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: Stack(
              children: [
                Column(
                  children: [
                    WizardStepIndicator(
                      currentStep: _currentStep,
                      totalSteps: _totalSteps,
                      stepLabels: const [
                        'Konfigurasi',
                        'Info Dasar',
                        'Tiket',
                        'Fitur',
                        'Review',
                      ],
                    ),
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildStep1Configuration(),
                          _buildStep2BasicInfo(),
                          _buildStep3Ticketing(),
                          _buildStep4Features(),
                          _buildStep5Review(),
                        ],
                      ),
                    ),
                    _buildFooter(context, state is AdminEventsLoading),
                  ],
                ),
                if (state is AdminEventsLoading)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStep1Configuration() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            '🛠️ Konfigurasi ID',
            'Tentukan format penomoran untuk invoice dan tiket agar sistematis.',
          ),
          const SizedBox(height: 24),
          _buildTextField(
            label: 'Kode Event (Prefix)',
            controller: _codeController,
            hint: 'Contoh: REUNI26',
            helperText: 'Akan digunakan sebagai prefix global.',
            isUpperCase: true,
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;
              final kids = [
                _buildBookingFormatSection(),
                SizedBox(width: 24, height: 24),
                _buildTicketFormatSection(),
              ];

              if (isMobile) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: kids,
                );
              } else {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: kids[0]),
                    const SizedBox(width: 24),
                    Expanded(child: kids[2]),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBookingFormatSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          label: 'Format Booking ID',
          controller: _bookingFormatController,
        ),
        const SizedBox(height: 8),
        _buildTagsRow(_bookingFormatController, ['{CODE}', '{YEAR}', '{SEQ}']),
        const SizedBox(height: 12),
        _buildPreviewBox(_bookingPreview),
      ],
    );
  }

  Widget _buildTicketFormatSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          label: 'Format Ticket ID',
          controller: _ticketFormatController,
        ),
        const SizedBox(height: 8),
        _buildTagsRow(_ticketFormatController, ['{CODE}', '{SEQ}', '{RAND}']),
        const SizedBox(height: 12),
        _buildPreviewBox(_ticketPreview),
      ],
    );
  }

  Widget _buildStep2BasicInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            '📝 Informasi Dasar',
            'Lengkapi detail utama mengenai event yang akan diselenggarakan.',
          ),
          _buildTextField(
            label: 'Judul Event',
            controller: _titleController,
            hint: 'Contoh: Jalan Sehat & Reuni Akbar 2026',
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tanggal Mulai',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _selectDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 18,
                              color: AppColors.textGrey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _selectedDate == null
                                  ? 'Pilih Tanggal'
                                  : DateFormat(
                                      'dd MMM yyyy',
                                    ).format(_selectedDate!),
                              style: GoogleFonts.plusJakartaSans(
                                color: _selectedDate == null
                                    ? AppColors.textGrey
                                    : AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Waktu',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _selectTime,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 18,
                              color: AppColors.textGrey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _selectedTime == null
                                  ? 'Pilih Waktu'
                                  : _selectedTime!.format(context),
                              style: GoogleFonts.plusJakartaSans(
                                color: _selectedTime == null
                                    ? AppColors.textGrey
                                    : AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildTextField(
            label: 'Lokasi',
            controller: _locationController,
            hint: 'Nama Tempat / Alamat Lengkap',
          ),
          const SizedBox(height: 24),
          _buildTextField(
            label: 'Deskripsi Event',
            controller: _descriptionController,
            hint: 'Jelaskan detail acara menarik Anda di sini...',
            maxLines: 5,
          ),
          const SizedBox(height: 24),
          Text(
            'Banner Event',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.border,
                  style: BorderStyle.none,
                ),
                image: _bannerFile != null
                    ? DecorationImage(
                        image: FileImage(_bannerFile!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _bannerFile == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.image_outlined,
                          size: 48,
                          color: AppColors.textGrey,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Upload Banner Utama',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          'Rekomendasi: 1200x600px (Max 5MB)',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    )
                  : Stack(
                      children: [
                        Positioned(
                          right: 8,
                          top: 8,
                          child: IconButton(
                            icon: const CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.edit,
                                color: AppColors.textDark,
                                size: 20,
                              ),
                            ),
                            onPressed: _pickImage,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3Ticketing() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            '🎟️ Tiket & Peserta',
            'Atur jenis tiket, harga, kuota, dan fasilitas yang didapatkan peserta.',
          ),
          if (_ticketTypes.isEmpty)
            Container(
              padding: const EdgeInsets.all(40),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  const Text('🎫', style: TextStyle(fontSize: 32)),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada jenis tiket yang dibuat.',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.textGrey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _addTicketType,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('+ Buat Tiket Pertama'),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _ticketTypes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final ticket = _ticketTypes[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tiket #${index + 1}',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeTicketType(index),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: ticket['name'],
                        decoration: const InputDecoration(
                          labelText: 'Nama Tiket',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (val) =>
                            _updateTicketType(index, 'name', val),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: ticket['price'].toString(),
                              decoration: const InputDecoration(
                                labelText: 'Harga (Rp)',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (val) => _updateTicketType(
                                index,
                                'price',
                                int.tryParse(val) ?? 0,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              initialValue: ticket['quota'].toString(),
                              decoration: const InputDecoration(
                                labelText: 'Kuota',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (val) => _updateTicketType(
                                index,
                                'quota',
                                int.tryParse(val) ?? 0,
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
          if (_ticketTypes.isNotEmpty) ...[
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _addTicketType,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('+ Tambah Jenis Tiket Baru'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStep4Features() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            '⚡ Fitur Tambahan',
            'Aktifkan fitur pendukung untuk memeriahkan event ini.',
          ),
          SwitchListTile(
            title: Text(
              'Sponsorship',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text(
              'Buka kesempatan bagi sponsor untuk mendukung acara.',
            ),
            value: _enableSponsorship,
            onChanged: (val) => setState(() => _enableSponsorship = val),
            activeThumbColor: AppColors.primary,
          ),
          const Divider(),
          SwitchListTile(
            title: Text(
              'Open Donasi',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text(
              'Fitur penggalangan dana sukarela yang terintegrasi.',
            ),
            value: _enableDonation,
            onChanged: (val) => setState(() => _enableDonation = val),
            activeThumbColor: AppColors.primary,
          ),
          if (_enableDonation)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _buildTextField(
                    label: 'Deskripsi Donasi',
                    controller: _donationDescriptionController,
                    hint: 'Tujuan donasi...',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Target Donasi (Opsional)',
                    controller: _donationTargetController,
                    hint: 'Rp',
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStep5Review() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text('🚀', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            'Siap untuk Publish?',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          Text(
            'Pastikan semua data di bawah sudah sesuai sebelum event diluncurkan.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(color: AppColors.textGrey),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(12),
                        image: _bannerFile != null
                            ? DecorationImage(
                                image: FileImage(_bannerFile!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _titleController.text.isEmpty
                                ? 'Judul Event'
                                : _titleController.text,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${_selectedDate != null ? DateFormat('dd MMM yyyy').format(_selectedDate!) : '-'} • ${_selectedTime?.format(context) ?? '-'}',
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.textGrey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 24),
                _buildReviewItem('Kode Event', _codeController.text),
                _buildReviewItem('Lokasi', _locationController.text),
                _buildReviewItem('Tiket', '${_ticketTypes.length} Jenis Tiket'),
                _buildReviewItem(
                  'Fitur',
                  [
                    if (_enableSponsorship) 'Sponsorship',
                    if (_enableDonation) 'Donasi',
                  ].join(', '),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(color: AppColors.textGrey),
          ),
          Text(
            value.isEmpty ? '-' : value,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlinedButton(
            onPressed: (_currentStep > 1 && !isLoading) ? _prevStep : null,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text('Kembali'),
          ),
          ElevatedButton(
            onPressed: isLoading
                ? null
                : () {
                    if (_currentStep == _totalSteps) {
                      _submitEvent(context);
                    } else {
                      _nextStep();
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(_currentStep == _totalSteps ? 'Publish' : 'Lanjut'),
          ),
        ],
      ),
    );
  }

  Widget _buildStepHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            color: AppColors.textGrey,
          ),
        ),
        const SizedBox(height: 24),
        const Divider(),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    String? helperText,
    bool isUpperCase = false,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            helperText: helperText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          textCapitalization: isUpperCase
              ? TextCapitalization.characters
              : TextCapitalization.none,
        ),
      ],
    );
  }

  Widget _buildTagsRow(TextEditingController controller, List<String> tags) {
    return Wrap(
      spacing: 8,
      children: tags.map((tag) {
        return GestureDetector(
          onTap: () => _insertTag(controller, tag),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              '+ $tag',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textGrey,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPreviewBox(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            'OUTPUT:',
            style: GoogleFonts.robotoMono(
              color: Colors.white.withOpacity(0.7),
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: GoogleFonts.robotoMono(
              color: const Color(0xFF10B981),
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
