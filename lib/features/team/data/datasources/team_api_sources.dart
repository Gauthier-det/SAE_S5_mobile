// lib/features/team/data/datasources/team_api_sources.dart
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
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // ============================================================================
  // TEAM REGISTRATION (TeamRegistration.tsx)
  // ============================================================================

  /// GET /races/{raceId} - Récupérer détails d'une course
  /// Utilisé dans: TeamRegistration (getRaceDetails)
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

  /// GET /races/{raceId}/available-users - Utilisateurs disponibles pour une course
  /// Utilisé dans: TeamRegistration + TeamRaceManagement
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
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  /// POST /teams - Créer une nouvelle équipe
  /// Body: { name: string, image?: string }
  /// Returns: team_id
  Future<int> createTeam(Map<String, dynamic> teamData) async {
    try {
      // ✅ LOG: Vérifier le token et les données

      final response = await client.post(
        Uri.parse('$baseUrl/teams'),
        headers: _headers,
        body: json.encode(teamData),
      );

      // ✅ LOG: Voir la réponse complète

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['data'] == null) {
          throw Exception('Réponse API invalide: champ "data" manquant');
        }

        final data = responseData['data'];

        // La réponse API est {"data": {"team_id": 11, "team_name": "...", ...}}
        final teamId = data is Map ? (data['team_id'] ?? data['id']) : null;

        if (teamId == null) {
          // Fallback au cas où le format serait différent (ex: {"team_id": 11})
          if (responseData['team_id'] != null) {
            return responseData['team_id'] as int;
          }

          throw Exception('ID d\'équipe manquant dans la réponse');
        }
        return teamId as int;
      } else if (response.statusCode == 401) {
        throw Exception('Non authentifié - Token invalide ou manquant');
      } else if (response.statusCode == 422) {
        // ✅ Mieux gérer l'erreur de validation
        try {
          final errorData = json.decode(response.body);
          final errors =
              errorData['errors'] ?? errorData['message'] ?? response.body;
          throw Exception('Validation: $errors');
        } catch (e) {
          // Si le body n'est pas du JSON valide
          throw Exception(
            'Erreur de validation (HTML reçu): ${response.body.substring(0, 100)}',
          );
        }
      } else {
        // ✅ Afficher le début du body pour déboguer
        throw Exception(
          'Erreur API ${response.statusCode}: ${response.body.substring(0, 100)}',
        );
      }
    } catch (e) {
      throw Exception('Erreur lors de la création de l\'équipe: $e');
    }
  }

  /// POST /teams/addMember - Ajouter un membre
  Future<void> addMemberToTeam(Map<String, dynamic> data) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/teams/addMember'),
        headers: _headers,
        body: json.encode(data),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        // ✅ Gérer le HTML
        try {
          final errorData = json.decode(response.body);
          throw Exception(
            errorData['message'] ?? 'Erreur lors de l\'ajout du membre',
          );
        } catch (e) {
          throw Exception('Erreur ${response.statusCode} (HTML reçu)');
        }
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  /// POST /teams/{teamId}/register-race - Inscrire une équipe à une course
  /// Body: { race_id: number } ou peut-être vide si race_id dans l'URL suffit
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
          errorData['message'] ?? 'Erreur lors de l\'inscription de l\'équipe',
        );
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // ============================================================================
  // TEAM MANAGEMENT (TeamRaceManagement.tsx)
  // ============================================================================

  /// GET /teams/{teamId}/races/{raceId} - Détails complets équipe pour une course
  /// Returns: TeamRaceDetails (team info + members + race info)
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
        // Backend returns direct object {team:..., race:..., members:...}
        return responseData as Map<String, dynamic>;
      } else if (response.statusCode == 404) {
        throw Exception('Équipe ou course non trouvée');
      } else if (response.statusCode == 403) {
        throw Exception('Vous n\'avez pas accès à cette équipe');
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  /// POST /teams/{teamId}/races/{raceId}/remove-member - Retirer un membre
  /// Body: { user_id: number }
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
          errorData['message'] ?? 'Erreur lors de la suppression du membre',
        );
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  /// POST /teams/{teamId}/races/{raceId}/update-member - Mettre à jour infos membre
  /// Body: { user_id: number, chip_number?: string, pps_form?: string }
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
          errorData['message'] ?? 'Erreur lors de la mise à jour',
        );
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  /// POST /teams/{teamId}/races/{raceId}/validate - Valider l'équipe
  Future<void> validateTeamForRace(int teamId, int raceId) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/teams/validate-race'),
        headers: _headers,
        body: json.encode({'team_id': teamId, 'race_id': raceId}),
      );

      if (response.statusCode != 200) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Erreur lors de la validation');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  /// POST /teams/{teamId}/races/{raceId}/unvalidate - Dévalider l'équipe
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
          errorData['message'] ?? 'Erreur lors de la dévalidation',
        );
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // ============================================================================
  // MÉTHODES ADDITIONNELLES (utilisées par le repository)
  // ============================================================================

  /// GET /races/{raceId}/teams - Liste des équipes d'une course
  /// Modified: Uses /races/{raceId}/details instead to get validation status (is_valid)
  Future<List<Team>> getRaceTeams(int raceId) async {
    try {
      final response = await client.get(
        // Utiliser l'endpoint details car il contient le statut 'is_valid'
        Uri.parse('$baseUrl/races/$raceId/details'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // La structure est data -> teams_list
        if (responseData['data'] != null &&
            responseData['data']['teams_list'] != null) {
          final List<dynamic> teamsList = responseData['data']['teams_list'];
          return teamsList.map((teamJson) {
            // Adapter: 'responsible' -> 'manager_id'
            // L'endpoint details renvoie un objet 'responsible', mais Team attend 'manager_id' ou 'USE_ID'
            if (teamJson['responsible'] != null &&
                teamJson['responsible'] is Map) {
              teamJson['manager_id'] = teamJson['responsible']['id'];
            }
            return Team.fromJson(teamJson);
          }).toList();
        }

        // Fallback: si teams_list n'existe pas, essayer structure classique (peu probable pour cet endpoint)
        if (responseData['data'] is List) {
          final List<dynamic> list = responseData['data'];
          return list.map((json) => Team.fromJson(json)).toList();
        }

        return [];
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
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
