// lib/features/team/data/repositories/team_repository_impl.dart
import '../../domain/team.dart';
import '../../domain/team_repository.dart';
import '../../../user/domain/user.dart';
import '../datasources/team_api_sources.dart';
import '../datasources/team_local_sources.dart';
import '../../../auth/data/datasources/auth_local_sources.dart';

class TeamRepositoryImpl implements TeamRepository {
  final TeamApiSources apiSources;
  final TeamLocalSources localSources;
  final AuthLocalSources authLocalSources;

  TeamRepositoryImpl({
    required this.apiSources,
    required this.localSources,
    required this.authLocalSources,
  });

  void _setAuthToken() {
    final token = authLocalSources.getToken();
    apiSources.setAuthToken(token);
  }

  @override
  Future<List<Team>> getRaceTeams(int raceId) async {
    try {
      _setAuthToken();
      final remoteTeams = await apiSources.getRaceTeams(raceId);
      return remoteTeams;
    } catch (e) {
      print('API fetch failed: $e. Falling back to local cache...');
      
      try {
        final localData = await localSources.getRaceTeams(raceId);
        return localData.map((data) => Team.fromJson(data)).toList();
      } catch (localError) {
        return [];
      }
    }
  }

  @override
  Future<Team?> getTeamById(int teamId) async {
    try {
      _setAuthToken();
      return await apiSources.getTeamById(teamId);
    } catch (e) {
      print('API fetch failed: $e. Falling back to local cache...');
      
      try {
        final localData = await localSources.getTeamById(teamId);
        if (localData != null) {
          return Team.fromJson(localData);
        }
        return null;
      } catch (localError) {
        return null;
      }
    }
  }

  @override
  Future<int> createTeam(Map<String, dynamic> teamData) async {
    try {
      _setAuthToken();
      
      final token = authLocalSources.getToken();
      print('🔑 Repository - Token from storage: ${token != null ? "YES" : "NO"}');
      
      // ✅ CORRECTION: Ne pas utiliser teamData directement s'il vient de toJson()
      // Au lieu de ça, s'assurer qu'on envoie le bon format
      final apiData = {
        'name': teamData['TEA_NAME'] ?? teamData['name'],
        if (teamData['TEA_IMAGE'] != null || teamData['image'] != null)
          'image': teamData['TEA_IMAGE'] ?? teamData['image'],
      };
      
      print('📤 Sending to API: $apiData');
      
      final teamId = await apiSources.createTeam(apiData);
      
      // Sauvegarder en local avec le bon format
      final team = Team.fromJson({
        'TEA_ID': teamId,
        'TEA_NAME': apiData['name'],
        'USE_ID': teamData['USE_ID'] ?? teamData['manager_id'],
        if (apiData['image'] != null) 'TEA_IMAGE': apiData['image'],
      });
      await localSources.createTeam(team.toJson());      
      return teamId;
    } catch (e) {
      print('API sync failed, saving locally: $e');
      
      // Fallback local
      return await localSources.createTeam(teamData);
    }
  }

  @override
  Future<void> addTeamMember(int teamId, int userId) async {
    try {
      _setAuthToken();
      await apiSources.addMemberToTeam({
        'team_id': teamId,
        'user_id': userId,
      });
    } catch (e) {
      print('API sync failed, saving locally: $e');
      
      await localSources.addTeamMember(teamId, userId);
    }
  }

  /// Nouvelle méthode avec race_id (utilisée par l'interface)
  Future<void> addMemberToTeam(Map<String, dynamic> data) async {
    try {
      _setAuthToken();
      await apiSources.addMemberToTeam(data);
      
      // Sauvegarder en local (note: la méthode locale ne prend pas race_id)
      await localSources.addTeamMember(
        data['team_id'],
        data['user_id'],
      );
      
      // Inscrire aussi l'utilisateur à la course en local
      await localSources.registerUserToRace(
        data['user_id'],
        data['race_id'],
      );
    } catch (e) {
      print('API sync failed, saving locally: $e');
      
      await localSources.addTeamMember(
        data['team_id'],
        data['user_id'],
      );
      await localSources.registerUserToRace(
        data['user_id'],
        data['race_id'],
      );
    }
  }

  @override
  Future<void> registerTeamToRace(int teamId, int raceId) async {
    try {
      _setAuthToken();
      await apiSources.registerTeamToRace(teamId, raceId);
      
      // Sauvegarder en local
      await localSources.registerTeamToRace(teamId, raceId);
    } catch (e) {
      print('API sync failed, saving locally: $e');
      
      await localSources.registerTeamToRace(teamId, raceId);
    }
  }

