// lib/features/teams/data/repositories/team_repository_impl.dart
import 'package:sae5_g13_mobile/features/auth/data/datasources/auth_local_sources.dart';

import '../../domain/team.dart';
import '../../domain/team_repository.dart';
import '../datasources/team_api_sources.dart';
import '../datasources/team_local_sources.dart';
import '../../../user/domain/user.dart';

class TeamRepositoryImpl implements TeamRepository {
  final TeamLocalSources localSources;
  final TeamApiSources apiSources;
  final AuthLocalSources authLocalSources;

  TeamRepositoryImpl({required this.localSources, required this.apiSources, required this.authLocalSources});

  @override
  Future<List<Team>> getRaceTeams(int raceId) async {
    try {
      print('🌐 API: getRaceTeams');
      final teams = await apiSources.getRaceTeams(raceId);
      print('✅ API success: ${teams.length} teams');
      return teams;
    } catch (e) {
      print('⚠️ API failed, fallback to local: $e');
      final maps = await localSources.getRaceTeams(raceId);
      return maps.map((map) => Team.fromJson(map)).toList();
    }
  }

  @override
  Future<Team?> getTeamById(int teamId) async {
    try {
      print('🌐 API: getTeamById');
      final team = await apiSources.getTeamById(teamId);
      print('✅ API success');
      return team;
    } catch (e) {
      print('⚠️ API failed, fallback to local: $e');
      final map = await localSources.getTeamById(teamId);
      return map != null ? Team.fromJson(map) : null;
    }
  }

  @override
  Future<Team?> getTeamByIdWithRaceStatus(int teamId, int raceId) async {
    try {
      print('🌐 API: getTeamByIdWithRaceStatus');
      final team = await apiSources.getTeamByIdWithRaceStatus(teamId, raceId);
      print('✅ API success');
      return team;
    } catch (e) {
      print('⚠️ API failed, fallback to local: $e');
      return await localSources.getTeamByIdWithRaceStatus(teamId, raceId);
    }
  }

  @override
  Future<int> createTeam(Map<String, dynamic> teamData) async {
    try {
      print('🌐 API: createTeam');
      final teamId = await apiSources.createTeam(teamData);
      print('✅ API success: teamId=$teamId');
      
      // Sync to local
      try {
        await localSources.createTeam(teamData);
        print('💾 Synced to local');
      } catch (e) {
        print('⚠️ Local sync failed: $e');
      }
      
      return teamId;
    } catch (e) {
      print('⚠️ API failed, fallback to local: $e');
      return await localSources.createTeam(teamData);
    }
  }

  @override
  Future<void> addTeamMember(int teamId, int userId) async {
    try {
      print('🌐 API: addTeamMember');
      await apiSources.addTeamMember(teamId, userId);
      print('✅ API success');
      
      // Sync to local
      try {
        await localSources.addTeamMember(teamId, userId);
        print('💾 Synced to local');
      } catch (e) {
        print('⚠️ Local sync failed: $e');
      }
    } catch (e) {
      print('⚠️ API failed, fallback to local: $e');
      await localSources.addTeamMember(teamId, userId);
    }
  }

  @override
  Future<void> registerTeamToRace(int teamId, int raceId) async {
    try {
      print('🌐 API: registerTeamToRace');
      await apiSources.registerTeamToRace(teamId, raceId);
      print('✅ API success');
      
      // Sync to local
      try {
        await localSources.registerTeamToRace(teamId, raceId);
        print('💾 Synced to local');
      } catch (e) {
        print('⚠️ Local sync failed: $e');
      }
    } catch (e) {
      print('⚠️ API failed, fallback to local: $e');
      await localSources.registerTeamToRace(teamId, raceId);
    }
  }

  @override
  Future<void> registerUserToRace(int userId, int raceId) async {
    try {
      print('🌐 API: registerUserToRace');
      await apiSources.registerUserToRace(userId, raceId);
      print('✅ API success');
      
      // Sync to local
      try {
        await localSources.registerUserToRace(userId, raceId);
        print('💾 Synced to local');
      } catch (e) {
        print('⚠️ Local sync failed: $e');
      }
    } catch (e) {
      print('⚠️ API failed, fallback to local: $e');
      await localSources.registerUserToRace(userId, raceId);
    }
  }

