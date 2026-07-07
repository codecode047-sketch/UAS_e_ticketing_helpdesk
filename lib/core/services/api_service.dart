import 'package:dio/dio.dart';

class ApiService {
  static final ApiService _instance = ApiService._();
  factory ApiService() => _instance;
  ApiService._();

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2/e_ticketing_helpdesk/backend/api/',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      headers: {'Accept': 'application/json'},
    ),
  );

  Future<Response> post(String endpoint, Map<String, dynamic> data) async {
    return _dio.post(endpoint, data: data);
  }

  Future<Response> get(String endpoint, {Map<String, dynamic>? params}) async {
    return _dio.get(endpoint, queryParameters: params);
  }
}
