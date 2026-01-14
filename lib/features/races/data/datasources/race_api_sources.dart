// lib/features/races/data/datasources/race_api_sources.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../domain/race.dart';

class RaceApiSources {
  final String baseUrl;
  final http.Client client;

  RaceApiSources({required this.baseUrl, http.Client? client})
    : client = client ?? http.Client();

  /// GET /races - Récupérer toutes les courses
  Future<List<Race>> getAllRaces() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/races'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Race.fromJson(json)).toList();
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  /// GET /races/{id} - Récupérer une course par ID
  Future<Race?> getRaceById(int id) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/races/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return Race.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  /// GET /raids/{raidId}/races - Récupérer les courses d'un raid
  Future<List<Race>> getRacesByRaid(int raidId) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/raids/$raidId/races'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Race.fromJson(json)).toList();
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  /// POST /races - Créer une nouvelle course
  Future<Race> createRace(Race race) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/races'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(race.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Race.fromJson(json.decode(response.body));
      } else if (response.statusCode == 422) {
        final errors = json.decode(response.body);
        throw Exception('Validation: ${errors['message'] ?? errors}');
      } else {
        throw Exception('Erreur création: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  /// PUT /races/{id} - Mettre à jour une course
  Future<Race> updateRace(int id, Race race) async {
    try {
      final response = await client.put(
        Uri.parse('$baseUrl/races/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(race.toJson()),
      );

      if (response.statusCode == 200) {
        return Race.fromJson(json.decode(response.body));
      } else {
        throw Exception('Erreur mise à jour: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  /// DELETE /races/{id} - Supprimer une course
  Future<void> deleteRace(int id) async {
    try {
      final response = await client.delete(
        Uri.parse('$baseUrl/races/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Erreur suppression: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }
}
