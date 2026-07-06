import 'package:equatable/equatable.dart';

class Comment extends Equatable {
  final String id;
  final String ticketId;
  final String userId;
  final String userName;
  final String content;
  final String createdAt;
  final List<String> attachments;

  const Comment({
    required this.id,
    required this.ticketId,
    required this.userId,
    required this.userName,
    required this.content,
    required this.createdAt,
    this.attachments = const [],
  });

  @override
  List<Object?> get props => [
    id,
    ticketId,
    userId,
    userName,
    content,
    createdAt,
    attachments,
  ];
}

class TicketHistory extends Equatable {
  final String status;
  final String updatedBy;
  final String updatedAt;
  final String note;

  const TicketHistory({
    required this.status,
    required this.updatedBy,
    required this.updatedAt,
    this.note = '',
  });

  TicketHistory copyWith({
    String? status,
    String? updatedBy,
    String? updatedAt,
    String? note,
  }) {
    return TicketHistory(
      status: status ?? this.status,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedAt: updatedAt ?? this.updatedAt,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'updatedBy': updatedBy,
      'updatedAt': updatedAt,
      'note': note,
    };
  }

  factory TicketHistory.fromMap(Map<String, dynamic> map) {
    return TicketHistory(
      status: map['status'] as String,
      updatedBy: map['updatedBy'] as String,
      updatedAt: map['updatedAt'] as String,
      note: map['note'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory TicketHistory.fromJson(Map<String, dynamic> json) =>
      TicketHistory.fromMap(json);

  @override
  List<Object?> get props => [status, updatedBy, updatedAt, note];
}
