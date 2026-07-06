import 'package:equatable/equatable.dart';

import 'comment_model.dart';

enum TicketStatus {
  open('Open'),
  inProgress('In Progress'),
  resolved('Resolved'),
  closed('Closed'),
  cancelled('Cancelled');

  final String label;
  const TicketStatus(this.label);
}

enum TicketPriority {
  low('Low'),
  medium('Medium'),
  high('High'),
  critical('Critical');

  final String label;
  const TicketPriority(this.label);
}

enum TicketCategory {
  hardware('Hardware'),
  software('Software'),
  jaringan('Jaringan'),
  akunAkses('Akun & Akses'),
  lainnya('Lainnya');

  final String label;
  const TicketCategory(this.label);
}

class Ticket extends Equatable {
  final String id;
  final String ticketNumber;
  final String title;
  final String description;
  final TicketCategory category;
  final TicketPriority priority;
  final TicketStatus status;
  final String createdAt;
  final String updatedAt;
  final String userId;
  final String assignedTo;
  final List<String> attachments;
  final List<String> comments;
  final List<TicketHistory> history;

  const Ticket({
    required this.id,
    required this.ticketNumber,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    required this.assignedTo,
    this.attachments = const [],
    this.comments = const [],
    this.history = const [],
  });

  Ticket copyWith({
    String? id,
    String? ticketNumber,
    String? title,
    String? description,
    TicketCategory? category,
    TicketPriority? priority,
    TicketStatus? status,
    String? createdAt,
    String? updatedAt,
    String? userId,
    String? assignedTo,
    List<String>? attachments,
    List<String>? comments,
    List<TicketHistory>? history,
  }) {
    return Ticket(
      id: id ?? this.id,
      ticketNumber: ticketNumber ?? this.ticketNumber,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
      assignedTo: assignedTo ?? this.assignedTo,
      attachments: attachments ?? this.attachments,
      comments: comments ?? this.comments,
      history: history ?? this.history,
    );
  }

  @override
  List<Object?> get props => [
    id,
    ticketNumber,
    title,
    description,
    category,
    priority,
    status,
    createdAt,
    updatedAt,
    userId,
    assignedTo,
    attachments,
    comments,
    history,
  ];
}
