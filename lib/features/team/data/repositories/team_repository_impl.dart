/// Repository implementation for team data operations.
///
/// Manages team CRUD, membership, race registration with API-first,
/// local-fallback strategy. Handles bidirectional sync and data normalization
/// between API (snake_case) and DB (UPPERCASE_UNDERSCORE) formats [web:138][web:186].
///
/// **Key Features:**
/// - Token-based authentication for all API calls
/// - Automatic local cache after successful API operations
/// - Complex sync with validation state and member details
/// - Atomic team creation with race registration
///
/// Example:
/// ```dart
/// final repo = TeamRepositoryImpl(
///   apiSources: teamApi,
///   localSources: teamLocalDb,
///   authLocalSources: authDb,
/// );
/// await repo.createTeamAndRegisterToRace(
///   team: team,
///   memberIds:,[1][2][3]
///   raceId: raceId,
/// );
/// ```
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

  /// Injects auth token into API client [web:138].
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

      // ✅ CORRECTION: Ne pas utiliser teamData directement s'il vient de toJson()
      // Au lieu de ça, s'assurer qu'on envoie le bon format
      final apiData = {
        'name': teamData['TEA_NAME'] ?? teamData['name'],
        if (teamData['TEA_IMAGE'] != null || teamData['image'] != null)
          'image': teamData['TEA_IMAGE'] ?? teamData['image'],
      };

      final teamId = await apiSources.createTeam(apiData);

      // Cache locally with DB format
      final team = Team.fromJson({
        'TEA_ID': teamId,
        'TEA_NAME': apiData['name'],
        'USE_ID': teamData['USE_ID'] ?? teamData['manager_id'],
        if (apiData['image'] != null) 'TEA_IMAGE': apiData['image'],
      });
      await localSources.createTeam(team.toJson());
      return teamId;
    } catch (e) {
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
        await apiSources.addMemberToTeam({
          'team_id': teamId,
          'user_id': userId,
        });
      }
    } catch (e) {
      await localSources.addTeamMember(teamId, userId);
      if (raceId != null) {
        await localSources.registerUserToRace(userId, raceId);
      }
    }
  }

  /// Adds member to team for specific race (with local sync).
  Future<void> addMemberToTeam(Map<String, dynamic> data) async {
    try {
      _setAuthToken();
      await apiSources.addMemberToTeam(data);

      await localSources.addTeamMember(data['team_id'], data['user_id']);
      await localSources.registerUserToRace(data['user_id'], data['race_id']);
    } catch (e) {
      await localSources.addTeamMember(data['team_id'], data['user_id']);
      await localSources.registerUserToRace(data['user_id'], data['race_id']);
    }
  }

  @override
  Future<void> registerTeamToRace(int teamId, int raceId) async {
    try {
      _setAuthToken();
      await apiSources.registerTeamToRace(teamId, raceId);

      await localSources.registerTeamToRace(teamId, raceId);
    } catch (e) {
      await localSources.registerTeamToRace(teamId, raceId);
    }
  }

  @override
  Future<void> registerUserToRace(int userId, int raceId) async {
    try {
      _setAuthToken();
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

      // Sync users locally for JOIN operations
      for (var user in remoteUsers) {
        await localSources.upsertUser(user.toJson());
      }

      return remoteUsers;
    } catch (e) {
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

      await localSources.validateTeamForRace(teamId, raceId);
    } catch (e) {
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
        } catch (e) {}
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
      return await localSources.getTeamMembersWithRaceDetails(teamId, raceId);
    }
  }

  /// Syncs API team data to local DB with format normalization [web:186].
  ///
  /// Normalizes API (snake_case) → DB (UPPERCASE_UNDERSCORE), syncs team,
  /// members, validation state, PPS forms, and chip numbers.
  Future<void> _syncTeamFromApi(
    Map<String, dynamic> apiData,
    int raceId,
  ) async {
    try {
      final teamJson = apiData['team'];
      if (teamJson != null) {
        // Normalize API format → DB format
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

        final team = Team.fromJson(normalizedTeamJson);
        await localSources.createTeam(team.toJson());

        // Sync validation status
        bool isValid = false;
        if (teamJson['is_valid'] == true || teamJson['is_valid'] == 1)
          isValid = true;

        if (isValid) {
          await localSources.validateTeamForRace(team.id, raceId);
        } else {
          await localSources.invalidateTeamForRace(team.id, raceId);
        }

        // Sync members with PPS and chip data
        final members = apiData['members'] as List?;
        if (members != null) {
          for (var m in members) {
            final Map<String, dynamic> normM = Map<String, dynamic>.from(m);
            // Normalize User keys for DB format
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

            // Sync PPS form
            final pps = m['pps_form'] ?? m['USR_PPS_FORM'];
            if (pps != null) {
              await localSources.updateUserPPS(user.id, pps, raceId);
            }

            // Sync chip number
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
    } catch (e) {}
  }

  @override
  Future<void> invalidateTeamForRace(int teamId, int raceId) async {
    try {
      _setAuthToken();
      await apiSources.unvalidateTeamForRace(teamId, raceId);

      await localSources.invalidateTeamForRace(teamId, raceId);
    } catch (e) {
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
      // No offline queueing
      await localSources.removeMemberFromTeam(teamId, userId);
    }
  }

  /// Removes member from team for specific race.
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
      await localSources.removeMemberFromTeam(teamId, userId);
    }
  }

  @override
  Future<void> deleteTeam(int teamId, int raceId) async {
    try {
      _setAuthToken();

      // Fix: Use the race-specific delete endpoint
      await apiSources.deleteTeamFromRace(teamId, raceId);

      // Local cleanup
      await localSources.deleteTeam(teamId, raceId);
    } catch (e) {
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
        null,
      );

      await localSources.updateUserChipNumber(userId, raceId, chipNumber);
    } catch (e) {
      await localSources.updateUserChipNumber(userId, raceId, chipNumber);
    }
  }

  /// Combined update for PPS form and chip number.
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

      // Sync locally
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
      return await localSources.getRaceDetails(raceId);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getUserConflictingRaces(
    int userId,
    int raceId,
  ) async {
    try {
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

      // 1. Create team
      final teamId = await createTeam(team.toJson());

      // 2. Add members
      for (final userId in memberIds) {
        await addMemberToTeam({
          'user_id': userId,
          'team_id': teamId,
          'race_id': raceId,
        });
      }

      // 3. Register team to race
      await registerTeamToRace(teamId, raceId);
    } catch (e) {
      // Complete local fallback (atomic transaction)
      await localSources.createTeamAndRegisterToRace(
        team: team,
        memberIds: memberIds,
        raceId: raceId,
      );
    }
  }

  /// Fetches complete team-race details with members.
  Future<Map<String, dynamic>> getTeamRaceDetails(
    int teamId,
    int raceId,
  ) async {
    try {
      _setAuthToken();
      return await apiSources.getTeamRaceDetails(teamId, raceId);
    } catch (e) {
      // Build details from local sources
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
