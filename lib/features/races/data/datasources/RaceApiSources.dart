import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../domain/Race.dart';

class RaceApiSources {
  final String baseUrl;
  final http.Client client;

  RaceApiSources({
    required this.baseUrl,
    http.Client? client,
  }) : client = client ?? http.Client();

  /// Récupère toutes les courses depuis l'API
  Future<List<Race>> getAllRaces() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/races'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Race.fromJson(json)).toList();
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Récupère les courses d'un raid spécifique
  Future<List<Race>> getRacesByRaidId(int raidId) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/raids/$raidId/races'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Race.fromJson(json)).toList();
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Récupère une course par son ID
  Future<Race?> getRaceById(int id) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/races/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Race.fromJson(data);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
