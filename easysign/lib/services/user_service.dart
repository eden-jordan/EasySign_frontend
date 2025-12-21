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
}
