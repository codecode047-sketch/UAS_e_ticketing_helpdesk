import 'package:equatable/equatable.dart';

enum NotificationType {
  ticketUpdate,
  newComment,
  ticketAssigned,
  ticketClosed,
}

class NotificationItem extends Equatable {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final String? ticketId;
  final bool isRead;
  final String createdAt;

  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.ticketId,
    this.isRead = false,
    required this.createdAt,
  });

  NotificationItem copyWith({bool? isRead}) {
    return NotificationItem(
      id: id,
      type: type,
      title: title,
      body: body,
      ticketId: ticketId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    type,
    title,
    body,
    ticketId,
    isRead,
    createdAt,
  ];
}
