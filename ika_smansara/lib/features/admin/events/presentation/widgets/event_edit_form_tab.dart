import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';
import 'package:flutter_quill_delta_from_html/flutter_quill_delta_from_html.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:cached_network_image/cached_network_image.dart';
import '../bloc/admin_events_bloc.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../events/domain/entities/event.dart';

class EventEditFormTab extends StatefulWidget {
  final Event event;

  const EventEditFormTab({super.key, required this.event});

  @override
  State<EventEditFormTab> createState() => _EventEditFormTabState();
}

class _EventEditFormTabState extends State<EventEditFormTab> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _locationController;
  late TextEditingController
  _descriptionController; // Keep for fallback/validation if needed
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late String _selectedStatus;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  late QuillController _quillController;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event.title);
    _locationController = TextEditingController(text: widget.event.location);
    _descriptionController = TextEditingController(
      text: widget.event.description,
    );
    _selectedDate = widget.event.date;

    // Parse time string (HH:mm format, handles suffixes like "WIB")
    try {
      final timeParts = widget.event.time.split(':');
      if (timeParts.length >= 2) {
        // Extract only numbers from the parts to handle suffixes like "WIB"
        final hour = int.parse(timeParts[0].replaceAll(RegExp(r'[^0-9]'), ''));
        final minute = int.parse(
          timeParts[1].replaceAll(RegExp(r'[^0-9]'), ''),
        );
        _selectedTime = TimeOfDay(hour: hour, minute: minute);
      } else {
        _selectedTime = const TimeOfDay(hour: 0, minute: 0);
      }
    } catch (e) {
      _selectedTime = const TimeOfDay(hour: 0, minute: 0);
    }

    _selectedStatus = widget.event.status;

    // Initialize Quill Controller with HTML to Delta conversion
    try {
      final delta = HtmlToDelta().convert(widget.event.description);
      _quillController = QuillController(
        document: Document.fromDelta(delta),
        selection: const TextSelection.collapsed(offset: 0),
        readOnly: false,
      );
    } catch (e) {
      _quillController = QuillController.basic();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _quillController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
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
          _imageFile = compressedFile;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mengambil gambar: $e')));
      }
    }
  }

  Future<File> _compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath = p.join(
      dir.path,
      'compressed_banner_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      minWidth: 1024,
      minHeight: 1024,
      quality: 85,
    );

    if (result == null) {
      throw Exception('Gagal mengompres gambar');
    }

    return File(result.path);
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
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
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final deltaJson = _quillController.document.toDelta().toJson();
    final converter = QuillDeltaToHtmlConverter(
      List<Map<String, dynamic>>.from(deltaJson),
      ConverterOptions.forEmail(),
    );
    final String description = converter.convert();
    debugPrint('Saved description HTML: $description');

    final timeString =
        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';
    final updatedData = {
      'title': _titleController.text,
      'location': _locationController.text,
      'description': description,
      'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
      'time': timeString,
      'status': _selectedStatus,
    };

    context.read<AdminEventsBloc>().add(
      UpdateEvent(widget.event.id, updatedData, bannerFile: _imageFile),
    );
  }

  void _deleteEvent() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Event'),
        content: const Text('Apakah Anda yakin ingin menghapus event ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // Navigate back before deleting
      Navigator.pop(context);
      context.read<AdminEventsBloc>().add(DeleteEventAction(widget.event.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminEventsBloc, AdminEventsState>(
      listener: (context, state) {
        if (state is AdminEventsActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state is AdminEventsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Detail Event',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 20),

              // Judul Event
              _buildInputGroup(
                label: 'Judul Event',
                child: TextFormField(
                  controller: _titleController,
                  decoration: _inputDecoration('Masukkan judul event'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Judul harus diisi' : null,
                ),
              ),

              // Tanggal & Waktu
              Row(
                children: [
                  Expanded(
                    child: _buildInputGroup(
                      label: 'Tanggal',
                      child: InkWell(
                        onTap: _selectDate,
                        child: InputDecorator(
                          decoration: _inputDecoration('Pilih tanggal'),
                          child: Text(
                            DateFormat(
                              'dd MMM yyyy',
                              'id',
                            ).format(_selectedDate),
                            style: GoogleFonts.inter(fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInputGroup(
                      label: 'Waktu',
                      child: InkWell(
                        onTap: _selectTime,
                        child: InputDecorator(
                          decoration: _inputDecoration('Pilih waktu'),
                          child: Text(
                            _selectedTime.format(context),
                            style: GoogleFonts.inter(fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Lokasi
              _buildInputGroup(
                label: 'Lokasi',
                child: TextFormField(
                  controller: _locationController,
                  decoration: _inputDecoration('Masukkan lokasi event'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Lokasi harus diisi' : null,
                ),
              ),

              // Deskripsi
              _buildInputGroup(
                label: 'Deskripsi',
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                  child: Column(
                    children: [
                      QuillSimpleToolbar(
                        controller: _quillController,
                        config: const QuillSimpleToolbarConfig(
                          showFontFamily: false,
                          showFontSize: false,
                          showSubscript: false,
                          showSuperscript: false,
                          showSmallButton: false,
                          showInlineCode: false,
                          showLink: true,
                          showCodeBlock: false,
                          showDirection: false,
                          showAlignmentButtons: true,
                          multiRowsDisplay: true,
                        ),
                      ),
                      const Divider(height: 1),
                      Container(
                        height: 300,
                        padding: const EdgeInsets.all(12),
                        child: QuillEditor.basic(
                          controller: _quillController,
                          focusNode: _focusNode,
                          scrollController: _scrollController,
                          config: QuillEditorConfig(
                            autoFocus: false,
                            expands: false,
                            padding: EdgeInsets.zero,
                            placeholder: 'Tulis deskripsi event...',
                            embedBuilders: kIsWeb
                                ? FlutterQuillEmbeds.editorWebBuilders()
                                : FlutterQuillEmbeds.editorBuilders(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Banner Upload
              _buildInputGroup(
                label: 'Banner Event',
                child: InkWell(
                  onTap: _pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.background,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _imageFile != null
                          ? Image.file(_imageFile!, fit: BoxFit.cover)
                          : (widget.event.banner != null &&
                                widget.event.banner!.isNotEmpty)
                          ? CachedNetworkImage(
                              imageUrl: widget.event.banner!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Center(
                                    child: Icon(
                                      Icons.error_outline,
                                      color: AppColors.error,
                                    ),
                                  ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.image_outlined,
                                  size: 48,
                                  color: AppColors.textGrey,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Klik untuk upload banner',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: AppColors.textGrey,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),

              // Status Event
              _buildInputGroup(
                label: 'Status Event',
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedStatus,
                  decoration: _inputDecoration('Pilih status'),
                  items: const [
                    DropdownMenuItem(value: 'draft', child: Text('Draft')),
                    DropdownMenuItem(value: 'active', child: Text('Active')),
                    DropdownMenuItem(
                      value: 'completed',
                      child: Text('Completed'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _selectedStatus = value);
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _saveChanges,
                      icon: const Icon(Icons.save),
                      label: const Text('Simpan Perubahan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: _deleteEvent,
                    icon: const Icon(Icons.delete),
                    label: const Text('Hapus'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputGroup({required String label, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.textLight),
      filled: true,
      fillColor: Colors.white,
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}
