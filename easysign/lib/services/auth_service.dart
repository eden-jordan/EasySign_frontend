import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';

class AuthService {
  // Enregistrer superadmin
  static Future<Map<String, dynamic>> registerSuperadmin({
    required String nom,
    required String prenom,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/register-superadmin'),
      headers: ApiConstants.headers,
      body: jsonEncode({
        'nom': nom,
        'prenom': prenom,
        'email': email,
        'password': password,
      }),
    );

    return jsonDecode(response.body);
  }

  // Login
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/login'),
      headers: ApiConstants.headers,
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  // Logout
  static Future<void> logout(String token) async {
    await http.post(
      Uri.parse('${ApiConstants.baseUrl}/logout'),
      headers: {...ApiConstants.headers, 'Authorization': 'Bearer $token'},
    );
  }
}
