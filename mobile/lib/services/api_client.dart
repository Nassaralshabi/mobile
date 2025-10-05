import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiClient {
  final String baseUrl;
  final AuthService authService;
  final http.Client client;

  ApiClient({
    required this.baseUrl,
    required this.authService,
    http.Client? client,
  }) : client = client ?? http.Client();

  Future<Map<String, dynamic>> get(String endpoint) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    try {
      final response = await client.get(
        url,
        headers: authService.getAuthHeaders(),
      ).timeout(const Duration(seconds: 10));

      return _handleResponse(response);
    } on TimeoutException {
      throw 'Request timed out';
    } catch (e) {
      throw 'An unexpected error occurred';
    }
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    try {
      final response = await client.post(
        url,
        headers: authService.getAuthHeaders(),
        body: json.encode(data),
      ).timeout(const Duration(seconds: 10));

      return _handleResponse(response);
    } on TimeoutException {
      throw 'Request timed out';
    } catch (e) {
      throw 'An unexpected error occurred';
    }
  }

  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    try {
      final response = await client.put(
        url,
        headers: authService.getAuthHeaders(),
        body: json.encode(data),
      ).timeout(const Duration(seconds: 10));

      return _handleResponse(response);
    } on TimeoutException {
      throw 'Request timed out';
    } catch (e) {
      throw 'An unexpected error occurred';
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      throw 'Request failed with status: ${response.statusCode}';
    }
  }
}
