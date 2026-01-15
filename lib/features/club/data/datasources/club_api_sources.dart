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
    print('🏢 ClubApiSources.getClubs - Start');
    print('🏢 ClubApiSources.getClubs - Token present: ${_authToken != null}');

    try {
      final headers = {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

      final url = '$baseUrl/clubs';
      print('🏢 ClubApiSources.getClubs - URL: $url');

      final response = await client.get(Uri.parse(url), headers: headers);

      print(
        '🏢 ClubApiSources.getClubs - Response status: ${response.statusCode}',
      );
      print('🏢 ClubApiSources.getClubs - Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> clubsJson = responseData['data'] ?? responseData;
        print('✅ ClubApiSources.getClubs - Found ${clubsJson.length} clubs');
        return clubsJson.map((json) => Club.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Non authentifié - Token invalide ou manquant');
      } else {
        throw Exception('Failed to fetch clubs: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ ClubApiSources.getClubs - Error: $e');
      throw Exception('Network error: $e');
    }
  }

  /// Gets a club by ID from the API
  Future<Club?> getClubById(int id) async {
    print('🏢 ClubApiSources.getClubById - Start, ID: $id');

    try {
      final headers = {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

      final url = '$baseUrl/clubs/$id';
      print('🏢 ClubApiSources.getClubById - URL: $url');

      final response = await client.get(Uri.parse(url), headers: headers);

      print(
        '🏢 ClubApiSources.getClubById - Response status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final clubJson = responseData['data'] ?? responseData;
        print('✅ ClubApiSources.getClubById - Success');
        return Club.fromJson(clubJson);
      } else if (response.statusCode == 404) {
        return null;
      } else if (response.statusCode == 401) {
        throw Exception('Non authentifié - Token invalide ou manquant');
      } else {
        throw Exception('Failed to fetch club: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ ClubApiSources.getClubById - Error: $e');
      throw Exception('Network error: $e');
    }
  }

  /// Gets members of a club from the API
  Future<List<User>> getClubMembers(int clubId) async {
    print('🏢 ClubApiSources.getClubMembers - Start, Club ID: $clubId');

    try {
      final headers = {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

      final url = '$baseUrl/clubs/$clubId/users';
      print('🏢 ClubApiSources.getClubMembers - URL: $url');

      final response = await client.get(Uri.parse(url), headers: headers);

      print(
        '🏢 ClubApiSources.getClubMembers - Response status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> membersJson = responseData['data'] ?? responseData;
        print(
          '✅ ClubApiSources.getClubMembers - Found ${membersJson.length} members',
        );
        return membersJson.map((json) => User.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Non authentifié - Token invalide ou manquant');
      } else {
        throw Exception('Failed to fetch club members: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ ClubApiSources.getClubMembers - Error: $e');
      throw Exception('Network error: $e');
    }
  }

  /// Creates a new club via API
  Future<Club> createClub({
    required String name,
    required int responsibleId,
    required int addressId,
  }) async {
    print('🏢 ClubApiSources.createClub - Start');
    print(
      '🏢 ClubApiSources.createClub - Name: $name, ResponsibleId: $responsibleId, AddressId: $addressId',
    );

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

      print('🏢 ClubApiSources.createClub - Body: $body');

      final response = await client.post(
        Uri.parse('$baseUrl/clubs'),
        headers: headers,
        body: body,
      );

      print(
        '🏢 ClubApiSources.createClub - Response status: ${response.statusCode}',
      );
      print('🏢 ClubApiSources.createClub - Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final clubJson = responseData['data'] ?? responseData;
        print('✅ ClubApiSources.createClub - Success');
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
      print('❌ ClubApiSources.createClub - Error: $e');
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
    print('🏢 ClubApiSources.updateClub - Start, ID: $id');

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
      print('🏢 ClubApiSources.updateClub - Body: $body');

      final response = await client.put(
        Uri.parse('$baseUrl/clubs/$id'),
        headers: headers,
        body: body,
      );

      print(
        '🏢 ClubApiSources.updateClub - Response status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final clubJson = responseData['data'] ?? responseData;
        print('✅ ClubApiSources.updateClub - Success');
        return Club.fromJson(clubJson);
      } else if (response.statusCode == 401) {
        throw Exception('Non authentifié');
      } else if (response.statusCode == 403) {
        throw Exception('Accès refusé - Droits admin requis');
      } else {
        throw Exception('Failed to update club: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ ClubApiSources.updateClub - Error: $e');
      throw Exception('Network error: $e');
    }
  }

  /// Deletes a club via API
  Future<void> deleteClub(int id) async {
    print('🏢 ClubApiSources.deleteClub - Start, ID: $id');

    try {
      final headers = {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

      final response = await client.delete(
        Uri.parse('$baseUrl/clubs/$id'),
        headers: headers,
      );

      print(
        '🏢 ClubApiSources.deleteClub - Response status: ${response.statusCode}',
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ ClubApiSources.deleteClub - Success');
      } else if (response.statusCode == 401) {
        throw Exception('Non authentifié');
      } else if (response.statusCode == 403) {
        throw Exception('Accès refusé - Droits admin requis');
      } else {
        throw Exception('Failed to delete club: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ ClubApiSources.deleteClub - Error: $e');
      throw Exception('Network error: $e');
    }
  }
}
