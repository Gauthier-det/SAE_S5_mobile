// lib/features/teams/domain/team_repository.dart
import 'team.dart';
import '../../user/domain/user.dart';

/// Repository contract for team operations in domain layer [web:113][web:194][web:201].
///
/// Defines team CRUD, membership management, race registration, and validation
/// operations. Implemented in data layer with API-first, local-fallback strategy.
/// Part of clean architecture's dependency inversion principle [web:198][web:113].
///
/// **Operation Groups:**
/// - Team CRUD: getRaceTeams, getTeamById, createTeam, deleteTeam
/// - Membership: addTeamMember, removeMemberFromTeam, getTeamMembers
/// - Race Registration: registerTeamToRace, registerUserToRace
/// - Validation: validateTeamForRace, invalidateTeamForRace
/// - Race Details: getTeamDossardNumber, getTeamMembersWithRaceDetails
/// - Eligibility: getAvailableUsersForRace, getUserConflictingRaces
/// - Access Control: canAccessTeamDetail
/// - Member Details: updateUserPPS, updateUserChipNumber
///
/// Example:
/// ```dart
/// // Injected via dependency injection
/// class TeamBloc {
///   final TeamRepository repository;
///   TeamBloc(this.repository);
///   
///   Future<void> createTeam(Team team, List<int> members, int raceId) async {
///     await repository.createTeamAndRegisterToRace(
///       team: team, memberIds: members, raceId: raceId
///     );
///   }
/// }
/// ```
abstract class TeamRepository {
  /// Fetches teams registered to a race.
  Future<List<Team>> getRaceTeams(int raceId);

  /// Fetches team by ID (without race context).
  Future<Team?> getTeamById(int teamId);

  /// Creates team and returns generated ID.
  Future<int> createTeam(Map<String, dynamic> teamData);

  /// Adds member to team, optionally registers to race.
  Future<void> addTeamMember(int teamId, int userId, {int? raceId});

  /// Registers existing team to race.
  Future<void> registerTeamToRace(int teamId, int raceId);

  /// Registers user to race individually.
  Future<void> registerUserToRace(int userId, int raceId);

  /// Fetches users eligible for race (age, gender, conflicts checked).
  Future<List<User>> getAvailableUsersForRace(int raceId);

  /// Fetches team members without race context.
  Future<List<User>> getTeamMembers(int teamId);

  /// Marks team as validated for race (TER_IS_VALID = 1).
  Future<void> validateTeamForRace(int teamId, int raceId);

  /// Checks if user can view team details (member/creator/manager).
  Future<bool> canAccessTeamDetail({
    required int teamId,
    required int raceId,
    required int userId,
  });

  /// Fetches team with validation status for specific race.
  Future<Team?> getTeamByIdWithRaceStatus(int teamId, int raceId);

  /// Fetches team's dossard number for race.
  Future<int?> getTeamDossardNumber(int teamId, int raceId);

  /// Fetches team members with race-specific details (PPS, chip).
  Future<List<Map<String, dynamic>>> getTeamMembersWithRaceDetails(
    int teamId,
    int raceId,
  );

  /// Marks team as invalidated for race (TER_IS_VALID = 0).
  Future<void> invalidateTeamForRace(int teamId, int raceId);

  /// Removes member from team and race registrations.
  Future<void> removeMemberFromTeam(int teamId, int userId, {int? raceId});

  /// Deletes team and all associations for specific race.
  Future<void> deleteTeam(int teamId, int raceId);

  /// Updates user's PPS form status for race.
  Future<void> updateUserPPS(
    int userId,
    String? ppsForm,
    int raceId,
    int teamId,
  );

  /// Updates user's chip number for race.
  Future<void> updateUserChipNumber(
    int userId,
    int raceId,
    int? chipNumber,
    int teamId,
  );

  /// Fetches race details by ID.
  Future<Map<String, dynamic>?> getRaceDetails(int raceId);

  /// Fetches user's races with time conflicts.
  Future<List<Map<String, dynamic>>> getUserConflictingRaces(
    int userId,
    int raceId,
  );

  /// Atomic operation: creates team and registers to race with members.
  Future<void> createTeamAndRegisterToRace({
    required Team team,
    required List<int> memberIds,
    required int raceId,
  });
}
