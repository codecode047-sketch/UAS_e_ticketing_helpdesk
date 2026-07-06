import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';

import '../router/app_router.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    await _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
  }

  void _onNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null && payload.isNotEmpty) {
      navigatorKey.currentContext?.go('${AppRouter.tickets}/$payload');
    }
  }

  Future<void> showTicketUpdateNotification({
    required String ticketId,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'ticket_updates',
      'Pembaruan Tiket',
      channelDescription: 'Notifikasi pembaruan status tiket',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      ticketId.hashCode,
      title,
      body,
      details,
      payload: ticketId,
    );
  }

  Future<void> showCommentNotification({
    required String ticketId,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'new_comments',
      'Komentar Baru',
      channelDescription: 'Notifikasi komentar baru pada tiket',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      ticketId.hashCode,
      title,
      body,
      details,
      payload: ticketId,
    );
  }
}
