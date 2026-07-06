import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/notification_item.dart';

class NotificationNotifier extends StateNotifier<List<NotificationItem>> {
  NotificationNotifier() : super([]) {
    loadNotifications();
  }

  void loadNotifications() {
    state = _generateMockNotifications();
  }

  void markAsRead(String id) {
    state = state.map((n) {
      return n.id == id ? n.copyWith(isRead: true) : n;
    }).toList();
  }

  void markAllAsRead() {
    state = state.map((n) => n.copyWith(isRead: true)).toList();
  }

  void deleteNotification(String id) {
    state = state.where((n) => n.id != id).toList();
  }

  int get unreadCount => state.where((n) => !n.isRead).length;

  List<NotificationItem> _generateMockNotifications() {
    return [
      const NotificationItem(
        id: 'n-01',
        type: NotificationType.ticketUpdate,
        title: 'Tiket TKT-004 diperbarui',
        body: 'Status tiket VPN Connection berubah menjadi In Progress',
        ticketId: '4',
        isRead: false,
        createdAt: '2026-06-07 13:45:00',
      ),
      const NotificationItem(
        id: 'n-02',
        type: NotificationType.newComment,
        title: 'Komentar baru pada TKT-001',
        body: 'Budi Santoso menambahkan komentar pada tiket Cannot login to email system',
        ticketId: '1',
        isRead: false,
        createdAt: '2026-06-07 13:30:00',
      ),
      const NotificationItem(
        id: 'n-03',
        type: NotificationType.ticketAssigned,
        title: 'Tiket TKT-010 ditugaskan ke Anda',
        body: 'Server rack cooling issue telah ditugaskan kepada Anda',
        ticketId: '10',
        isRead: false,
        createdAt: '2026-06-07 11:00:00',
      ),
      const NotificationItem(
        id: 'n-04',
        type: NotificationType.ticketClosed,
        title: 'Tiket TKT-003 ditutup',
        body: 'Tiket Request new software license telah berhasil diselesaikan',
        ticketId: '3',
        isRead: true,
        createdAt: '2026-06-06 16:30:00',
      ),
      const NotificationItem(
        id: 'n-05',
        type: NotificationType.ticketUpdate,
        title: 'Tiket TKT-008 diperbarui',
        body: 'Status tiket WiFi access point berubah menjadi Resolved',
        ticketId: '8',
        isRead: true,
        createdAt: '2026-06-06 13:00:00',
      ),
      const NotificationItem(
        id: 'n-06',
        type: NotificationType.newComment,
        title: 'Komentar baru pada TKT-002',
        body: 'Siti Rahma menambahkan komentar pada tiket Printer not responding',
        ticketId: '2',
        isRead: false,
        createdAt: '2026-06-06 10:20:00',
      ),
      const NotificationItem(
        id: 'n-07',
        type: NotificationType.ticketAssigned,
        title: 'Tiket TKT-014 ditugaskan ke Anda',
        body: 'VoIP phone not registering telah ditugaskan kepada Anda',
        ticketId: '14',
        isRead: true,
        createdAt: '2026-06-06 08:00:00',
      ),
      const NotificationItem(
        id: 'n-08',
        type: NotificationType.ticketClosed,
        title: 'Tiket TKT-009 ditutup',
        body: 'Tiket Email signature update request telah berhasil diselesaikan',
        ticketId: '9',
        isRead: true,
        createdAt: '2026-06-05 14:00:00',
      ),
      const NotificationItem(
        id: 'n-09',
        type: NotificationType.newComment,
        title: 'Komentar baru pada TKT-015',
        body: 'Agus Wijaya menambahkan komentar pada tiket Antivirus alert',
        ticketId: '15',
        isRead: true,
        createdAt: '2026-06-05 09:30:00',
      ),
      const NotificationItem(
        id: 'n-10',
        type: NotificationType.ticketUpdate,
        title: 'Tiket TKT-012 dibatalkan',
        body: 'Tiket Network drive access denied telah dibatalkan oleh pengguna',
        ticketId: '12',
        isRead: true,
        createdAt: '2026-06-04 11:00:00',
      ),
    ];
  }
}

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, List<NotificationItem>>(
  (ref) => NotificationNotifier(),
);

final unreadCountProvider = Provider<int>((ref) {
  return ref.watch(notificationProvider).where((n) => !n.isRead).length;
});
