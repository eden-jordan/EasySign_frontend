import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/personnel.dart';
import '../core/constants/api_constants.dart';

class PersonnelService {
  final String token;

  PersonnelService({required this.token});

  Map<String, String> get _headers => {
    ...ApiConstants.headers,
    'Authorization': 'Bearer $token',
  };

  // Lister le personnel
  Future<List<Personnel>> getAll() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/personnel'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((e) => Personnel.fromJson(e)).toList();
    } else {
      throw Exception('Erreur lors du chargement du personnel');
    }
  }

  // Créer personnel
  Future<Personnel> create(Personnel p) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/personnel'),
      headers: _headers,
      body: jsonEncode(p.toJson()),
    );

    if (response.statusCode == 201) {
      return Personnel.fromJson(jsonDecode(response.body)['personnel']);
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  // Détails
  Future<Personnel> getById(int id) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/personnel/$id'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return Personnel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur lors du chargement du personnel');
    }
  }

  // Modifier
  Future<void> update(Personnel p) async {
    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}/personnel/${p.id}'),
      headers: _headers,
      body: jsonEncode(p.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  // Supprimer
  Future<void> delete(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}/personnel/$id'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }
}
