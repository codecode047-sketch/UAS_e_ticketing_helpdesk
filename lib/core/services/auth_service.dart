import 'api_service.dart';

class AuthService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _api.post('login.php', {
        'email': email,
        'password': password,
      });
      return response.data as Map<String, dynamic>;
    } catch (_) {
      return {'success': false};
    }
  }
}
