import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';
import '../models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  //Recuperer la liste des admins
  static Future<List<User>> fetchAdmins(String token) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/list-admins'),
      headers: {...ApiConstants.headers, 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Echec du chargement des admins');
    }
  }

  //Ajouter un admin
  static Future<User> addAdmin({
    required String nom,
    required String prenom,
    required String email,
    String? tel,
    required String password,
    required String token,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/add-admin'),
      headers: {...ApiConstants.headers, 'Authorization': 'Bearer $token'},
      body: jsonEncode({
        'nom': nom,
        'prenom': prenom,
        'email': email,
        'tel': tel,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return User.fromJson(data['admin']);
    } else {
      throw Exception('Echec de l\'ajout de l\'admin');
    }
  }

  //Supprimer un admin
  static Future<void> deleteAdmin({
    required int adminId,
    required String token,
  }) async {
    final response = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}/delete-admin/$adminId'),
      headers: {...ApiConstants.headers, 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      final message = data['message'] ?? 'Echec de la suppression de l\'admin';
      throw Exception(message);
    }
  }
}
