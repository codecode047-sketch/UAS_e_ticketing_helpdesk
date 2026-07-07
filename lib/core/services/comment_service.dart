import 'api_service.dart';

class CommentService {
  final ApiService _api = ApiService();

  Future<bool> sendComment(Map<String, dynamic> data) async {
    try {
      await _api.post('comments.php', data);
      return true;
    } catch (_) {
      return false;
    }
  }
}
