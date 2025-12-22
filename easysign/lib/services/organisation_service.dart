import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/organisation.dart';
import '../models/horaire.dart';
import '../core/constants/api_constants.dart';

class OrganisationService {
  final String token;

  OrganisationService({required this.token});

  Map<String, String> get _headers => {
    ...ApiConstants.headers,
    'Authorization': 'Bearer $token',
  };

  // Future<Organisation> createOrganisation(String nom, String adresse) async {
  //   final response = await http.post(
  //     Uri.parse('${ApiConstants.baseUrl}/organisation-store'),
  //     headers: ApiConstants.headers,
  //     body: jsonEncode({'nom': nom, 'adresse': adresse}),
  //   );

  //   if (response.statusCode == 201) {
  //     return Organisation.fromJson(jsonDecode(response.body)['organisation']);
  //   } else {
  //     final errorMessage =
  //         jsonDecode(response.body)['message'] ?? 'Erreur inconnue';
  //     throw Exception(errorMessage);
  //   }
  // }

  Future<Organisation> getOrganisation() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/organisation'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return Organisation.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur lors du chargement de l\'organisation');
    }
  }

  Future<Horaire> addHoraire(Horaire horaire) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/horaire'),
      headers: _headers,
      body: jsonEncode(horaire.toJson()),
    );

    if (response.statusCode == 201) {
      return Horaire.fromJson(jsonDecode(response.body)['horaire']);
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<List<Horaire>> getHoraires() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/horaires'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((e) => Horaire.fromJson(e)).toList();
    } else {
      throw Exception('Erreur lors du chargement des horaires');
    }
  }
}
