import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/comment_model.dart';

class CommentNotifier extends StateNotifier<List<Comment>> {
  CommentNotifier() : super([]);

  void loadComments(String ticketId) {
    state = _generateMockComments(ticketId);
  }

  Future<void> addComment({
    required String ticketId,
    required String userId,
    required String userName,
    required String content,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final comment = Comment(
      id: 'c-${DateTime.now().millisecondsSinceEpoch}',
      ticketId: ticketId,
      userId: userId,
      userName: userName,
      content: content,
      createdAt: DateTime.now().toIso8601String(),
    );
    state = [...state, comment];
  }

  List<Comment> _generateMockComments(String ticketId) {
    return [
      Comment(
        id: 'c-1',
        ticketId: ticketId,
        userId: 'USR-001',
        userName: 'Siti Rahma',
        content: 'Saya sudah mencoba reset password tapi tetap tidak bisa login. Apakah ada masalah di server?',
        createdAt: '2026-06-07 10:15:00',
      ),
      Comment(
        id: 'c-2',
        ticketId: ticketId,
        userId: 'ADM-001',
        userName: 'Surya Prakoso',
        content: 'Kami sedang memeriksa server autentikasi. Mohon tunggu sekitar 1 jam.',
        createdAt: '2026-06-07 10:45:00',
      ),
      Comment(
        id: 'c-3',
        ticketId: ticketId,
        userId: 'USR-001',
        userName: 'Siti Rahma',
        content: 'Baik, saya tunggu. Terima kasih.',
        createdAt: '2026-06-07 11:00:00',
      ),
      Comment(
        id: 'c-4',
        ticketId: ticketId,
        userId: 'ADM-001',
        userName: 'Surya Prakoso',
        content: 'Masalah sudah ditemukan. Ada kegagalan pada service LDAP. Tim kami sedang melakukan perbaikan.',
        createdAt: '2026-06-07 13:30:00',
      ),
    ];
  }
}

final commentProvider = StateNotifierProvider<CommentNotifier, List<Comment>>(
  (ref) => CommentNotifier(),
);
