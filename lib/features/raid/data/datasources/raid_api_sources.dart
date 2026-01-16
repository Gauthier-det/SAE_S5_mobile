// lib/features/raids/data/datasources/RaidApiSources.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../raid/domain/raid.dart';

class RaidApiSources {
  final String baseUrl;
  final http.Client client;
  String? _authToken; // Token d'authentification

  RaidApiSources({required this.baseUrl, http.Client? client})
    : client = client ?? http.Client();

  /// Définir le token d'authentification
  void setAuthToken(String? token) {
    _authToken = token;
  }

  Future<Raid?> getRaidById(int id) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/raids/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        // Laravel wraps response in {data: {...}}
        final raidData = responseData['data'];
        return Raid.fromJson(raidData);
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
      final response = await client.get(
        Uri.parse('$baseUrl/raids'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        // Laravel wraps response in {data: [...]}
        final List<dynamic> raidsList = responseData['data'];
        return raidsList.map((json) => Raid.fromJson(json)).toList();
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Raid> createRaid(Raid raid) async {
    try {
      // 1. Préparer les données en JSON pour l'API
      final body = json.encode(raid.toApiJson());

      // 2. Préparer les headers avec authentification
      final headers = {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

      // 3. Envoyer une requête POST
      final response = await client.post(
        Uri.parse('$baseUrl/raids'), // Endpoint API
        headers: headers,
        body: body, // Les données du raid en JSON
      );

      // 3. Vérifier le code de statut HTTP
      if (response.statusCode == 201 || response.statusCode == 200) {
        // 201 Created ou 200 OK = succès
        final responseData = json.decode(response.body);
        // Laravel wraps response in {data: {...}}
        final raidData = responseData['data'];
        return Raid.fromJson(
          raidData,
        ); // Retourne le raid créé (avec l'ID généré par le serveur)
      } else if (response.statusCode == 400) {
        // 400 Bad Request = données invalides
        throw Exception('Données invalides : ${response.body}');
      } else if (response.statusCode == 401) {
        // 401 Unauthorized = pas authentifié
        throw Exception('Non authentifié - Token invalide ou manquant');
      } else if (response.statusCode == 302) {
        // 302 Found = redirection (Laravel redirige car pas authentifié)
        throw Exception(
          'Non authentifié - Vous devez être connecté via l\'API pour créer un raid',
        );
      } else if (response.statusCode == 403) {
        // 403 Forbidden = pas les droits
        throw Exception(
          'Accès refusé - Vous n\'avez pas les droits pour créer ce raid',
        );
      } else if (response.statusCode == 422) {
        // 422 Unprocessable Entity = validation failed
        final errorData = json.decode(response.body);
        throw Exception(
          'Erreur de validation : ${errorData['errors'] ?? response.body}',
        );
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
        final responseData = json.decode(response.body);
        // Laravel wraps response in {data: {...}}
        final raidData = responseData['data'];
        return Raid.fromJson(raidData);
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
