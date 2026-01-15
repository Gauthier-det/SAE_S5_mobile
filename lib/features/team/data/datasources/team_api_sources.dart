import 'dart:convert';
import '../../../../core/services/api_client.dart';
import '../../domain/team.dart';

class TeamApiSources {
  final ApiClient apiClient;

  TeamApiSources({ApiClient? apiClient})
      : apiClient = apiClient ?? ApiClient();

  /// POST /api/teams (requires auth)
  Future<Team> createTeam(Map<String, dynamic> teamData) async {
    try {
      final response = await apiClient.post(
        '/api/teams',
        body: teamData,
        requiresAuth: true,
      );
      final data = json.decode(response.body);
      return Team.fromJson(data);
    } catch (e) {
      throw Exception('Failed to create team: $e');
    }
  }

  /// POST /api/teams/addMember (requires auth)
  Future<void> addMember(Map<String, dynamic> memberData) async {
    try {
      await apiClient.post(
        '/api/teams/addMember',
        body: memberData,
        requiresAuth: true,
      );
    } catch (e) {
      throw Exception('Failed to add member to team: $e');
    }
  }
}