  @override
  Future<List<User>> getAvailableUsersForRace(int raceId) async {
    try {
      print('🌐 API: getAvailableUsersForRace');
      final users = await apiSources.getAvailableUsersForRace(raceId);
      print('✅ API success: ${users.length} users');
      return users;
    } catch (e) {
      print('⚠️ API failed, fallback to local: $e');
      final maps = await localSources.getAvailableUsersForRace(raceId);
      return maps.map((map) => User.fromJson(map)).toList();
    }
  }

  @override
  Future<List<User>> getTeamMembers(int teamId) async {
    try {
      print('🌐 API: getTeamMembers');
      final users = await apiSources.getTeamMembers(teamId);
      print('✅ API success: ${users.length} members');
      return users;
    } catch (e) {
      print('⚠️ API failed, fallback to local: $e');
      final maps = await localSources.getTeamMembers(teamId);
      return maps.map((map) => User.fromJson(map)).toList();
    }
  }

  @override
  Future<void> validateTeamForRace(int teamId, int raceId) async {
    try {
      print('🌐 API: validateTeamForRace');
      await apiSources.validateTeamForRace(teamId, raceId);
      print('✅ API success');
      
      // Sync to local
      try {
        await localSources.validateTeamForRace(teamId, raceId);
        print('💾 Synced to local');
      } catch (e) {
        print('⚠️ Local sync failed: $e');
      }
    } catch (e) {
      print('⚠️ API failed, fallback to local: $e');
      await localSources.validateTeamForRace(teamId, raceId);
    }
  }

  @override
  Future<void> invalidateTeamForRace(int teamId, int raceId) async {
    try {
      print('🌐 API: invalidateTeamForRace');
      await apiSources.invalidateTeamForRace(teamId, raceId);
      print('✅ API success');
      
      // Sync to local
      try {
        await localSources.invalidateTeamForRace(teamId, raceId);
        print('💾 Synced to local');
      } catch (e) {
        print('⚠️ Local sync failed: $e');
      }
    } catch (e) {
      print('⚠️ API failed, fallback to local: $e');
      await localSources.invalidateTeamForRace(teamId, raceId);
    }
  }

  @override
  Future<bool> canAccessTeamDetail({
    required int teamId,
    required int raceId,
    required int userId,
  }) async {
    try {
      print('🌐 API: canAccessTeamDetail');
      final canAccess = await apiSources.canAccessTeamDetail(
        teamId: teamId,
        raceId: raceId,
        userId: userId,
      );
      print('✅ API success: $canAccess');
      return canAccess;
    } catch (e) {
      print('⚠️ API failed, fallback to local: $e');
      return await localSources.canAccessTeamDetail(
        teamId: teamId,
        raceId: raceId,
        userId: userId,
      );
    }
  }

