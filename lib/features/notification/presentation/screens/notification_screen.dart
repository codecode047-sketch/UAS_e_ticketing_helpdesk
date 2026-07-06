import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../domain/models/notification_item.dart';
import '../providers/notification_provider.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() =>
      _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  IconData _typeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.ticketUpdate:
        return Icons.autorenew;
      case NotificationType.newComment:
        return Icons.chat_bubble_outline;
      case NotificationType.ticketAssigned:
        return Icons.person_outline;
      case NotificationType.ticketClosed:
        return Icons.check_circle_outline;
    }
  }

  Color _typeColor(NotificationType type) {
    switch (type) {
      case NotificationType.ticketUpdate:
        return AppColors.info;
      case NotificationType.newComment:
        return AppColors.secondary;
      case NotificationType.ticketAssigned:
        return AppColors.success;
      case NotificationType.ticketClosed:
        return AppColors.warning;
    }
  }

  String _groupKey(String createdAt) {
    try {
      final dt = DateFormat('yyyy-MM-dd HH:mm:ss').parse(createdAt);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final date = DateTime(dt.year, dt.month, dt.day);

      if (date == today) return 'Hari ini';
      if (date == today.subtract(const Duration(days: 1))) return 'Kemarin';
      return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(dt);
    } catch (_) {
      return createdAt;
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unread = notifications.where((n) => !n.isRead).length;

    final filtered = _tabController.index == 0
        ? notifications
        : notifications.where((n) => !n.isRead).toList();

    final grouped = <String, List<NotificationItem>>{};
    for (final n in filtered) {
      final key = _groupKey(n.createdAt);
      grouped.putIfAbsent(key, () => []).add(n);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: [
          if (unread > 0)
            TextButton(
              onPressed: () {
                ref.read(notificationProvider.notifier).markAllAsRead();
              },
              child: const Text('Tandai semua dibaca'),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            const Tab(text: 'Semua'),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Belum Dibaca'),
                  if (unread > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$unread',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: AppSizes.fontXs,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body: filtered.isEmpty
          ? const EmptyState(
              icon: Icons.notifications_off_outlined,
              title: 'Tidak ada notifikasi',
              subtitle: 'Kami akan memberitahu Anda saat ada pembaruan',
            )
          : RefreshIndicator(
              onRefresh: () async {
                ref.read(notificationProvider.notifier).loadNotifications();
              },
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
                children: grouped.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSizes.md,
                          AppSizes.md,
                          AppSizes.md,
                          AppSizes.sm,
                        ),
                        child: Text(
                          entry.key,
                          style: TextStyle(
                            fontSize: AppSizes.fontSm,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      ...entry.value.map((notif) => _buildNotificationCard(
                            notif,
                            isDark,
                          )),
                    ],
                  );
                }).toList(),
              ),
            ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notif, bool isDark) {
    return Dismissible(
      key: ValueKey(notif.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSizes.md),
        color: AppColors.error,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) {
        ref.read(notificationProvider.notifier).deleteNotification(notif.id);
      },
      child: InkWell(
        onTap: () {
          ref.read(notificationProvider.notifier).markAsRead(notif.id);
          if (notif.ticketId != null) {
            context.push('${AppRouter.tickets}/${notif.ticketId}');
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.sm,
          ),
          color: !notif.isRead
              ? (isDark
                  ? AppColors.primaryDark.withOpacity(0.3)
                  : AppColors.primary.withOpacity(0.05))
              : null,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _typeColor(notif.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Icon(
                  _typeIcon(notif.type),
                  color: _typeColor(notif.type),
                  size: AppSizes.iconMd,
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notif.title,
                            style: TextStyle(
                              fontSize: AppSizes.fontMd,
                              fontWeight: notif.isRead
                                  ? FontWeight.normal
                                  : FontWeight.w600,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (!notif.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      notif.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: AppSizes.fontSm,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _timeAgo(notif.createdAt),
                      style: TextStyle(
                        fontSize: AppSizes.fontXs,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _timeAgo(String dateStr) {
    try {
      final dt = DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateStr);
      return timeago.format(dt, locale: 'id');
    } catch (_) {
      return dateStr;
    }
  }

}
