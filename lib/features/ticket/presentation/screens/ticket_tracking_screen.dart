import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/status_timeline.dart';
import '../../../../shared/widgets/ticket_card.dart';
import '../../domain/models/ticket_model.dart';
import '../providers/ticket_provider.dart';

class TicketTrackingScreen extends ConsumerStatefulWidget {
  final String ticketId;

  const TicketTrackingScreen({super.key, required this.ticketId});

  @override
  ConsumerState<TicketTrackingScreen> createState() => _TicketTrackingScreenState();
}

class _TicketTrackingScreenState extends ConsumerState<TicketTrackingScreen> {
  Ticket? _findTicket(List<Ticket> tickets) {
    try {
      return tickets.firstWhere((t) => t.id == widget.ticketId);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tickets = ref.watch(ticketProvider).tickets;
    final ticket = _findTicket(tickets);

    if (ticket == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tracking Tiket')),
        body: const EmptyState(
          icon: Icons.search_off,
          title: 'Tiket tidak ditemukan',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Tracking ${ticket.ticketNumber}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TicketCard(
              ticketId: ticket.ticketNumber,
              title: ticket.title,
              status: ticket.status.label,
              priority: ticket.priority.label,
              createdAt: ticket.createdAt,
              assignedTo: ticket.assignedTo,
              onTap: () {},
            ),
            const SizedBox(height: AppSizes.lg),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informasi Tracking',
                      style: TextStyle(
                        fontSize: AppSizes.fontLg,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.md),
                    _infoRow('Status Saat Ini', ticket.status.label, isDark),
                    _infoRow('Ditugaskan ke', ticket.assignedTo, isDark),
                    _infoRow('Dibuat pada', ticket.createdAt, isDark),
                    _infoRow('Update terakhir', ticket.updatedAt, isDark),
                    _infoRow(
                      'Kategori',
                      ticket.category.label,
                      isDark,
                    ),
                    _infoRow(
                      'Prioritas',
                      ticket.priority.label,
                      isDark,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            Text(
              'Timeline Status',
              style: TextStyle(
                fontSize: AppSizes.fontLg,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSizes.md),
            ticket.history.isEmpty
                ? const EmptyState(
                    icon: Icons.history,
                    title: 'Belum ada riwayat',
                    subtitle: 'Perubahan status tiket akan muncul di sini',
                  )
                : StatusTimeline(history: ticket.history),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: AppSizes.fontSm,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: AppSizes.fontSm,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
