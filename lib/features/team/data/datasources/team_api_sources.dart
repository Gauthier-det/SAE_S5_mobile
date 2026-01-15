// lib/features/teams/data/datasources/team_api_sources.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
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

  /// Headers avec authentification
  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  /// Headers requis pour routes authentifiées
  Map<String, String> get _authHeaders {
    if (_authToken == null || _authToken!.isEmpty) {
      throw Exception('Authentication required - No token available');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_authToken',
    };
  }

  /// Valide que la réponse est bien du JSON
  void _validateJsonResponse(http.Response response, String endpoint) {
    final contentType = response.headers['content-type'];
    if (contentType == null || !contentType.contains('application/json')) {
      final preview = response.body.length > 200 
          ? response.body.substring(0, 200) 
          : response.body;
      throw Exception(
        'Expected JSON but got ${contentType ?? "unknown"} from $endpoint. '
        'Status: ${response.statusCode}. Preview: $preview'
      );
    }
  }

  /// Décode la réponse JSON avec gestion d'erreur
  dynamic _decodeResponse(http.Response response, String endpoint) {
    try {
      return json.decode(response.body);
    } catch (e) {
      throw Exception(
        'Failed to decode JSON from $endpoint: $e. '
        'Body: ${response.body.substring(0, min(100, response.body.length))}'
      );
    }
  }

  // ============================================
  // PUBLIC ROUTES (No auth required)
  // ============================================

  // Note: Based on routes/api.php, most team routes require auth
  // Only race/raid routes are public

  // ============================================
  // AUTHENTICATED ROUTES
  // ============================================

  /// GET /races/{raceId}/teams - Équipes d'une course
  /// Requires: auth:sanctum
  Future<List<Team>> getRaceTeams(int raceId) async {
    final endpoint = '/races/$raceId/teams';
    try {
      final response = await client.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _authHeaders,
      );

      _validateJsonResponse(response, endpoint);

      if (response.statusCode == 200) {
        final responseData = _decodeResponse(response, endpoint);
        final List<dynamic> teamsList = responseData['data'];
        return teamsList.map((json) => Team.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        return [];
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Invalid or expired token');
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error on $endpoint: $e');
    }
  }

  /// GET /teams/{id} - Récupérer une équipe par ID
  /// Requires: auth:sanctum
  Future<Team?> getTeamById(int teamId) async {
    final endpoint = '/teams/$teamId';
    try {
      final response = await client.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _authHeaders,
      );

      _validateJsonResponse(response, endpoint);

      if (response.statusCode == 200) {
        final responseData = _decodeResponse(response, endpoint);
        final teamData = responseData['data'];
        return Team.fromJson(teamData);
      } else if (response.statusCode == 404) {
        return null;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Invalid or expired token');
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error on $endpoint: $e');
    }
  }

  /// GET /teams/{teamId}/races/{raceId} - Détails équipe pour une course
  /// Requires: auth:sanctum
  /// Laravel Route: TeamController@getTeamRaceDetails
  Future<Team?> getTeamByIdWithRaceStatus(int teamId, int raceId) async {
    final endpoint = '/teams/$teamId/races/$raceId';
    try {
      final response = await client.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _authHeaders,
      );

      _validateJsonResponse(response, endpoint);

      if (response.statusCode == 200) {
        final responseData = _decodeResponse(response, endpoint);
        final teamData = responseData['data'];
        return Team.fromJson(teamData);
      } else if (response.statusCode == 404) {
        return null;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Invalid or expired token');
      } else if (response.statusCode == 403) {
        throw Exception('Forbidden - No access to this team');
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error on $endpoint: $e');
    }
  }

  /// POST /teams - Créer une équipe
  /// Requires: auth:sanctum
  /// Laravel Route: TeamController@createTeam
  Future<int> createTeam(Map<String, dynamic> teamData) async {
    final endpoint = '/teams';
    try {
      final response = await client.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _authHeaders,
        body: json.encode(teamData),
      );

      _validateJsonResponse(response, endpoint);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = _decodeResponse(response, endpoint);
        final teamId = responseData['data']['TEA_ID'] ?? 
                       responseData['data']['id'];
        return teamId as int;
      } else if (response.statusCode == 401) {
        throw Exception('Non authentifié - Token invalide ou manquant');
      } else if (response.statusCode == 422) {
        final errorData = _decodeResponse(response, endpoint);
        throw Exception(
          'Erreur de validation : ${errorData['errors'] ?? errorData['message'] ?? response.body}',
        );
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error on $endpoint: $e');
    }
  }

  /// POST /teams/addMember - Ajouter un membre à une équipe
  /// Requires: auth:sanctum
  /// Laravel Route: TeamController@addMember
  /// Body: {TEA_ID, USE_ID}
  Future<void> addTeamMember(int teamId, int userId) async {
    final endpoint = '/teams/addMember';
    try {
      final response = await client.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _authHeaders,
        body: json.encode({
          'TEA_ID': teamId,
          'USE_ID': userId,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        _validateJsonResponse(response, endpoint);
        throw Exception('Failed to add member: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error on $endpoint: $e');
    }
  }

  /// POST /teams/{teamId}/register-race - Inscrire équipe à une course
  /// Requires: auth:sanctum
  /// Laravel Route: TeamController@registerTeamToRace
  /// Body: {RAC_ID}
  Future<void> registerTeamToRace(int teamId, int raceId) async {
    final endpoint = '/teams/$teamId/register-race';
    try {
      final response = await client.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _authHeaders,
        body: json.encode({'RAC_ID': raceId}),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        _validateJsonResponse(response, endpoint);
        throw Exception('Failed to register team: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error on $endpoint: $e');
    }
  }

  /// POST /users/races/register - Inscrire un utilisateur à une course
  /// Requires: auth:sanctum
  /// Laravel Route: UserController@registerUserToRace
  /// Body: {USE_ID, RAC_ID}
  /// Creates entry in SAN_USERS_RACES
  Future<void> registerUserToRace(int userId, int raceId) async {
    final endpoint = '/users/races/register';
    try {
      final response = await client.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _authHeaders,
        body: json.encode({
          'USE_ID': userId,
          'RAC_ID': raceId,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        _validateJsonResponse(response, endpoint);
        throw Exception('Failed to register user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error on $endpoint: $e');
    }
  }

  /// GET /races/{raceId}/available-users - Utilisateurs disponibles
  /// Requires: auth:sanctum
  /// Laravel Route: TeamController@getAvailableUsersForRace
  Future<List<User>> getAvailableUsersForRace(int raceId) async {
    final endpoint = '/races/$raceId/available-users';
    try {
      print('🌐 Calling: $baseUrl$endpoint');
      print('🔑 Token: ${_authToken?.substring(0, min(20, _authToken!.length))}...');
      
      final response = await client.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _authHeaders,
      );

      print('📊 Status: ${response.statusCode}');
      print('📋 Content-Type: ${response.headers['content-type']}');

      _validateJsonResponse(response, endpoint);

      if (response.statusCode == 200) {
        final responseData = _decodeResponse(response, endpoint);
        print('✅ Decoded successfully');
        
        final List<dynamic> usersList = responseData['data'];
        return usersList.map((json) => User.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Invalid or expired token');
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Full error: $e');
      throw Exception('Network error on $endpoint: $e');
    }
  }

  /// GET /teams/{teamId}/users - Membres d'une équipe
  /// Requires: auth:sanctum
  /// Laravel Route: UserController@getUsersByTeam
  Future<List<User>> getTeamMembers(int teamId) async {
    final endpoint = '/teams/$teamId/users';
    try {
      final response = await client.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _authHeaders,
      );

      _validateJsonResponse(response, endpoint);

      if (response.statusCode == 200) {
        final responseData = _decodeResponse(response, endpoint);
        final List<dynamic> usersList = responseData['data'];
        return usersList.map((json) => User.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Invalid or expired token');
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error on $endpoint: $e');
    }
  }

  /// POST /teams/validate-race - Valider une équipe pour une course
  /// Requires: auth:sanctum
  /// Laravel Route: TeamController@validateTeamForRace
  /// Body: {TEA_ID, RAC_ID}
  Future<void> validateTeamForRace(int teamId, int raceId) async {
    final endpoint = '/teams/validate-race';
    try {
      final response = await client.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _authHeaders,
        body: json.encode({
          'TEA_ID': teamId,
          'RAC_ID': raceId,
        }),
      );

      if (response.statusCode != 200) {
        _validateJsonResponse(response, endpoint);
        throw Exception('Failed to validate team: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error on $endpoint: $e');
    }
  }

  /// POST /teams/unvalidate-race - Invalider une équipe
  /// Requires: auth:sanctum
  /// Laravel Route: TeamController@unvalidateTeamForRace
  /// Body: {TEA_ID, RAC_ID}
  Future<void> invalidateTeamForRace(int teamId, int raceId) async {
    final endpoint = '/teams/unvalidate-race';
    try {
      final response = await client.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _authHeaders,
        body: json.encode({
          'TEA_ID': teamId,
          'RAC_ID': raceId,
        }),
      );

      if (response.statusCode != 200) {
        _validateJsonResponse(response, endpoint);
        throw Exception('Failed to invalidate team: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error on $endpoint: $e');
    }
  }

  /// Vérifier accès aux détails d'une équipe
  /// Uses: GET /teams/{teamId}/races/{raceId}
  /// Returns true if user has access (200), false otherwise (403/404)
  Future<bool> canAccessTeamDetail({
    required int teamId,
    required int raceId,
    required int userId,
  }) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/teams/$teamId/races/$raceId'),
        headers: _authHeaders,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Récupérer le numéro de dossard d'une équipe
  /// Uses: GET /teams/{teamId}/races/{raceId}
  /// Returns TER_RACE_NUMBER from response
  Future<int?> getTeamDossardNumber(int teamId, int raceId) async {
    final endpoint = '/teams/$teamId/races/$raceId';
    try {
      final response = await client.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _authHeaders,
      );

      _validateJsonResponse(response, endpoint);

      if (response.statusCode == 200) {
        final responseData = _decodeResponse(response, endpoint);
        return responseData['data']['TER_RACE_NUMBER'] as int?;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Récupérer les membres avec détails de course
  /// Uses: GET /teams/{teamId}/races/{raceId}
  /// Returns members array from response
  Future<List<Map<String, dynamic>>> getTeamMembersWithRaceDetails(
    int teamId,
    int raceId,
  ) async {
    final endpoint = '/teams/$teamId/races/$raceId';
    try {
      final response = await client.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _authHeaders,
      );

      _validateJsonResponse(response, endpoint);

      if (response.statusCode == 200) {
        final responseData = _decodeResponse(response, endpoint);
        final members = responseData['data']['members'] as List<dynamic>?;
        return members?.map((e) => e as Map<String, dynamic>).toList() ?? [];
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Network error on $endpoint: $e');
    }
  }

  /// POST /teams/member/remove - Retirer un membre
  /// Requires: auth:sanctum
  /// Laravel Route: TeamController@removeMember
  /// Body: {TEA_ID, USE_ID}
  Future<void> removeMemberFromTeam(int teamId, int userId) async {
    final endpoint = '/teams/member/remove';
    try {
      final response = await client.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _authHeaders,
        body: json.encode({
          'TEA_ID': teamId,
          'USE_ID': userId,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        _validateJsonResponse(response, endpoint);
        throw Exception('Failed to remove member: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error on $endpoint: $e');
    }
  }

  /// Supprimer une équipe
  /// ⚠️ NOT IMPLEMENTED in Laravel API
  /// TODO: Create DELETE /teams/{teamId} route in Laravel
  Future<void> deleteTeam(int teamId, int raceId) async {
    throw UnimplementedError(
      'DELETE /teams/{teamId} route not implemented in Laravel API',
    );
  }

  /// POST /teams/member/update-info - Mettre à jour PPS d'un membre
  /// Requires: auth:sanctum
  /// Laravel Route: TeamController@updateMemberRaceInfo
  /// Body: {USE_ID, RAC_ID, USR_PPS_FORM}
  Future<void> updateUserPPS(int userId, String? ppsForm, int raceId) async {
    final endpoint = '/teams/member/update-info';
    try {
      final response = await client.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _authHeaders,
        body: json.encode({
          'USE_ID': userId,
          'RAC_ID': raceId,
          'USR_PPS_FORM': ppsForm,
        }),
      );

      if (response.statusCode != 200) {
        _validateJsonResponse(response, endpoint);
        throw Exception('Failed to update PPS: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error on $endpoint: $e');
    }
  }

  /// POST /teams/member/update-info - Mettre à jour numéro de puce
  /// Requires: auth:sanctum
  /// Laravel Route: TeamController@updateMemberRaceInfo
  /// Body: {USE_ID, RAC_ID, USR_CHIP_NUMBER}
  Future<void> updateUserChipNumber(int userId, int raceId, int? chipNumber) async {
    final endpoint = '/teams/member/update-info';
    try {
      final response = await client.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _authHeaders,
        body: json.encode({
          'USE_ID': userId,
          'RAC_ID': raceId,
          'USR_CHIP_NUMBER': chipNumber,
        }),
      );

      if (response.statusCode != 200) {
        _validateJsonResponse(response, endpoint);
        throw Exception('Failed to update chip: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error on $endpoint: $e');
    }
  }

  /// Créer une équipe ET l'inscrire à une course (flow complet)
  /// Uses multiple endpoints in sequence:
  /// 1. POST /teams
  /// 2. POST /teams/addMember (for each member)
  /// 3. POST /teams/{teamId}/register-race
  /// 4. POST /users/races/register (for each member)
  Future<void> createTeamAndRegisterToRace({
    required Team team,
    required List<int> memberIds,
    required int raceId,
  }) async {
    try {
      // 1. Créer l'équipe
      print('📝 Step 1/4: Creating team...');
      final teamId = await createTeam(team.toApiJson());
      print('✅ Team created with ID: $teamId');

      // 2. Ajouter les membres
      print('👥 Step 2/4: Adding ${memberIds.length} members...');
      for (final userId in memberIds) {
        await addTeamMember(teamId, userId);
        print('  ✅ Added member $userId');
      }

      // 3. Inscrire l'équipe à la course
      print('🏁 Step 3/4: Registering team to race...');
      await registerTeamToRace(teamId, raceId);
      print('✅ Team registered to race');

      // 4. Inscrire chaque membre à la course
      print('👤 Step 4/4: Registering members to race...');
      for (final userId in memberIds) {
        await registerUserToRace(userId, raceId);
        print('  ✅ Registered member $userId');
      }

      print('🎉 Complete flow finished successfully');
    } catch (e) {
      throw Exception('Failed to create and register team: $e');
    }
  }

  /// GET /races/{id} - Détails d'une course
  /// Requires: auth:sanctum (based on routes/api.php structure)
  /// Laravel Route: RaceController@getRaceById
  Future<Map<String, dynamic>?> getRaceDetails(int raceId) async {
    final endpoint = '/races/$raceId';
    try {
      final response = await client.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _authHeaders,
      );

      _validateJsonResponse(response, endpoint);

      if (response.statusCode == 200) {
        final responseData = _decodeResponse(response, endpoint);
        return responseData['data'] as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Network error on $endpoint: $e');
    }
  }

  /// Récupérer les courses en conflit pour un utilisateur
  /// ⚠️ NOT IMPLEMENTED in Laravel API
  /// TODO: Create GET /users/{userId}/races/{raceId}/conflicts route
  Future<List<Map<String, dynamic>>> getUserConflictingRaces(
    int userId,
    int raceId,
  ) async {
    throw UnimplementedError(
      'GET /users/{userId}/races/{raceId}/conflicts not implemented in Laravel API',
    );
  }
}
