// lib/features/club/data/datasources/club_api_sources.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/club.dart';
import '../../../user/domain/user.dart';

class ClubApiSources {
  final String baseUrl;
  final http.Client client;
  String? _authToken;

  ClubApiSources({required this.baseUrl, http.Client? client})
    : client = client ?? http.Client();

  /// Sets the authentication token for API requests
  void setAuthToken(String? token) {
    _authToken = token;
  }

  /// Gets all clubs from the API
  Future<List<Club>> getClubs() async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

      final url = '$baseUrl/clubs';

      final response = await client.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> clubsJson = responseData['data'] ?? responseData;
        return clubsJson.map((json) => Club.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Non authentifié - Token invalide ou manquant');
      } else {
        throw Exception('Failed to fetch clubs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Gets a club by ID from the API
  Future<Club?> getClubById(int id) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

      final url = '$baseUrl/clubs/$id';

      final response = await client.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final clubJson = responseData['data'] ?? responseData;

        return Club.fromJson(clubJson);
      } else if (response.statusCode == 404) {
        return null;
      } else if (response.statusCode == 401) {
        throw Exception('Non authentifié - Token invalide ou manquant');
      } else {
        throw Exception('Failed to fetch club: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Gets members of a club from the API
  Future<List<User>> getClubMembers(int clubId) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

      final url = '$baseUrl/clubs/$clubId/users';

      final response = await client.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> membersJson = responseData['data'] ?? responseData;

        return membersJson.map((json) => User.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Non authentifié - Token invalide ou manquant');
      } else {
        throw Exception('Failed to fetch club members: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Creates a new club via API
  Future<Club> createClub({
    required String name,
    required int responsibleId,
    required int addressId,
  }) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

      final body = json.encode({
        'CLU_NAME': name,
        'USE_ID': responsibleId,
        'ADD_ID': addressId,
      });

      final response = await client.post(
        Uri.parse('$baseUrl/clubs'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final clubJson = responseData['data'] ?? responseData;

        return Club.fromJson(clubJson);
      } else if (response.statusCode == 401) {
        throw Exception('Non authentifié - Token invalide ou manquant');
      } else if (response.statusCode == 403) {
        throw Exception('Accès refusé - Droits admin requis');
      } else if (response.statusCode == 422) {
        final errorData = json.decode(response.body);
        throw Exception(
          'Erreur de validation: ${errorData['errors'] ?? response.body}',
        );
      } else {
        throw Exception('Failed to create club: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Updates an existing club via API
  Future<Club> updateClub({
    required int id,
    String? name,
    int? responsibleId,
    int? addressId,
  }) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

      final bodyMap = <String, dynamic>{};
      if (name != null) bodyMap['CLU_NAME'] = name;
      if (responsibleId != null) bodyMap['USE_ID'] = responsibleId;
      if (addressId != null) bodyMap['ADD_ID'] = addressId;

      final body = json.encode(bodyMap);

      final response = await client.put(
        Uri.parse('$baseUrl/clubs/$id'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final clubJson = responseData['data'] ?? responseData;

        return Club.fromJson(clubJson);
      } else if (response.statusCode == 401) {
        throw Exception('Non authentifié');
      } else if (response.statusCode == 403) {
        throw Exception('Accès refusé - Droits admin requis');
      } else {
        throw Exception('Failed to update club: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Deletes a club via API
  Future<void> deleteClub(int id) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

      final response = await client.delete(
        Uri.parse('$baseUrl/clubs/$id'),
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
      } else if (response.statusCode == 401) {
        throw Exception('Non authentifié');
      } else if (response.statusCode == 403) {
        throw Exception('Accès refusé - Droits admin requis');
      } else {
        throw Exception('Failed to delete club: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
