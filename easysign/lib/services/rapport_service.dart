import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/rapport.dart';
import '../core/constants/api_constants.dart';

class RapportService {
  final String token;

  RapportService({required this.token});

  Map<String, String> get _headers => {
    ...ApiConstants.headers,
    'Authorization': 'Bearer $token',
  };

  Future<Rapport> journalier({String? date}) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/rapport/journalier',
    ).replace(queryParameters: {if (date != null) 'date': date});

    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      return Rapport.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur rapport journalier');
    }
  }

  Future<Rapport> mensuel({required int month, required int year}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/rapport/mensuel').replace(
      queryParameters: {'month': month.toString(), 'year': year.toString()},
    );

    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      return Rapport.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur rapport mensuel');
    }
  }

  Future<Rapport> annuel({required int year}) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/rapport/annuel',
    ).replace(queryParameters: {'year': year.toString()});

    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      return Rapport.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur rapport annuel');
    }
  }
}