  @override
  Future<void> registerUserToRace(int userId, int raceId) async {
    try {
      _setAuthToken();
      // L'API gère ça via addMemberToTeam
      // Mais en local on a une méthode dédiée
      await localSources.registerUserToRace(userId, raceId);
    } catch (e) {
      await localSources.registerUserToRace(userId, raceId);
    }
  }

  @override
  Future<List<User>> getAvailableUsersForRace(int raceId) async {
    try {
      _setAuthToken();
      final remoteUsers = await apiSources.getAvailableUsersForRace(raceId);
      return remoteUsers;
    } catch (e) {
      print('API fetch failed: $e. Falling back to local cache...');
      
      try {
        final localData = await localSources.getAvailableUsersForRace(raceId);
        return localData.map((data) => User.fromJson(data)).toList();
      } catch (localError) {
        return [];
      }
    }
  }

  @override
  Future<List<User>> getTeamMembers(int teamId) async {
    try {
      final localData = await localSources.getTeamMembers(teamId);
      return localData.map((data) => User.fromJson(data)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> validateTeamForRace(int teamId, int raceId) async {
    try {
      _setAuthToken();
      await apiSources.validateTeamForRace(teamId, raceId);
      
      // Mettre à jour en local
      await localSources.validateTeamForRace(teamId, raceId);
    } catch (e) {
      print('API sync failed, saving locally: $e');
      
      await localSources.validateTeamForRace(teamId, raceId);
    }
  }

  @override
  Future<bool> canAccessTeamDetail({
    required int teamId,
    required int raceId,
    required int userId,
  }) async {
    try {
      _setAuthToken();
      await apiSources.getTeamRaceDetails(teamId, raceId);
      return true;
    } catch (e) {
      // Vérifier en local
      return await localSources.canAccessTeamDetail(
        teamId: teamId,
        raceId: raceId,
        userId: userId,
      );
    }
  }

  @override
  Future<Team?> getTeamByIdWithRaceStatus(int teamId, int raceId) async {
    try {
      _setAuthToken();
      final data = await apiSources.getTeamRaceDetails(teamId, raceId);
      return Team.fromJson(data['team']);
    } catch (e) {
      print('API fetch failed: $e. Falling back to local cache...');
      
      // La méthode locale retourne directement un Team
      return await localSources.getTeamByIdWithRaceStatus(teamId, raceId);
    }
  }

  @override
  Future<int?> getTeamDossardNumber(int teamId, int raceId) async {
    try {
      _setAuthToken();
      final data = await apiSources.getTeamRaceDetails(teamId, raceId);
      return data['team']['race_number'] as int?;
    } catch (e) {
      return await localSources.getTeamDossardNumber(teamId, raceId);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getTeamMembersWithRaceDetails(
    int teamId,
    int raceId,
  ) async {
    try {
      _setAuthToken();
      final data = await apiSources.getTeamRaceDetails(teamId, raceId);
      final members = data['members'] as List<dynamic>?;
      return members?.map((e) => e as Map<String, dynamic>).toList() ?? [];
    } catch (e) {
      print('API fetch failed: $e. Falling back to local cache...');
      
      return await localSources.getTeamMembersWithRaceDetails(teamId, raceId);
    }
  }

  @override
  Future<void> invalidateTeamForRace(int teamId, int raceId) async {
    try {
      _setAuthToken();
      await apiSources.unvalidateTeamForRace(teamId, raceId);
      
      await localSources.invalidateTeamForRace(teamId, raceId);
    } catch (e) {
      print('API sync failed, saving locally: $e');
      
      await localSources.invalidateTeamForRace(teamId, raceId);
    }
  }

  @override
  Future<void> removeMemberFromTeam(int teamId, int userId) async {
    try {
      _setAuthToken();
      // L'API nécessite raceId, mais on peut essayer quand même
      // Sinon utiliser la méthode avec raceId
      await localSources.removeMemberFromTeam(teamId, userId);
    } catch (e) {
      await localSources.removeMemberFromTeam(teamId, userId);
    }
  }

  /// Méthode avec raceId pour l'API
  Future<void> removeMemberFromTeamRace(int teamId, int raceId, int userId) async {
    try {
      _setAuthToken();
      await apiSources.removeMemberFromTeamRace(teamId, raceId, userId);
      
      // En local, pas besoin de raceId pour cette méthode
      await localSources.removeMemberFromTeam(teamId, userId);
    } catch (e) {
      print('API sync failed, saving locally: $e');
      
      await localSources.removeMemberFromTeam(teamId, userId);
    }
  }

  @override
  Future<void> deleteTeam(int teamId, int raceId) async {
    try {
      _setAuthToken();
      // L'API n'a pas cette route
      // On supprime juste en local
      await localSources.deleteTeam(teamId, raceId);
    } catch (e) {
      await localSources.deleteTeam(teamId, raceId);
    }
  }

  @override
  Future<void> updateUserPPS(int userId, String? ppsForm, int raceId) async {
    try {
      _setAuthToken();
      // L'API utilise updateMemberRaceInfo
      // En local on a une méthode dédiée
      await localSources.updateUserPPS(userId, ppsForm, raceId);
    } catch (e) {
      await localSources.updateUserPPS(userId, ppsForm, raceId);
    }
  }

  @override
  Future<void> updateUserChipNumber(int userId, int raceId, int? chipNumber) async {
    try {
      _setAuthToken();
      // L'API utilise updateMemberRaceInfo
      // En local on a une méthode dédiée
      await localSources.updateUserChipNumber(userId, raceId, chipNumber);
    } catch (e) {
      await localSources.updateUserChipNumber(userId, raceId, chipNumber);
    }
  }

  /// Méthode combinée pour l'API
  Future<void> updateMemberRaceInfo(
    int teamId,
    int raceId,
    int userId,
    String? chipNumber,
    String? ppsForm,
  ) async {
    try {
      _setAuthToken();
      await apiSources.updateMemberRaceInfo(
        teamId,
        raceId,
        userId,
        chipNumber,
        ppsForm,
      );
      
      // Mettre à jour en local
      if (chipNumber != null && chipNumber.isNotEmpty) {
        await localSources.updateUserChipNumber(userId, raceId, int.tryParse(chipNumber));
      }
      if (ppsForm != null && ppsForm.isNotEmpty) {
        await localSources.updateUserPPS(userId, ppsForm, raceId);
      }
    } catch (e) {
      print('API sync failed, saving locally: $e');
      
      if (chipNumber != null && chipNumber.isNotEmpty) {
        await localSources.updateUserChipNumber(userId, raceId, int.tryParse(chipNumber));
      }
      if (ppsForm != null && ppsForm.isNotEmpty) {
        await localSources.updateUserPPS(userId, ppsForm, raceId);
      }
    }
  }

  @override
  Future<Map<String, dynamic>?> getRaceDetails(int raceId) async {
    try {
      _setAuthToken();
      return await apiSources.getRaceDetails(raceId);
    } catch (e) {
      print('API fetch failed: $e. Falling back to local cache...');
      
      return await localSources.getRaceDetails(raceId);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getUserConflictingRaces(
    int userId,
    int raceId,
  ) async {
    try {
      // Pas d'API pour ça, utiliser directement le local
      return await localSources.getUserConflictingRaces(userId, raceId);
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> createTeamAndRegisterToRace({
    required Team team,
    required List<int> memberIds,
    required int raceId,
  }) async {
    try {
      _setAuthToken();
      
      // 1. Créer l'équipe
      final teamId = await createTeam(team.toJson());

      // 2. Ajouter les membres
      for (final userId in memberIds) {
        await addMemberToTeam({
          'user_id': userId,
          'team_id': teamId,
          'race_id': raceId,
        });
      }

      // 3. Inscrire l'équipe à la course
      await registerTeamToRace(teamId, raceId);
    } catch (e) {
      print('Full team creation failed: $e. Falling back to local...');
      
      // Fallback complet en local
      await localSources.createTeamAndRegisterToRace(
        team: team,
        memberIds: memberIds,
        raceId: raceId,
      );
    }
  }

  /// Méthode pour getTeamRaceDetails (complète)
  Future<Map<String, dynamic>> getTeamRaceDetails(int teamId, int raceId) async {
    try {
      _setAuthToken();
      return await apiSources.getTeamRaceDetails(teamId, raceId);
    } catch (e) {
      print('API fetch failed: $e. Falling back to local cache...');
      
      // Construire les détails depuis le local
      final team = await localSources.getTeamByIdWithRaceStatus(teamId, raceId);
      final members = await localSources.getTeamMembersWithRaceDetails(teamId, raceId);
      final race = await localSources.getRaceDetails(raceId);
      final dossard = await localSources.getTeamDossardNumber(teamId, raceId);
      
      if (team == null || race == null) {
        throw Exception('Impossible de récupérer les détails de l\'équipe');
      }
      
      return {
        'team': {
          'TEA_ID': team.id,
          'TEA_NAME': team.name,
          'is_valid': team.isValid,
          'race_number': dossard,
        },
        'race': race,
        'members': members,
      };
    }
  }
}
