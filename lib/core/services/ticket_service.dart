import 'api_service.dart';

class TicketService {
  final ApiService _api = ApiService();

  Future<List<dynamic>> getTickets() async {
    try {
      final response = await _api.get('tickets.php');
      final data = response.data;
      if (data is List) return data;
      if (data is Map && data.containsKey('data')) return data['data'] as List;
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, dynamic>> getDetail(int id) async {
    try {
      final response = await _api.get('tickets/id.php', params: {'id': id});
      return response.data as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }
}
