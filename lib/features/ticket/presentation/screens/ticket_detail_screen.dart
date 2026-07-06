import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/status_timeline.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/models/comment_model.dart';
import '../../domain/models/ticket_model.dart';
import '../providers/comment_provider.dart';
import '../providers/ticket_provider.dart';

class TicketDetailScreen extends ConsumerStatefulWidget {
  final String ticketId;

  const TicketDetailScreen({super.key, required this.ticketId});

  @override
  ConsumerState<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends ConsumerState<TicketDetailScreen> {
  final _commentController = TextEditingController();
  final _noteController = TextEditingController();
  final _scrollController = ScrollController();
  final _picker = ImagePicker();
  bool _descExpanded = false;
  List<XFile> _commentAttachments = [];
  bool _isUpdatingStatus = false;
  TicketStatus _selectedNewStatus = TicketStatus.open;
  String _selectedAssignee = '';
  final List<_InternalNote> _internalNotes = [];

  Ticket? _findTicket(List<Ticket> tickets) {
    try {
      return tickets.firstWhere((t) => t.id == widget.ticketId);
    } catch (_) {
      return null;
    }
  }

  List<TicketHistory> get _mockHistory {
    return [
      const TicketHistory(
        status: 'Open',
        updatedBy: 'Siti Rahma',
        updatedAt: '2026-06-07 09:30',
        note: 'Tiket dibuat oleh pengguna',
      ),
      const TicketHistory(
        status: 'In Progress',
        updatedBy: 'Budi Santoso',
        updatedAt: '2026-06-07 10:00',
        note: 'Tiket sedang diproses oleh tim IT',
      ),
    ];
  }

  List<String> get _mockAttachments {
    return [
      'error_screenshot.png',
      'system_log.txt',
    ];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(commentProvider.notifier).loadComments(widget.ticketId);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _noteController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _timeAgo(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      return timeago.format(dt, locale: 'id');
    } catch (_) {
      return dateStr;
    }
  }

  void _showFullscreenImage(String fileName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FullscreenViewer(fileName: fileName),
      ),
    );
  }

  Future<void> _pickAttachment() async {
    final result = await _picker.pickImage(source: ImageSource.gallery);
    if (result != null) {
      setState(() => _commentAttachments.add(result));
    }
  }

  Future<void> _sendComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    await ref.read(commentProvider.notifier).addComment(
          ticketId: widget.ticketId,
          userId: 'ADM-001',
          userName: 'Surya Prakoso',
          content: text,
        );

    _commentController.clear();
    setState(() => _commentAttachments = []);
  }

  void _showUpdateStatusDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Update Status Tiket'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<TicketStatus>(
                value: _selectedNewStatus,
                decoration: const InputDecoration(
                  labelText: 'Status Baru',
                ),
                items: TicketStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status.label),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setDialogState(() => _selectedNewStatus = value);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
              ElevatedButton(
                onPressed: _isUpdatingStatus
                    ? null
                    : () async {
                        setDialogState(() => _isUpdatingStatus = true);
                        await Future.delayed(const Duration(milliseconds: 300));
                        ref.read(ticketProvider.notifier).updateStatus(
                          widget.ticketId,
                          _selectedNewStatus,
                        );
                        if (mounted) {
                          Navigator.pop(dialogContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Status berhasil diupdate ke ${_selectedNewStatus.label}',
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: _isUpdatingStatus
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAssignDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Assign Tiket'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedAssignee.isNotEmpty
                    ? _selectedAssignee
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Pilih Helpdesk',
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Budi Santoso',
                    child: Text('Budi Santoso'),
                  ),
                  DropdownMenuItem(
                    value: 'Dewi Lestari',
                    child: Text('Dewi Lestari'),
                  ),
                  DropdownMenuItem(
                    value: 'Ahmad Fauzi',
                    child: Text('Ahmad Fauzi'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setDialogState(() => _selectedAssignee = value);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
              ElevatedButton(
                onPressed: _selectedAssignee.isEmpty
                    ? null
                    : () {
                        ref.read(ticketProvider.notifier).assignTicket(
                          widget.ticketId,
                          _selectedAssignee,
                        );
                        Navigator.pop(dialogContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Tiket ditugaskan ke $_selectedAssignee',
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Assign'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Hapus Tiket'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus tiket ini? Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
              ElevatedButton(
                onPressed: () {
                  ref.read(ticketProvider.notifier).deleteTicket(
                    widget.ticketId,
                  );
                  Navigator.pop(dialogContext);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tiket berhasil dihapus'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ticketState = ref.watch(ticketProvider);
    final ticket = _findTicket(ticketState.tickets);
    final comments = ref.watch(commentProvider);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final role = ref.watch(roleProvider);
    final isStaff = role == 'admin' || role == 'helpdesk';
    final isAdmin = role == 'admin';

    if (ticket == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Tiket ${widget.ticketId}')),
        body: const Center(child: Text('Tiket tidak ditemukan')),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverAppBar(
                  expandedHeight: 0,
                  pinned: true,
                  title: Text(ticket.ticketNumber),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () {},
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Hero(
                    tag: 'ticket-${ticket.ticketNumber}',
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ticket.title,
                            style: TextStyle(
                              fontSize: AppSizes.fontXl,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSizes.sm),
                          Row(
                            children: [
                              _buildBadge(
                                ticket.status.label,
                                _statusColor(ticket.status),
                              ),
                              const SizedBox(width: AppSizes.sm),
                              _buildBadge(
                                ticket.priority.label,
                                _priorityColor(ticket.priority),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSizes.sm),
                          Text(
                            '${ticket.category.label}  |  ${ticket.createdAt}  |  ${ticket.updatedAt}',
                            style: TextStyle(
                              fontSize: AppSizes.fontSm,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: _buildDivider()),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ditugaskan kepada',
                          style: TextStyle(
                            fontSize: AppSizes.fontSm,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSizes.sm),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: AppColors.primary,
                              child: Text(
                                ticket.assignedTo.isNotEmpty
                                    ? ticket.assignedTo[0]
                                    : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSizes.sm),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ticket.assignedTo.isNotEmpty
                                      ? ticket.assignedTo
                                      : 'Belum ditugaskan',
                                  style: TextStyle(
                                    fontSize: AppSizes.fontMd,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                  ),
                                ),
                                if (ticket.assignedTo.isNotEmpty)
                                  Text(
                                    'Helpdesk IT',
                                    style: TextStyle(
                                      fontSize: AppSizes.fontSm,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
    if (isStaff)
      SliverToBoxAdapter(child: _buildActionPanel(isDark, isAdmin)),
    if (!isStaff)
      SliverToBoxAdapter(child: _buildUserActions(isDark, ticket)),
                SliverToBoxAdapter(child: _buildDivider()),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Deskripsi',
                          style: TextStyle(
                            fontSize: AppSizes.fontSm,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSizes.sm),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final textSpan = TextSpan(
                              text: ticket.description,
                              style: TextStyle(
                                fontSize: AppSizes.fontMd,
                                color: isDark
                                    ? Colors.white
                                    : AppColors.textPrimary,
                                height: 1.5,
                              ),
                            );
                            final tp = TextPainter(
                              text: textSpan,
                              maxLines: _descExpanded ? null : 3,
                              textDirection: TextDirection.ltr,
                            );
                            tp.layout(maxWidth: constraints.maxWidth);
                            final isOverflow = tp.didExceedMaxLines;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ticket.description,
                                  maxLines: _descExpanded ? null : 3,
                                  overflow: _descExpanded
                                      ? null
                                      : TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: AppSizes.fontMd,
                                    color: isDark
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                    height: 1.5,
                                  ),
                                ),
                                if (isOverflow)
                                  TextButton(
                                    onPressed: () {
                                      setState(
                                        () => _descExpanded = !_descExpanded,
                                      );
                                    },
                                    child: Text(
                                      _descExpanded
                                          ? 'Sembunyikan'
                                          : 'Selengkapnya',
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                if (_mockAttachments.isNotEmpty)
                  SliverToBoxAdapter(child: _buildDivider()),
                if (_mockAttachments.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lampiran',
                            style: TextStyle(
                              fontSize: AppSizes.fontSm,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSizes.sm),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: AppSizes.sm,
                              mainAxisSpacing: AppSizes.sm,
                              childAspectRatio: 1.5,
                            ),
                            itemCount: _mockAttachments.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () =>
                                    _showFullscreenImage(
                                      _mockAttachments[index],
                                    ),
                                child: Hero(
                                  tag: 'attachment-${_mockAttachments[index]}',
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0xFF2A2A3E)
                                          : AppColors.border.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(
                                        AppSizes.radiusSm,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.insert_drive_file,
                                          size: 32,
                                          color: AppColors.primary,
                                        ),
                                        const SizedBox(height: 4),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                          child: Text(
                                            _mockAttachments[index],
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: AppSizes.fontXs,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                SliverToBoxAdapter(child: _buildDivider()),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Riwayat Status',
                          style: TextStyle(
                            fontSize: AppSizes.fontSm,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSizes.md),
                        StatusTimeline(history: ticket.history.isNotEmpty ? ticket.history : _mockHistory),
                      ],
                    ),
                  ),
                ),
                if (isStaff) ...[
                  SliverToBoxAdapter(child: _buildDivider()),
                  SliverToBoxAdapter(
                    child: _buildInternalNotesSection(isDark),
                  ),
                ],
                SliverToBoxAdapter(child: _buildDivider()),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Komentar (${comments.length})',
                          style: TextStyle(
                            fontSize: AppSizes.fontSm,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSizes.md),
                        ...comments.map((comment) {
                          final isOwn = comment.userId == 'ADM-001';
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppSizes.md),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: isOwn
                                      ? AppColors.primary
                                      : AppColors.secondary,
                                  child: Text(
                                    comment.userName[0],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: AppSizes.fontSm,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSizes.sm),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(
                                          AppSizes.sm,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isOwn
                                              ? AppColors.primary.withOpacity(
                                                0.1,
                                              )
                                              : isDark
                                                  ? const Color(0xFF2A2A3E)
                                                  : AppColors.background,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  comment.userName,
                                                  style: TextStyle(
                                                    fontSize: AppSizes.fontSm,
                                                    fontWeight: FontWeight.w600,
                                                    color: isOwn
                                                        ? AppColors.primary
                                                        : (isDark
                                                            ? Colors.white
                                                            : AppColors
                                                                .textPrimary),
                                                  ),
                                                ),
                                                const Spacer(),
                                                Text(
                                                  _timeAgo(comment.createdAt),
                                                  style: TextStyle(
                                                    fontSize: AppSizes.fontXs,
                                                    color: AppColors.textHint,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              comment.content,
                                              style: TextStyle(
                                                fontSize: AppSizes.fontSm,
                                                color: isDark
                                                    ? Colors.white70
                                                    : AppColors.textPrimary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(height: size.height * 0.15),
                ),
              ],
            ),
          ),
          Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1A2E) : AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              padding: EdgeInsets.fromLTRB(
                AppSizes.md,
                AppSizes.sm,
                AppSizes.md,
                bottomInset > 0 ? bottomInset : AppSizes.sm,
              ),
              child: Row(
                children: [
                  if (_commentAttachments.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(right: AppSizes.sm),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Icon(Icons.attach_file, color: AppColors.primary),
                          Positioned(
                            right: -4,
                            top: -4,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${_commentAttachments.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.attach_file),
                    onPressed: _pickAttachment,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      maxLines: 3,
                      minLines: 1,
                      decoration: InputDecoration(
                        hintText: 'Tulis komentar...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: isDark
                            ? const Color(0xFF2A2A3E)
                            : AppColors.background,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        isDense: true,
                      ),
                      onChanged: (_) => setState(() {}),
                      onSubmitted: (_) => _sendComment(),
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  IconButton(
                    icon: Icon(
                      Icons.send_rounded,
                      color: _commentController.text.trim().isNotEmpty
                          ? AppColors.primary
                          : AppColors.textHint,
                    ),
                    onPressed:
                        _commentController.text.trim().isNotEmpty
                            ? _sendComment
                            : null,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUserActions(bool isDark, Ticket ticket) {
    final isResolved = ticket.status == TicketStatus.resolved;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSizes.md, 0, AppSizes.md, AppSizes.sm),
      child: Card(
        color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isDark ? const Color(0xFF2A2A3E) : AppColors.border,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.person, size: 18, color: isDark ? Colors.white70 : AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    'Aksi Anda',
                    style: TextStyle(
                      fontSize: AppSizes.fontSm,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.md),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit Tiket'),
                  onPressed: _showEditTicketDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.info,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              if (isResolved) ...[
                const SizedBox(height: AppSizes.sm),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle, size: 18),
                    label: const Text('Tutup Tiket'),
                    onPressed: _showCloseTicketDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showEditTicketDialog() {
    final tickets = ref.read(ticketProvider).tickets;
    final t = _findTicket(tickets);
    if (t == null) return;
    final titleCtrl = TextEditingController(text: t.title);
    final descCtrl = TextEditingController(text: t.description);
    TicketCategory category = t.category;
    TicketPriority priority = t.priority;
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Edit Tiket'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Judul'),
                ),
                const SizedBox(height: AppSizes.sm),
                DropdownButtonFormField<TicketCategory>(
                  value: category,
                  decoration: const InputDecoration(labelText: 'Kategori'),
                  items: TicketCategory.values.map((c) {
                    return DropdownMenuItem(value: c, child: Text(c.label));
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) setDialogState(() => category = v);
                  },
                ),
                const SizedBox(height: AppSizes.sm),
                DropdownButtonFormField<TicketPriority>(
                  value: priority,
                  decoration: const InputDecoration(labelText: 'Prioritas'),
                  items: TicketPriority.values.map((p) {
                    return DropdownMenuItem(value: p, child: Text(p.label));
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) setDialogState(() => priority = v);
                  },
                ),
                const SizedBox(height: AppSizes.sm),
                TextField(
                  controller: descCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Deskripsi'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: isSaving
                  ? null
                  : () {
                      setDialogState(() => isSaving = true);
                      ref.read(ticketProvider.notifier).updateTicket(
                        t.copyWith(
                          title: titleCtrl.text.trim(),
                          description: descCtrl.text.trim(),
                          category: category,
                          priority: priority,
                          updatedAt: _now(),
                        ),
                      );
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tiket berhasil diedit'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.info,
              ),
              child: isSaving
                  ? const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white,
                      ),
                    )
                  : const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  String _now() {
    final now = DateTime.now();
    final y = now.year;
    final M = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    return '$y-$M-$d $h:$m';
  }

  void _showCloseTicketDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Tutup Tiket'),
        content: const Text('Apakah Anda yakin ingin menutup tiket ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(ticketProvider.notifier).updateStatus(
                widget.ticketId,
                TicketStatus.closed,
              );
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tiket berhasil ditutup'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
            ),
            child: const Text('Tutup', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionPanel(bool isDark, bool isAdmin) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSizes.md, 0, AppSizes.md, AppSizes.sm),
      child: Card(
        color: isDark ? const Color(0xFF1E1E2C) : const Color(0xFFFFF8E1),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isDark ? const Color(0xFF2A2A3E) : const Color(0xFFFFE082),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.admin_panel_settings, size: 18, color: isDark ? Colors.white70 : AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    'Panel Tindakan',
                    style: TextStyle(
                      fontSize: AppSizes.fontSm,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.md),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.update, size: 18),
                  label: const Text('Update Status'),
                  onPressed: _showUpdateStatusDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.info,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.person_add, size: 18),
                  label: const Text('Assign Tiket'),
                  onPressed: _showAssignDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.warning,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              if (isAdmin) ...[
                const SizedBox(height: AppSizes.sm),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text('Hapus Tiket'),
                    onPressed: _showDeleteDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInternalNotesSection(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lock,
                size: 16,
                color: isDark ? Colors.grey : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                'Catatan Internal',
                style: TextStyle(
                  fontSize: AppSizes.fontSm,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF2A2A3E)
                  : const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF3A3A4E)
                    : const Color(0xFFFFE082),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ..._internalNotes.map((note) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(top: 6, right: 8),
                        decoration: const BoxDecoration(
                          color: AppColors.warning,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              note.content,
                              style: const TextStyle(fontSize: 13),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${note.createdBy} - ${note.createdAt}',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textHint,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
                if (_internalNotes.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Belum ada catatan internal.',
                      style: TextStyle(fontSize: 13, color: AppColors.textHint),
                    ),
                  ),
                const SizedBox(height: AppSizes.sm),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _noteController,
                        maxLines: 2,
                        minLines: 1,
                        decoration: InputDecoration(
                          hintText: 'Tambah catatan internal...',
                          filled: true,
                          fillColor: isDark
                              ? const Color(0xFF1E1E2C)
                              : Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isDark
                                  ? const Color(0xFF3A3A4E)
                                  : AppColors.border,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          isDense: true,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    IconButton(
                      icon: Icon(
                        Icons.send,
                        color: _noteController.text.trim().isNotEmpty
                            ? AppColors.warning
                            : AppColors.textHint,
                      ),
                      onPressed: _noteController.text.trim().isNotEmpty
                          ? () {
                              final now = DateTime.now();
                              final y = now.year;
                              final M = now.month.toString().padLeft(2, '0');
                              final d = now.day.toString().padLeft(2, '0');
                              final h = now.hour.toString().padLeft(2, '0');
                              final m = now.minute.toString().padLeft(2, '0');
                              _internalNotes.add(_InternalNote(
                                content: _noteController.text.trim(),
                                createdBy: 'Surya Prakoso',
                                createdAt: '$y-$M-$d $h:$m',
                              ));
                              _noteController.clear();
                              setState(() {});
                            }
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: AppSizes.fontSm,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 6);
  }

  Color _statusColor(TicketStatus status) {
    switch (status) {
      case TicketStatus.open:
        return AppColors.warning;
      case TicketStatus.inProgress:
        return AppColors.info;
      case TicketStatus.resolved:
        return AppColors.success;
      case TicketStatus.closed:
        return AppColors.success;
      case TicketStatus.cancelled:
        return AppColors.error;
    }
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

class _InternalNote {
  final String content;
  final String createdBy;
  final String createdAt;

  const _InternalNote({
    required this.content,
    required this.createdBy,
    required this.createdAt,
  });
}

class _FullscreenViewer extends StatelessWidget {
  final String fileName;

  const _FullscreenViewer({required this.fileName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(fileName),
      ),
      body: Center(
        child: Hero(
          tag: 'attachment-$fileName',
          child: Icon(
            Icons.insert_drive_file,
            size: 100,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}
