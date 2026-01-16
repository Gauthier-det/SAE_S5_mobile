// lib/features/raids/data/datasources/RaidApiSources.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../raid/domain/raid.dart';

/// REST API client for raid endpoints.
///
/// Handles CRUD operations with Laravel API that wraps responses in
/// `{data: {...}}` or `{data: [...]}` format. Supports token-based
/// authentication via [setAuthToken] [web:138][web:186].
///
/// **Error Codes:**
/// - 200/201: Success
/// - 400: Invalid data
/// - 401/302: Unauthorized
/// - 403: Forbidden
/// - 404: Not found
/// - 422: Validation error
///
/// Example:
/// ```dart
/// final apiSource = RaidApiSources(
///   baseUrl: 'https://api.example.com',
/// );
/// apiSource.setAuthToken('your-token');
/// final raids = await apiSource.getAllRaids();
/// ```
class RaidApiSources {
  final String baseUrl;
  final http.Client client;
  String? _authToken;

  RaidApiSources({required this.baseUrl, http.Client? client})
      : client = client ?? http.Client();

  /// Sets authentication token for protected endpoints [web:138].
  void setAuthToken(String? token) {
    _authToken = token;
  }

  /// Fetches single raid by ID.
  ///
  /// Returns null if raid not found (404).
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

  /// Fetches all raids.
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

  /// Creates new raid via POST.
  ///
  /// Requires authentication token. Returns created raid with server-generated ID.
  Future<Raid> createRaid(Raid raid) async {
    try {
      final body = json.encode(raid.toApiJson());

      final headers = {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

      final response = await client.post(
        Uri.parse('$baseUrl/raids'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = json.decode(response.body);
        // Laravel wraps response in {data: {...}}
        final raidData = responseData['data'];
        return Raid.fromJson(raidData);
      } else if (response.statusCode == 400) {
        throw Exception('Données invalides : ${response.body}');
      } else if (response.statusCode == 401) {
        throw Exception('Non authentifié - Token invalide ou manquant');
      } else if (response.statusCode == 302) {
        throw Exception(
          'Non authentifié - Vous devez être connecté via l\'API pour créer un raid',
        );
      } else if (response.statusCode == 403) {
        throw Exception(
          'Accès refusé - Vous n\'avez pas les droits pour créer ce raid',
        );
      } else if (response.statusCode == 422) {
        final errorData = json.decode(response.body);
        throw Exception(
          'Erreur de validation : ${errorData['errors'] ?? response.body}',
        );
      } else {
        throw Exception('Erreur serveur : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Updates existing raid via PUT.
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

  /// Deletes raid via DELETE.
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