  @override
  Future<int?> getTeamDossardNumber(int teamId, int raceId) async {
    try {
      print('🌐 API: getTeamDossardNumber');
      final dossard = await apiSources.getTeamDossardNumber(teamId, raceId);
      print('✅ API success: $dossard');
      return dossard;
    } catch (e) {
      print('⚠️ API failed, fallback to local: $e');
      return await localSources.getTeamDossardNumber(teamId, raceId);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getTeamMembersWithRaceDetails(
    int teamId,
    int raceId,
  ) async {
    try {
      print('🌐 API: getTeamMembersWithRaceDetails');
      final members = await apiSources.getTeamMembersWithRaceDetails(teamId, raceId);
      print('✅ API success: ${members.length} members');
      return members;
    } catch (e) {
      print('⚠️ API failed, fallback to local: $e');
      return await localSources.getTeamMembersWithRaceDetails(teamId, raceId);
    }
  }

  @override
  Future<void> removeMemberFromTeam(int teamId, int userId) async {
    try {
      print('🌐 API: removeMemberFromTeam');
      await apiSources.removeMemberFromTeam(teamId, userId);
      print('✅ API success');
      
      // Sync to local
      try {
        await localSources.removeMemberFromTeam(teamId, userId);
        print('💾 Synced to local');
      } catch (e) {
        print('⚠️ Local sync failed: $e');
      }
    } catch (e) {
      print('⚠️ API failed, fallback to local: $e');
      await localSources.removeMemberFromTeam(teamId, userId);
    }
  }

  @override
  Future<void> deleteTeam(int teamId, int raceId) async {
    try {
      print('🌐 API: deleteTeam');
      await apiSources.deleteTeam(teamId, raceId);
      print('✅ API success');
      
      // Sync to local
      try {
        await localSources.deleteTeam(teamId, raceId);
        print('💾 Synced to local');
      } catch (e) {
        print('⚠️ Local sync failed: $e');
      }
    } catch (e) {
      print('⚠️ API failed (not implemented), fallback to local: $e');
      await localSources.deleteTeam(teamId, raceId);
    }
  }

  @override
  Future<void> updateUserPPS(int userId, String? ppsForm, int raceId) async {
    try {
      print('🌐 API: updateUserPPS');
      await apiSources.updateUserPPS(userId, ppsForm, raceId);
      print('✅ API success');
      
      // Sync to local
      try {
        await localSources.updateUserPPS(userId, ppsForm, raceId);
        print('💾 Synced to local');
      } catch (e) {
        print('⚠️ Local sync failed: $e');
      }
    } catch (e) {
      print('⚠️ API failed, fallback to local: $e');
      await localSources.updateUserPPS(userId, ppsForm, raceId);
    }
  }

  @override
  Future<void> updateUserChipNumber(int userId, int raceId, int? chipNumber) async {
    try {
      print('🌐 API: updateUserChipNumber');
      await apiSources.updateUserChipNumber(userId, raceId, chipNumber);
      print('✅ API success');
      
      // Sync to local
      try {
        await localSources.updateUserChipNumber(userId, raceId, chipNumber);
        print('💾 Synced to local');
      } catch (e) {
        print('⚠️ Local sync failed: $e');
      }
    } catch (e) {
      print('⚠️ API failed, fallback to local: $e');
      await localSources.updateUserChipNumber(userId, raceId, chipNumber);
    }
  }

  @override
  Future<void> createTeamAndRegisterToRace({
    required Team team,
    required List<int> memberIds,
    required int raceId,
  }) async {
    try {
      print('🌐 API: createTeamAndRegisterToRace (full flow)');
      await apiSources.createTeamAndRegisterToRace(
        team: team,
        memberIds: memberIds,
        raceId: raceId,
      );
      print('✅ API success');
      
      // Sync to local
      try {
        await localSources.createTeamAndRegisterToRace(
          team: team,
          memberIds: memberIds,
          raceId: raceId,
        );
        print('💾 Synced to local');
      } catch (e) {
        print('⚠️ Local sync failed: $e');
      }
    } catch (e) {
      print('⚠️ API failed, fallback to local: $e');
      await localSources.createTeamAndRegisterToRace(
        team: team,
        memberIds: memberIds,
        raceId: raceId,
      );
    }
  }

  @override
  Future<Map<String, dynamic>?> getRaceDetails(int raceId) async {
    try {
      print('🌐 API: getRaceDetails');
      final details = await apiSources.getRaceDetails(raceId);
      print('✅ API success');
      return details;
    } catch (e) {
      print('⚠️ API failed, fallback to local: $e');
      return await localSources.getRaceDetails(raceId);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getUserConflictingRaces(
    int userId,
    int raceId,
  ) async {
    try {
      print('🌐 API: getUserConflictingRaces');
      final conflicts = await apiSources.getUserConflictingRaces(userId, raceId);
      print('✅ API success');
      return conflicts;
    } catch (e) {
      print('⚠️ API failed (not implemented), fallback to local: $e');
      return await localSources.getUserConflictingRaces(userId, raceId);
    }
  }
}
