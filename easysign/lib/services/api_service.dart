import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/constants/api_constants.dart';

class ApiService {
  final storage = const FlutterSecureStorage();

  Future<Map<String, String>> _headers() async {
    final token = await storage.read(key: 'token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> get(String endpoint) async {
    return http.get(
      Uri.parse("${ApiConstants.baseUrl}/$endpoint"),
      headers: await _headers(),
    );
  }

  Future<http.Response> post(String endpoint, Map data) async {
    return http.post(
      Uri.parse("${ApiConstants.baseUrl}/$endpoint"),
      headers: await _headers(),
      body: jsonEncode(data),
    );
  }
}
