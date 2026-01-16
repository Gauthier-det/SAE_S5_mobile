import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../team/domain/team.dart';
import '../../../user/domain/user.dart';

/// Data source for team API operations.
/// Handles all HTTP requests related to team management, registration, and race interactions.
class TeamApiSources {
  final String baseUrl;
  final http.Client client;
  String? _authToken;

  /// Creates a TeamApiSources instance.
  TeamApiSources({required this.baseUrl, http.Client? client})
    : client = client ?? http.Client();

  /// Sets the authentication token for API requests.
  void setAuthToken(String? token) {
    _authToken = token;
  }

  /// Returns the HTTP headers with authentication token if available.
  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  /// Retrieves race details for the given race ID.
  Future<Map<String, dynamic>> getRaceDetails(int raceId) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/races/$raceId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['data'] as Map<String, dynamic>;
      } else if (response.statusCode == 404) {
        throw Exception('Course non trouvée');
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  /// Retrieves available users for a given race.
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

  /// Creates a new team with the provided team data.
  /// Returns the ID of the newly created team.
  Future<int> createTeam(Map<String, dynamic> teamData) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/teams'),
        headers: _headers,
        body: json.encode(teamData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['data'] == null) {
          throw Exception('Invalid API response: "data" field missing');
        }

        final data = responseData['data'];
        final teamId = data is Map ? (data['team_id'] ?? data['id']) : null;

        if (teamId == null) {
          if (responseData['team_id'] != null) {
            return responseData['team_id'] as int;
          }

          throw Exception('ID d\'équipe manquant dans la réponse');
        }
        return teamId as int;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Invalid or missing token');
      } else if (response.statusCode == 422) {
        try {
          final errorData = json.decode(response.body);
          final errors =
              errorData['errors'] ?? errorData['message'] ?? response.body;
          throw Exception('Validation error: $errors');
        } catch (e) {
          throw Exception(
            'Validation error: ${response.body.substring(0, 100)}',
          );
        }
      } else {
        throw Exception(
          'API Error ${response.statusCode}: ${response.body.substring(0, 100)}',
        );
      }
    } catch (e) {
      throw Exception('Error creating team: $e');
    }
  }

  /// Adds a member to a team.
  Future<void> addMemberToTeam(Map<String, dynamic> data) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/teams/addMember'),
        headers: _headers,
        body: json.encode(data),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        try {
          final errorData = json.decode(response.body);
          throw Exception(
            errorData['message'] ?? 'Error adding member',
          );
        } catch (e) {
          throw Exception('Error ${response.statusCode}');
        }
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Registers a team for a race.
  Future<void> registerTeamToRace(int teamId, int raceId) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/teams/$teamId/register-race'),
        headers: _headers,
        body: json.encode({'race_id': raceId}),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ?? 'Error registering team for race',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Retrieves complete team and race details.
  Future<Map<String, dynamic>> getTeamRaceDetails(
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
        return responseData as Map<String, dynamic>;
      } else if (response.statusCode == 404) {
        throw Exception('Team or race not found');
      } else if (response.statusCode == 403) {
        throw Exception('Access denied to this team');
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Removes a member from a team for a specific race.
  Future<void> removeMemberFromTeamRace(
    int teamId,
    int raceId,
    int userId,
  ) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/teams/member/remove'),
        headers: _headers,
        body: json.encode({
          'team_id': teamId,
          'race_id': raceId,
          'user_id': userId,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ?? 'Error removing member',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Updates member information for a race (chip number, PPS form).
  Future<void> updateMemberRaceInfo(
    int teamId,
    int raceId,
    int userId,
    String? chipNumber,
    String? ppsForm,
  ) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/teams/member/update-info'),
        headers: _headers,
        body: json.encode({
          'team_id': teamId,
          'race_id': raceId,
          'user_id': userId,
          if (chipNumber != null && chipNumber.isNotEmpty)
            'chip_number': chipNumber,
          if (ppsForm != null && ppsForm.isNotEmpty) 'pps': ppsForm,
        }),
      );

      if (response.statusCode != 200) {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ?? 'Error updating member',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Validates a team for a race.
  Future<void> validateTeamForRace(int teamId, int raceId) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/teams/validate-race'),
        headers: _headers,
        body: json.encode({'team_id': teamId, 'race_id': raceId}),
      );

      if (response.statusCode != 200) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Error validating team');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Invalidates a team for a race.
  Future<void> unvalidateTeamForRace(int teamId, int raceId) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/teams/unvalidate-race'),
        headers: _headers,
        body: json.encode({'team_id': teamId, 'race_id': raceId}),
      );

      if (response.statusCode != 200) {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ?? 'Error invalidating team',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Retrieves teams for a specific race.
  Future<List<Team>> getRaceTeams(int raceId) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/races/$raceId/details'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['data'] != null &&
            responseData['data']['teams_list'] != null) {
          final List<dynamic> teamsList = responseData['data']['teams_list'];
          return teamsList.map((teamJson) {
            if (teamJson['responsible'] != null &&
                teamJson['responsible'] is Map) {
              teamJson['manager_id'] = teamJson['responsible']['id'];
            }
            return Team.fromJson(teamJson);
          }).toList();
        }

        if (responseData['data'] is List) {
          final List<dynamic> list = responseData['data'];
          return list.map((json) => Team.fromJson(json)).toList();
        }

        return [];
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // ===================================
  // DELETE TEAM
  // ===================================

  /// DELETE /races/{raceId}/teams/{teamId}
  Future<void> deleteTeamFromRace(int teamId, int raceId) async {
    try {
      final response = await client.delete(
        Uri.parse('$baseUrl/races/$raceId/teams/$teamId'),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ?? 'Erreur lors de la suppression de l\'équipe',
        );
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  /// GET /teams/{teamId} - Récupérer une équipe par ID (sans détails course)
  Future<Team?> getTeamById(int teamId) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/teams/$teamId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return Team.fromJson(responseData['data']);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }
}
