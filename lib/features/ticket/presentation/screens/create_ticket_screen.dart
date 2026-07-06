import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../domain/models/ticket_model.dart';
import '../providers/ticket_provider.dart';

class CreateTicketScreen extends ConsumerStatefulWidget {
  const CreateTicketScreen({super.key});

  @override
  ConsumerState<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends ConsumerState<CreateTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imagePicker = ImagePicker();

  TicketCategory? _selectedCategory;
  TicketPriority _selectedPriority = TicketPriority.medium;
  final List<XFile> _attachments = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (result != null && _attachments.length < 3) {
      setState(() => _attachments.add(result));
    }
  }

  Future<void> _takePhoto() async {
    final result = await _imagePicker.pickImage(source: ImageSource.camera);
    if (result != null && _attachments.length < 3) {
      setState(() => _attachments.add(result));
    }
  }

  void _removeAttachment(int index) {
    setState(() => _attachments.removeAt(index));
  }

  void _showAttachmentPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSizes.lg),
              ListTile(
                leading: const Icon(Icons.attach_file),
                title: const Text('Pilih File'),
                subtitle: const Text('Dari galeri'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFile();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Ambil Foto'),
                subtitle: const Text('Menggunakan kamera'),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
              const SizedBox(height: AppSizes.sm),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih kategori'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    final now = DateTime.now();
    final state = ref.read(ticketProvider);
    final ticketNum = 'TKT-${(state.tickets.length + 1).toString().padLeft(3, '0')}';

    final ticket = Ticket(
      id: now.millisecondsSinceEpoch.toString(),
      ticketNumber: ticketNum,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory!,
      priority: _selectedPriority,
      status: TicketStatus.open,
      createdAt: _formatDateTime(now),
      updatedAt: _formatDateTime(now),
      userId: 'USR-${now.millisecondsSinceEpoch}',
      assignedTo: '',
    );

    ref.read(ticketProvider.notifier).createTicket(ticket);

    if (!mounted) return;
    setState(() => _isSubmitting = false);
    _showSuccessDialog(ticket);
  }

  String _formatDateTime(DateTime dt) {
    final y = dt.year;
    final M = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$y-$M-$d $h:$m';
  }

  void _showSuccessDialog(Ticket ticket) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 36),
            ),
            const SizedBox(height: AppSizes.md),
            const Text(
              'Tiket Berhasil Dibuat!',
              style: TextStyle(
                fontSize: AppSizes.fontLg,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              'Nomor tiket: ${ticket.ticketNumber}',
              style: TextStyle(
                fontSize: AppSizes.fontMd,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.push('${AppRouter.tickets}/${ticket.id}');
                },
                child: const Text('Lihat Tiket'),
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _resetForm();
              },
              child: const Text('Buat Tiket Lain'),
            ),
          ],
        ),
      ),
    );
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _titleController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedCategory = null;
      _selectedPriority = TicketPriority.medium;
      _attachments.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Buat Tiket Baru')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Judul Tiket',
                style: TextStyle(
                  fontSize: AppSizes.fontSm,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey[300] : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              TextFormField(
                controller: _titleController,
                maxLength: 100,
                decoration: const InputDecoration(
                  hintText: 'Masukkan judul tiket',
                  counterText: '',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Judul tiket harus diisi';
                  }
                  if (value.trim().length < 5) {
                    return 'Judul minimal 5 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.sm),
              Text(
                'Kategori',
                style: TextStyle(
                  fontSize: AppSizes.fontSm,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey[300] : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              DropdownButtonFormField<TicketCategory>(
                value: _selectedCategory,
                hint: const Text('Pilih kategori'),
                items: TicketCategory.values.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat.label),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedCategory = value);
                },
                validator: (value) {
                  if (value == null) return 'Kategori harus dipilih';
                  return null;
                },
                decoration: const InputDecoration(
                  hintText: 'Pilih kategori',
                ),
              ),
              const SizedBox(height: AppSizes.md),
              Text(
                'Prioritas',
                style: TextStyle(
                  fontSize: AppSizes.fontSm,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey[300] : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              Row(
                children: TicketPriority.values.map((priority) {
                  final isSelected = _selectedPriority == priority;
                  final color = _priorityColor(priority);
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: AppSizes.xs),
                      child: ChoiceChip(
                        label: Text(priority.label),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() => _selectedPriority = priority);
                        },
                        selectedColor: color,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : color,
                          fontSize: AppSizes.fontSm,
                          fontWeight: FontWeight.w600,
                        ),
                        backgroundColor: color.withOpacity(0.1),
                        side: BorderSide(
                          color: isSelected ? color : color.withOpacity(0.3),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSizes.md),
              Text(
                'Deskripsi',
                style: TextStyle(
                  fontSize: AppSizes.fontSm,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey[300] : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                minLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Jelaskan masalah Anda secara detail...',
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Deskripsi harus diisi';
                  }
                  if (value.trim().length < 20) {
                    return 'Deskripsi minimal 20 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.md),
              Text(
                'Lampiran (maks. 3 file)',
                style: TextStyle(
                  fontSize: AppSizes.fontSm,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey[300] : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              if (_attachments.isNotEmpty)
                SizedBox(
                  height: 100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _attachments.length,
                    separatorBuilder: (_, __) => const SizedBox(
                      width: AppSizes.sm,
                    ),
                    itemBuilder: (context, index) {
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusSm,
                            ),
                            child: Image.file(
                              File(_attachments[index].path),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            right: -6,
                            top: -6,
                            child: GestureDetector(
                              onTap: () => _removeAttachment(index),
                              child: Container(
                                width: 22,
                                height: 22,
                                decoration: const BoxDecoration(
                                  color: AppColors.error,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              if (_attachments.isNotEmpty)
                const SizedBox(height: AppSizes.sm),
              Row(
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.attach_file),
                    label: const Text('Pilih File'),
                    onPressed: _attachments.length < 3 ? _showAttachmentPicker : null,
                  ),
                  const SizedBox(width: AppSizes.sm),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Ambil Foto'),
                    onPressed: _attachments.length < 3 ? _showAttachmentPicker : null,
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.lg),
              AppButton(
                text: 'Kirim Tiket',
                isLoading: _isSubmitting,
                onPressed: _submit,
              ),
              const SizedBox(height: AppSizes.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Color _priorityColor(TicketPriority priority) {
    switch (priority) {
      case TicketPriority.low:
        return AppColors.success;
      case TicketPriority.medium:
        return AppColors.warning;
      case TicketPriority.high:
        return AppColors.error;
      case TicketPriority.critical:
        return Colors.red;
    }
  }
}

