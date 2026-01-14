// lib/features/teams/data/repositories/team_repository_impl.dart
import 'package:sae5_g13_mobile/features/team/data/datasources/team_api_sources.dart';

import '../../domain/team.dart';
import '../../domain/team_repository.dart';
import '../datasources/team_local_sources.dart';
import '../../../user/domain/user.dart';

class TeamRepositoryImpl implements TeamRepository {
  final TeamLocalSources localSources;
  final TeamApiSources apiSources;

  TeamRepositoryImpl({required this.localSources, required this.apiSources});

  @override
  Future<List<Team>> getRaceTeams(int raceId) async {
    final maps = await localSources.getRaceTeams(raceId);
    return maps.map((map) => Team.fromJson(map)).toList();
  }

  @override
  Future<Team?> getTeamById(int teamId) async {
    final map = await localSources.getTeamById(teamId);
    return map != null ? Team.fromJson(map) : null;
  }

  @override
  Future<int> createTeam(Map<String, dynamic> teamData) async {
    return await localSources.createTeam(teamData);
  }

  @override
  Future<void> addTeamMember(int teamId, int userId) async {
    await localSources.addTeamMember(teamId, userId);
  }

  @override
  Future<void> registerTeamToRace(int teamId, int raceId) async {
    await localSources.registerTeamToRace(teamId, raceId);
  }

  @override
  Future<void> registerUserToRace(int userId, int raceId) async {
    await localSources.registerUserToRace(userId, raceId);
  }

  @override
  Future<List<User>> getAvailableUsersForRace(int raceId) async {
    final maps = await localSources.getAvailableUsersForRace(raceId);
    return maps.map((map) => User.fromJson(map)).toList();
  }

  @override
  Future<List<User>> getTeamMembers(int teamId) async {
    final maps = await localSources.getTeamMembers(teamId);
    return maps.map((map) => User.fromJson(map)).toList();
  }

  @override
  Future<void> validateTeamForRace(int teamId, int raceId) async {
    await localSources.validateTeamForRace(teamId, raceId);
  }

  @override
  Future<bool> canAccessTeamDetail({
    required int teamId,
    required int raceId,
    required int userId,
  }) async {
    return await localSources.canAccessTeamDetail(
      teamId: teamId,
      raceId: raceId,
      userId: userId,
    );
  }

  // Nouvelles implémentations
  @override
  Future<int?> getTeamDossardNumber(int teamId, int raceId) async {
    return await localSources.getTeamDossardNumber(teamId, raceId);
  }

  @override
  Future<List<Map<String, dynamic>>> getTeamMembersWithRaceDetails(
    int teamId,
    int raceId,
  ) async {
    return await localSources.getTeamMembersWithRaceDetails(teamId, raceId);
  }

  @override
  Future<void> invalidateTeamForRace(int teamId, int raceId) async {
    await localSources.invalidateTeamForRace(teamId, raceId);
  }

  @override
  Future<void> removeMemberFromTeam(int teamId, int userId) async {
    await localSources.removeMemberFromTeam(teamId, userId);
  }

  @override
  Future<void> deleteTeam(int teamId, int raceId) async {
    await localSources.deleteTeam(teamId, raceId);
  }

  @override
  Future<void> updateUserPPS(int userId, String? ppsForm) async {
    await localSources.updateUserPPS(userId, ppsForm);
  }

  @override
  Future<void> updateUserChipNumber(int userId, int raceId, int? chipNumber) async {
    await localSources.updateUserChipNumber(userId, raceId, chipNumber);
  }

  @override
  Future<void> createTeamAndRegisterToRace({
    required Team team,
    required List<int> memberIds,
    required int raceId,
  }) async {
    await localSources.createTeamAndRegisterToRace(
      team: team,
      memberIds: memberIds,
      raceId: raceId,
    );
  }

}
