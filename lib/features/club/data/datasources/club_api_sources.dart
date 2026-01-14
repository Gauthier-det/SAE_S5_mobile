// lib/features/club/data/datasources/club_api_sources.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../domain/club.dart';

class ClubApiSources {
  final String baseUrl;
  final http.Client client;

  ClubApiSources({required this.baseUrl, http.Client? client})
    : client = client ?? http.Client();

  /// GET /clubs - Récupérer tous les clubs
  Future<List<Club>> getAllClubs() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/clubs'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Club.fromJson(json)).toList();
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  /// GET /clubs/{id} - Récupérer un club par ID
  Future<Club?> getClubById(int id) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/clubs/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return Club.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  /// POST /clubs - Créer un nouveau club
  Future<Club> createClub(Club club) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/clubs'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(club.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Club.fromJson(json.decode(response.body));
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

  /// PUT /clubs/{id} - Mettre à jour un club
  Future<Club> updateClub(int id, Club club) async {
    try {
      final response = await client.put(
        Uri.parse('$baseUrl/clubs/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(club.toJson()),
      );

      if (response.statusCode == 200) {
        return Club.fromJson(json.decode(response.body));
      } else {
        throw Exception('Erreur mise à jour: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  /// DELETE /clubs/{id} - Supprimer un club
  Future<void> deleteClub(int id) async {
    try {
      final response = await client.delete(
        Uri.parse('$baseUrl/clubs/$id'),
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

  /// GET /clubs/{clubId}/members - Récupérer les membres d'un club
  Future<List<dynamic>> getClubMembers(int clubId) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/clubs/$clubId/members'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }
}
