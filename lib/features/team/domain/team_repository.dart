// lib/features/teams/domain/team_repository.dart
import 'team.dart';
import '../../user/domain/user.dart';

abstract class TeamRepository {
  Future<List<Team>> getRaceTeams(int raceId);
  Future<Team?> getTeamById(int teamId);
  Future<int> createTeam(Map<String, dynamic> teamData);
  Future<void> addTeamMember(int teamId, int userId, {int? raceId});
  Future<void> registerTeamToRace(int teamId, int raceId);
  Future<void> registerUserToRace(int userId, int raceId);
  Future<List<User>> getAvailableUsersForRace(int raceId);
  Future<List<User>> getTeamMembers(int teamId);
  Future<void> validateTeamForRace(int teamId, int raceId);
  Future<bool> canAccessTeamDetail({
    required int teamId,
    required int raceId,
    required int userId,
  });
  Future<Team?> getTeamByIdWithRaceStatus(int teamId, int raceId);
  Future<int?> getTeamDossardNumber(int teamId, int raceId);
  Future<List<Map<String, dynamic>>> getTeamMembersWithRaceDetails(
    int teamId,
    int raceId,
  );
  Future<void> invalidateTeamForRace(int teamId, int raceId);
  Future<void> removeMemberFromTeam(int teamId, int userId, {int? raceId});
  Future<void> deleteTeam(int teamId, int raceId);
  Future<void> updateUserPPS(
    int userId,
    String? ppsForm,
    int raceId,
    int teamId,
  );
  Future<void> updateUserChipNumber(
    int userId,
    int raceId,
    int? chipNumber,
    int teamId,
  );
  Future<Map<String, dynamic>?> getRaceDetails(int raceId);
  Future<List<Map<String, dynamic>>> getUserConflictingRaces(
    int userId,
    int raceId,
  );

  Future<void> createTeamAndRegisterToRace({
    required Team team,
    required List<int> memberIds,
    required int raceId,
  });

  Future<void> syncPendingActions();
}
