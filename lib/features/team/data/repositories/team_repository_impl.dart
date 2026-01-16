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
      print(
        '🔑 Repository - Token from storage: ${token != null ? "YES" : "NO"}',
      );

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
  Future<void> addTeamMember(int teamId, int userId, {int? raceId}) async {
    try {
      _setAuthToken();
      if (raceId != null) {
        await apiSources.addMemberToTeam({
          'team_id': teamId,
          'user_id': userId,
          'race_id': raceId,
        });
      } else {
        // Fallback or error if raceId is required by API
        await apiSources.addMemberToTeam({
          'team_id': teamId,
          'user_id': userId,
        });
      }
    } catch (e) {
      print('API sync failed, saving locally: $e');

      await localSources.addTeamMember(teamId, userId);
      if (raceId != null) {
        await localSources.registerUserToRace(userId, raceId);
      }
    }
  }

  /// Nouvelle méthode avec race_id (utilisée par l'interface)
  Future<void> addMemberToTeam(Map<String, dynamic> data) async {
    try {
      _setAuthToken();
      await apiSources.addMemberToTeam(data);

      // Sauvegarder en local (note: la méthode locale ne prend pas race_id)
      await localSources.addTeamMember(data['team_id'], data['user_id']);

      // Inscrire aussi l'utilisateur à la course en local
      await localSources.registerUserToRace(data['user_id'], data['race_id']);
    } catch (e) {
      print('API sync failed, saving locally: $e');

      await localSources.addTeamMember(data['team_id'], data['user_id']);
      await localSources.registerUserToRace(data['user_id'], data['race_id']);
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

      // Sync users locally to ensure joins work for team display
      for (var user in remoteUsers) {
        await localSources.upsertUser(user.toJson());
      }

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

      // Update local cache in background
      await _syncTeamFromApi(data, raceId);

      // Construct Team object explicitly from API data to ensure fresh data
      final teamJson = data['team'];

      final isValidVal = teamJson['is_valid'] ?? teamJson['TER_IS_VALID'];
      final bool isValid = isValidVal == 1 || isValidVal == true;

      final dynamic rawManagerId = teamJson['manager_id'] ?? teamJson['USE_ID'];

      int managerId = (rawManagerId ?? 0) as int;

      // FIX: If managerId is 0 or missing (because API doesn't return it), fetch it separately
      if (managerId == 0) {
        try {
          final fullTeam = await apiSources.getTeamById(teamId);
          if (fullTeam != null) {
            managerId = fullTeam.managerId;
          }
        } catch (e) {
          print('Secondary fetch for manager ID failed: $e');
        }
      }

      return Team(
        id: (teamJson['id'] ?? teamJson['TEA_ID'] ?? 0) as int,
        managerId: managerId,
        name: (teamJson['name'] ?? teamJson['TEA_NAME'] ?? '') as String,
        image: (teamJson['image'] ?? teamJson['TEA_IMAGE']) as String?,
        isValid: isValid,
        membersCount: (data['members'] as List?)?.length,
      );
    } catch (e) {
      print('API fetch failed: $e. Falling back to local cache...');
      return await localSources.getTeamByIdWithRaceStatus(teamId, raceId);
    }
  }

  @override
  Future<int?> getTeamDossardNumber(int teamId, int raceId) async {
    try {
      _setAuthToken();
      final data = await apiSources.getTeamRaceDetails(teamId, raceId);
      final teamData = data['team'];
      return (teamData['race_number'] ?? teamData['TER_RACE_NUMBER']) as int?;
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

      // Sync in background (fire and forget or await, but don't rely on it for return)
      await _syncTeamFromApi(data, raceId);

      final members = data['members'] as List;
      return members.map((m) => m as Map<String, dynamic>).toList();
    } catch (e) {
      print('API fetch failed: $e. Falling back to local cache...');
      return await localSources.getTeamMembersWithRaceDetails(teamId, raceId);
    }
  }

  Future<void> _syncTeamFromApi(
    Map<String, dynamic> apiData,
    int raceId,
  ) async {
    try {
      final teamJson = apiData['team'];
      if (teamJson != null) {
        // Normalize JSON keys for Team parsing if necessary
        final Map<String, dynamic> normalizedTeamJson =
            Map<String, dynamic>.from(teamJson);
        if (!normalizedTeamJson.containsKey('TEA_ID'))
          normalizedTeamJson['TEA_ID'] = teamJson['id'];
        if (!normalizedTeamJson.containsKey('TEA_NAME'))
          normalizedTeamJson['TEA_NAME'] = teamJson['name'];
        if (!normalizedTeamJson.containsKey('USE_ID'))
          normalizedTeamJson['USE_ID'] = teamJson['manager_id'];
        if (!normalizedTeamJson.containsKey('TEA_IMAGE'))
          normalizedTeamJson['TEA_IMAGE'] = teamJson['image'];

        // Creates Team object to standardise, then saves to DB using DB columns
        // NOTE: We strip race-specific fields (is_valid, race_number) because SAN_TEAMS doesn't have them
        // They are handled separately via registerTeamToRace or validateTeamForRace
        final team = Team.fromJson(normalizedTeamJson);
        await localSources.createTeam(team.toJson());

        // Sync Validation Status
        bool isValid = false;
        if (teamJson['is_valid'] == true || teamJson['is_valid'] == 1)
          isValid = true;

        if (isValid) {
          await localSources.validateTeamForRace(team.id, raceId);
        } else {
          // Si non validé, on l'invalide (ou on ne fait rien si c'est déjà 0 par défaut)
          await localSources.invalidateTeamForRace(team.id, raceId);
        }

        // Sync Members
        final members = apiData['members'] as List?;
        if (members != null) {
          for (var m in members) {
            final Map<String, dynamic> normM = Map<String, dynamic>.from(m);
            // Normalize User keys for User.fromJson (DB Format expected)
            if (!normM.containsKey('USE_ID')) normM['USE_ID'] = m['id'];
            if (!normM.containsKey('USE_NAME'))
              normM['USE_NAME'] = m['name'] ?? m['first_name'];
            if (!normM.containsKey('USE_LAST_NAME'))
              normM['USE_LAST_NAME'] = m['last_name'];
            if (!normM.containsKey('USE_MAIL')) normM['USE_MAIL'] = m['email'];
            if (!normM.containsKey('USE_LICENCE_NUMBER'))
              normM['USE_LICENCE_NUMBER'] = m['licence_number'];

            final user = User.fromJson(normM);
            await localSources.upsertUser(user.toJson());
            await localSources.addTeamMember(team.id, user.id);
            await localSources.registerUserToRace(user.id, raceId);

            // Sync PPS
            final pps = m['pps_form'] ?? m['USR_PPS_FORM'];
            if (pps != null) {
              await localSources.updateUserPPS(user.id, pps, raceId);
            }

            // Sync Chip
            final chip = m['chip_number'] ?? m['USR_CHIP_NUMBER'];
            int? chipInt;
            if (chip is int) {
              chipInt = chip;
            } else if (chip is String) {
              chipInt = int.tryParse(chip);
            }
            if (chipInt != null) {
              await localSources.updateUserChipNumber(user.id, raceId, chipInt);
            }
          }
        }
      }
    } catch (e) {
      print('Error syncing team data from API: $e');
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

  // ===================================
  // SYNC QUEUE IMPLEMENTATION
  // ===================================

  @override
  Future<void> removeMemberFromTeam(
    int teamId,
    int userId, {
    int? raceId,
  }) async {
    try {
      _setAuthToken();
      if (raceId != null) {
        await apiSources.removeMemberFromTeamRace(teamId, raceId, userId);
      }
      await localSources.removeMemberFromTeam(teamId, userId);
    } catch (e) {
      print('API sync failed: $e');
      // No offline queueing
      await localSources.removeMemberFromTeam(teamId, userId);
    }
  }

  /// Méthode avec raceId pour l'API
  Future<void> removeMemberFromTeamRace(
    int teamId,
    int raceId,
    int userId,
  ) async {
    try {
      _setAuthToken();
      await apiSources.removeMemberFromTeamRace(teamId, raceId, userId);
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
      print('Deleting team $teamId from race $raceId...');

      // Fix: Use the race-specific delete endpoint
      await apiSources.deleteTeamFromRace(teamId, raceId);

      // Local cleanup
      await localSources.deleteTeam(teamId, raceId);
    } catch (e) {
      print('API deletion failed: $e');
      // No offline queueing
      await localSources.deleteTeam(teamId, raceId);
    }
  }

  @override
  Future<void> updateUserPPS(
    int userId,
    String? ppsForm,
    int raceId,
    int teamId,
  ) async {
    try {
      _setAuthToken();
      await apiSources.updateMemberRaceInfo(
        teamId,
        raceId,
        userId,
        null,
        ppsForm,
      );
      await localSources.updateUserPPS(userId, ppsForm, raceId);
    } catch (e) {
      print('API sync failed: $e');
      // No offline queueing
      await localSources.updateUserPPS(userId, ppsForm, raceId);
    }
  }

  @override
  Future<void> updateUserChipNumber(
    int userId,
    int raceId,
    int? chipNumber,
    int teamId,
  ) async {
    try {
      _setAuthToken();
      await apiSources.updateMemberRaceInfo(
        teamId,
        raceId,
        userId,
        chipNumber?.toString(),
        null, // No pps update
      );

      await localSources.updateUserChipNumber(userId, raceId, chipNumber);
    } catch (e) {
      print('API sync failed, saving locally: $e');
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
        await localSources.updateUserChipNumber(
          userId,
          raceId,
          int.tryParse(chipNumber),
        );
      }
      if (ppsForm != null && ppsForm.isNotEmpty) {
        await localSources.updateUserPPS(userId, ppsForm, raceId);
      }
    } catch (e) {
      print('API sync failed, saving locally: $e');

      if (chipNumber != null && chipNumber.isNotEmpty) {
        await localSources.updateUserChipNumber(
          userId,
          raceId,
          int.tryParse(chipNumber),
        );
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
  Future<Map<String, dynamic>> getTeamRaceDetails(
    int teamId,
    int raceId,
  ) async {
    try {
      _setAuthToken();
      return await apiSources.getTeamRaceDetails(teamId, raceId);
    } catch (e) {
      print('API fetch failed: $e. Falling back to local cache...');

      // Construire les détails depuis le local
      final team = await localSources.getTeamByIdWithRaceStatus(teamId, raceId);
      final members = await localSources.getTeamMembersWithRaceDetails(
        teamId,
        raceId,
      );
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
