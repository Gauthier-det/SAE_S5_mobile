// lib/features/teams/data/datasources/team_api_sources.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../team/domain/team.dart';
import '../../../user/domain/user.dart';

class TeamApiSources {
  final String baseUrl;
  final http.Client client;
  String? _authToken;

  TeamApiSources({required this.baseUrl, http.Client? client})
      : client = client ?? http.Client();

  void setAuthToken(String? token) {
    _authToken = token;
  }

  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  /// GET /races/{raceId}/teams - Équipes d'une course
  Future<List<Team>> getRaceTeams(int raceId) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/races/$raceId/teams'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> teamsList = responseData['data'];
        return teamsList.map((json) => Team.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// GET /teams/{id} - Récupérer une équipe par ID
  Future<Team?> getTeamById(int teamId) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/teams/$teamId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final teamData = responseData['data'];
        return Team.fromJson(teamData);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// GET /teams/{teamId}/races/{raceId} - Détails équipe pour une course
  Future<Team?> getTeamByIdWithRaceStatus(int teamId, int raceId) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/teams/$teamId/races/$raceId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final teamData = responseData['data'];
        return Team.fromJson(teamData);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// POST /teams - Créer une équipe
  Future<int> createTeam(Map<String, dynamic> teamData) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/teams'),
        headers: _headers,
        body: json.encode(teamData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final teamId = responseData['data']['TEA_ID'] ?? responseData['data']['id'];
        return teamId as int;
      } else if (response.statusCode == 401) {
        throw Exception('Non authentifié - Token invalide ou manquant');
      } else if (response.statusCode == 422) {
        final errorData = json.decode(response.body);
        throw Exception(
          'Erreur de validation : ${errorData['errors'] ?? response.body}',
        );
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// POST /teams/addMember - Ajouter un membre à une équipe
  /// ⚠️ ATTENTION: Route non-RESTful, body probablement: {TEA_ID, USE_ID}
  Future<void> addTeamMember(int teamId, int userId) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/teams/addMember'),
        headers: _headers,
        body: json.encode({
          'TEA_ID': teamId,
          'USE_ID': userId,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to add member: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// POST /teams/{teamId}/register-race - Inscrire équipe à une course
  /// ⚠️ Body probablement: {RAC_ID}
  Future<void> registerTeamToRace(int teamId, int raceId) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/teams/$teamId/register-race'),
        headers: _headers,
        body: json.encode({'RAC_ID': raceId}),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to register team: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// POST /users/races/register - Inscrire un utilisateur à une course
  /// ⚠️ Route dans UserController, probablement: {USE_ID, RAC_ID}
  Future<void> registerUserToRace(int userId, int raceId) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/users/races/register'),
        headers: _headers,
        body: json.encode({
          'USE_ID': userId,
          'RAC_ID': raceId,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to register user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// GET /races/{raceId}/available-users - Utilisateurs disponibles
  Future<List<User>> getAvailableUsersForRace(int raceId) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/races/$raceId/available-users'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> usersList = responseData['data'];
        return usersList.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// GET /teams/{teamId}/users - Membres d'une équipe
  Future<List<User>> getTeamMembers(int teamId) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/teams/$teamId/users'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> usersList = responseData['data'];
        return usersList.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// POST /teams/validate-race - Valider une équipe pour une course
  /// ⚠️ Body probablement: {TEA_ID, RAC_ID}
  Future<void> validateTeamForRace(int teamId, int raceId) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/teams/validate-race'),
        headers: _headers,
        body: json.encode({
          'TEA_ID': teamId,
          'RAC_ID': raceId,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to validate team: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// POST /teams/unvalidate-race - Invalider une équipe
  /// ⚠️ Body probablement: {TEA_ID, RAC_ID}
  Future<void> invalidateTeamForRace(int teamId, int raceId) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/teams/unvalidate-race'),
        headers: _headers,
        body: json.encode({
          'TEA_ID': teamId,
          'RAC_ID': raceId,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to invalidate team: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Vérifier accès aux détails - ⚠️ PAS DE ROUTE DÉDIÉE
  /// Doit être géré côté serveur dans getTeamRaceDetails
  Future<bool> canAccessTeamDetail({
    required int teamId,
    required int raceId,
    required int userId,
  }) async {
    try {
      // Tenter de récupérer les détails
      final response = await client.get(
        Uri.parse('$baseUrl/teams/$teamId/races/$raceId'),
        headers: _headers,
      );

      // Si 200 = a accès, si 403/404 = pas d'accès
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Numéro de dossard - ⚠️ Probablement dans getTeamRaceDetails
  Future<int?> getTeamDossardNumber(int teamId, int raceId) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/teams/$teamId/races/$raceId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['data']['TER_RACE_NUMBER'] as int?;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Membres avec détails course - ⚠️ Probablement dans getTeamRaceDetails
  Future<List<Map<String, dynamic>>> getTeamMembersWithRaceDetails(
    int teamId,
    int raceId,
  ) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/teams/$teamId/races/$raceId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final members = responseData['data']['members'] as List<dynamic>?;
        return members?.map((e) => e as Map<String, dynamic>).toList() ?? [];
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// POST /teams/member/remove - Retirer un membre
  /// ⚠️ Body probablement: {TEA_ID, USE_ID}
  Future<void> removeMemberFromTeam(int teamId, int userId) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/teams/member/remove'),
        headers: _headers,
        body: json.encode({
          'TEA_ID': teamId,
          'USE_ID': userId,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to remove member: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Supprimer équipe - ⚠️ PAS DE ROUTE DÉDIÉE
  /// Tu devras créer cette route ou adapter le code
  Future<void> deleteTeam(int teamId, int raceId) async {
    throw UnimplementedError(
      'DELETE /teams/{teamId} route not implemented in Laravel API',
    );
  }

  /// POST /teams/member/update-info - Mettre à jour infos membre
  /// ⚠️ Body probablement: {USE_ID, RAC_ID, USR_PPS_FORM?, USR_CHIP_NUMBER?}
  Future<void> updateUserPPS(int userId, String? ppsForm, int raceId) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/teams/member/update-info'),
        headers: _headers,
        body: json.encode({
          'USE_ID': userId,
          'RAC_ID': raceId,
          'USR_PPS_FORM': ppsForm,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update PPS: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<void> updateUserChipNumber(int userId, int raceId, int? chipNumber) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/teams/member/update-info'),
        headers: _headers,
        body: json.encode({
          'USE_ID': userId,
          'RAC_ID': raceId,
          'USR_CHIP_NUMBER': chipNumber,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update chip: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Créer équipe ET inscrire - ⚠️ PAS DE ROUTE DÉDIÉE
  /// Utilise createTeam + addMember + registerTeamToRace en séquence
  Future<void> createTeamAndRegisterToRace({
    required Team team,
    required List<int> memberIds,
    required int raceId,
  }) async {
    try {
      // 1. Créer l'équipe
      final teamId = await createTeam(team.toApiJson());

      // 2. Ajouter les membres
      for (final userId in memberIds) {
        await addTeamMember(teamId, userId);
      }

      // 3. Inscrire l'équipe à la course
      await registerTeamToRace(teamId, raceId);

      // 4. Inscrire chaque membre à la course
      for (final userId in memberIds) {
        await registerUserToRace(userId, raceId);
      }
    } catch (e) {
      throw Exception('Failed to create and register team: $e');
    }
  }

  /// Détails course - ⚠️ Utilise /races/{id}
  Future<Map<String, dynamic>?> getRaceDetails(int raceId) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/races/$raceId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['data'] as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Courses en conflit - ⚠️ PAS DE ROUTE DÉDIÉE
  Future<List<Map<String, dynamic>>> getUserConflictingRaces(
    int userId,
    int raceId,
  ) async {
    throw UnimplementedError(
      'GET /users/{userId}/races/{raceId}/conflicts not implemented in Laravel API',
    );
  }
}
