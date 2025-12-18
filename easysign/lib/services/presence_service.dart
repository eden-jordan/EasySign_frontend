import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/presence.dart';
import '../core/constants/api_constants.dart';

class PresenceService {
  final String token;

  PresenceService({required this.token});

  Map<String, String> get _headers => {
    ...ApiConstants.headers,
    'Authorization': 'Bearer $token',
  };

  // Émargement QR
  Future<void> emarger(String qrCode, String action) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/emargement'),
      headers: _headers,
      body: jsonEncode({'qr_code': qrCode, 'action': action}),
    );

    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  // Présences du jour
  Future<List<Presence>> today() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/presences/today'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((e) => Presence.fromJson(e)).toList();
    } else {
      throw Exception('Erreur lors du chargement des présences');
    }
  }

  // Historique d’un personnel
  Future<List<Presence>> history(int personnelId) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/presences/$personnelId/history'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((e) => Presence.fromJson(e)).toList();
    } else {
      throw Exception('Erreur lors du chargement de l\'historique');
    }
  }
}
