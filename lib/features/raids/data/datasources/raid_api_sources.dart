// lib/features/raids/data/datasources/RaidApiSources.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../domain/raid.dart';

class RaidApiSources {
  final String baseUrl;
  final http.Client client;

  RaidApiSources({required this.baseUrl, http.Client? client})
    : client = client ?? http.Client();

  Future<Raid?> getRaidById(int id) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/raids/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final data = responseBody['data'];
        return Raid.fromJson(data);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<List<Raid>> getAllRaids() async {
    try {
      print('🔍 Fetching raids from: $baseUrl/raids');
      final response = await client.get(
        Uri.parse('$baseUrl/raids'),
        headers: {'Content-Type': 'application/json'},
      );

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final List<dynamic> data = responseBody['data'] ?? [];
        print('✅ Parsed ${data.length} raids');
        return data.map((json) => Raid.fromJson(json)).toList();
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('❌ Error fetching raids: $e');
      print('📚 Stack trace: $stackTrace');
      throw Exception('Network error: $e');
    }
  }

  Future<Raid> createRaid(Raid raid) async {
    try {
      // 1. Préparer les données en JSON
      final body = json.encode(raid.toJson());

      // 2. Envoyer une requête POST
      final response = await client.post(
        Uri.parse('$baseUrl/raids'), // Endpoint API
        headers: {
          'Content-Type':
              'application/json', // Important : spécifie que c'est du JSON
        },
        body: body, // Les données du raid en JSON
      );

      // 3. Vérifier le code de statut HTTP
      if (response.statusCode == 201 || response.statusCode == 200) {
        // 201 Created ou 200 OK = succès
        final data = json.decode(response.body);
        return Raid.fromJson(
          data,
        ); // Retourne le raid créé (avec l'ID généré par le serveur)
      } else if (response.statusCode == 400) {
        // 400 Bad Request = données invalides
        throw Exception('Données invalides : ${response.body}');
      } else if (response.statusCode == 401) {
        // 401 Unauthorized = pas authentifié
        throw Exception('Non authentifié');
      } else {
        // Autre erreur
        throw Exception('Erreur serveur : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Updates an existing raid via PUT request
  Future<Raid> updateRaid(int id, Raid raid) async {
    try {
      final body = json.encode(raid.toJson());

      final response = await client.put(
        Uri.parse('$baseUrl/raids/$id'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Raid.fromJson(data);
      } else {
        throw Exception('Failed to update raid: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Deletes a raid via DELETE request
  Future<void> deleteRaid(int id) async {
    try {
      final response = await client.delete(
        Uri.parse('$baseUrl/raids/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete raid: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
