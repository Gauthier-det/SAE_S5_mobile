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
        final responseData = json.decode(response.body);
        final List<dynamic> data = responseData['data'] ?? responseData;
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
        final responseData = json.decode(response.body);
        return Race.fromJson(responseData['data'] ?? responseData);
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
        final responseData = json.decode(response.body);
        final List<dynamic> data = responseData['data'] ?? responseData;
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
      // Préparer les données sans RAC_ID (auto-généré), ni les champs optionnels non gérés
      final Map<String, dynamic> data = {
        'USE_ID': race.userId,
        'RAI_ID': race.raidId,
        'RAC_TIME_START': race.startDate.toIso8601String(),
        'RAC_TIME_END': race.endDate.toIso8601String(),
        'RAC_TYPE': race.type,
        'RAC_DIFFICULTY': race.difficulty,
        'RAC_MIN_PARTICIPANTS': race.minParticipants,
        'RAC_MAX_PARTICIPANTS': race.maxParticipants,
        'RAC_MIN_TEAMS': race.minTeams,
        'RAC_MAX_TEAMS': race.maxTeams,
        'RAC_TEAM_MEMBERS': race.teamMembers,
        'RAC_AGE_MIN': race.ageMin,
        'RAC_AGE_MIDDLE': race.ageMiddle,
        'RAC_AGE_MAX': race.ageMax,
      };

      print('🔍 Creating race with data: ${json.encode(data)}');

      final response = await client.post(
        Uri.parse('$baseUrl/races'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(data),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return Race.fromJson(responseData['data'] ?? responseData);
      } else if (response.statusCode == 422) {
        final errors = json.decode(response.body);
        print('❌ Validation errors: ${errors}');
        throw Exception('Validation: ${json.encode(errors['errors'] ?? errors['message'] ?? errors)}');
      } else {
        throw Exception('Erreur création: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error creating race: $e');
      throw Exception('Erreur réseau: $e');
    }
  }

  /// PUT /races/{id} - Mettre à jour une course
  Future<Race> updateRace(int id, Race race) async {
    try {
      // Préparer les données sans RAC_ID
      final Map<String, dynamic> data = {
        'USE_ID': race.userId,
        'RAI_ID': race.raidId,
        'RAC_TIME_START': race.startDate.toIso8601String(),
        'RAC_TIME_END': race.endDate.toIso8601String(),
        'RAC_TYPE': race.type,
        'RAC_DIFFICULTY': race.difficulty,
        'RAC_MIN_PARTICIPANTS': race.minParticipants,
        'RAC_MAX_PARTICIPANTS': race.maxParticipants,
        'RAC_MIN_TEAMS': race.minTeams,
        'RAC_MAX_TEAMS': race.maxTeams,
        'RAC_TEAM_MEMBERS': race.teamMembers,
        'RAC_AGE_MIN': race.ageMin,
        'RAC_AGE_MIDDLE': race.ageMiddle,
        'RAC_AGE_MAX': race.ageMax,
      };

      final response = await client.put(
        Uri.parse('$baseUrl/races/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return Race.fromJson(responseData['data'] ?? responseData);
      } else {
        throw Exception('Erreur mise à jour: ${response.statusCode} - ${response.body}');
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
