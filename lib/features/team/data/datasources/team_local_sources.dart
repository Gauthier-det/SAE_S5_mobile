// lib/features/teams/data/datasources/team_local_sources.dart
import 'package:sae5_g13_mobile/features/team/domain/team.dart';
import '../../../../core/database/database_helper.dart';
import 'package:sqflite/sqflite.dart';

/// SQLite data source for team operations.
///
/// Handles team CRUD, member management, race registration, and validation.
/// Enforces business rules: age ≥12, gender matching, time conflict detection
/// [web:186][web:189][web:200].
///
/// **Key Features:**
/// - Team-race registration with auto-generated dossard numbers
/// - Member availability filtering (age, gender, conflicts)
/// - Validation state management (TER_IS_VALID)
/// - Access control checks (member/creator/manager)
/// - PPS form and chip number tracking
///
/// Example:
/// ```dart
/// final localSource = TeamLocalSources();
/// final teams = await localSource.getRaceTeams(raceId);
/// await localSource.validateTeamForRace(teamId, raceId);
/// ```
class TeamLocalSources {
  /// Upserts user data into SAN_USERS table.
  Future<void> upsertUser(Map<String, dynamic> userData) async {
    final db = await DatabaseHelper.database;
    await db.insert(
      'SAN_USERS',
      userData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Fetches teams registered to a race with validation status [web:186].
  Future<List<Map<String, dynamic>>> getRaceTeams(int raceId) async {
    final db = await DatabaseHelper.database;

    return await db.rawQuery(
      '''
      SELECT t.*, tr.TER_IS_VALID
      FROM SAN_TEAMS t
      INNER JOIN SAN_TEAMS_RACES tr ON t.TEA_ID = tr.TEA_ID
      WHERE tr.RAC_ID = ?
      ORDER BY t.TEA_NAME
    ''',
      [raceId],
    );
  }

  /// Fetches single team by ID.
  Future<Map<String, dynamic>?> getTeamById(int teamId) async {
    final db = await DatabaseHelper.database;
    final result = await db.query(
      'SAN_TEAMS',
      where: 'TEA_ID = ?',
      whereArgs: [teamId],
      limit: 1,
    );

    return result.isEmpty ? null : result.first;
  }

  /// Creates new team. Strips race-specific fields before insert.
  Future<int> createTeam(Map<String, dynamic> teamData) async {
    final db = await DatabaseHelper.database;
    // Clean data to keep only SAN_TEAMS columns
    final dataToInsert = Map<String, dynamic>.from(teamData);
    dataToInsert.remove('TER_IS_VALID');
    dataToInsert.remove('race_number');

    return await db.insert(
      'SAN_TEAMS',
      dataToInsert,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Adds user to team via SAN_USERS_TEAMS junction table.
  Future<void> addTeamMember(int teamId, int userId) async {
    final db = await DatabaseHelper.database;
    await db.insert('SAN_USERS_TEAMS', {
      'TEA_ID': teamId,
      'USE_ID': userId,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  /// Registers team to race with auto-generated dossard number [web:200].
  Future<void> registerTeamToRace(int teamId, int raceId) async {
    final db = await DatabaseHelper.database;
    final result = await db.rawQuery(
      '''
      SELECT TER_RACE_NUMBER +1 FROM SAN_TEAMS_RACES
      WHERE RAC_ID = ?
    ''',
      [raceId],
    );
    int nextNumber;
    if (result.isEmpty) {
      nextNumber = 1;
    } else {
      nextNumber = (result.first.values.first as int?) ?? 1;
    }

    await db.insert('SAN_TEAMS_RACES', {
      'TEA_ID': teamId,
      'RAC_ID': raceId,
      'TER_IS_VALID': 0,
      'TER_RACE_NUMBER': nextNumber,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  /// Registers user to race individually (via SAN_USERS_RACES).
  Future<void> registerUserToRace(int userId, int raceId) async {
    final db = await DatabaseHelper.database;

    final existing = await db.query(
      'SAN_USERS_RACES',
      where: 'USE_ID = ? AND RAC_ID = ?',
      whereArgs: [userId, raceId],
    );

    if (existing.isEmpty) {
      await db.insert('SAN_USERS_RACES', {'USE_ID': userId, 'RAC_ID': raceId});
    }
  }

  /// Fetches users eligible for race with filters [web:189][web:200].
  ///
  /// Filters:
  /// - Age ≥ 12 years
  /// - Not already registered
  /// - Gender match (if not Mixte)
  /// - No time conflicts with other races
  Future<List<Map<String, dynamic>>> getAvailableUsersForRace(
    int raceId,
  ) async {
    final db = await DatabaseHelper.database;

    // Fetch race details
    final raceInfo = await db.query(
      'SAN_RACES',
      where: 'RAC_ID = ?',
      whereArgs: [raceId],
      limit: 1,
    );

    if (raceInfo.isEmpty) return [];

    final race = raceInfo.first;
    final raceSex = race['RAC_GENDER'] as String?;
    final raceStart = race['RAC_TIME_START'] as String;
    final raceEnd = race['RAC_TIME_END'] as String;

    // Build gender filter clause
    String genderFilter = '';
    if (raceSex == 'Homme') {
      genderFilter = "AND USE_GENDER = 'Homme'";
    } else if (raceSex == 'Femme') {
      genderFilter = "AND USE_GENDER = 'Femme'";
    }
    // If Mixte, no gender filter

    return await db.rawQuery(
      '''
      SELECT 
        USE_ID, 
        USE_NAME, 
        USE_LAST_NAME, 
        USE_MAIL, 
        USE_BIRTHDATE,
        USE_GENDER,
        ADD_ID, 
        CLU_ID, 
        USE_LICENCE_NUMBER
      FROM SAN_USERS
      WHERE 
        -- At least 12 years old
        (julianday('now') - julianday(USE_BIRTHDATE)) / 365.25 >= 12
        
        -- Not already registered
        AND USE_ID NOT IN (
          SELECT USE_ID 
          FROM SAN_USERS_RACES 
          WHERE RAC_ID = ?
        )
        
        -- Gender filter
        $genderFilter
        
        -- No time conflict
        AND USE_ID NOT IN (
          SELECT DISTINCT ur.USE_ID
          FROM SAN_USERS_RACES ur
          INNER JOIN SAN_RACES r ON ur.RAC_ID = r.RAC_ID
          WHERE r.RAC_ID != ?
            AND (
              (r.RAC_TIME_START < ? AND r.RAC_TIME_END > ?)
              OR (r.RAC_TIME_START >= ? AND r.RAC_TIME_START < ?)
            )
        )
        
      ORDER BY USE_LAST_NAME, USE_NAME
    ''',
      [raceId, raceId, raceEnd, raceStart, raceStart, raceEnd],
    );
  }

  /// Fetches team members with basic user details.
  Future<List<Map<String, dynamic>>> getTeamMembers(int teamId) async {
    final db = await DatabaseHelper.database;

    return await db.rawQuery(
      '''
      SELECT u.USE_ID, u.USE_NAME, u.USE_LAST_NAME, u.USE_MAIL, u.USE_BIRTHDATE,
             u.ADD_ID, u.CLU_ID, u.USE_LICENCE_NUMBER, u.USE_GENDER 
      FROM SAN_USERS u
      INNER JOIN SAN_USERS_TEAMS ut ON u.USE_ID = ut.USE_ID
      WHERE ut.TEA_ID = ?
      ORDER BY u.USE_LAST_NAME, u.USE_NAME
    ''',
      [teamId],
    );
  }

  /// Marks team as validated for race (TER_IS_VALID = 1) [web:186].
  Future<void> validateTeamForRace(int teamId, int raceId) async {
    final db = await DatabaseHelper.database;

    await db.update(
      'SAN_TEAMS_RACES',
      {'TER_IS_VALID': 1},
      where: 'TEA_ID = ? AND RAC_ID = ?',
      whereArgs: [teamId, raceId],
    );
  }

  /// Checks if user can access team details (member/creator/race manager).
  Future<bool> canAccessTeamDetail({
    required int teamId,
    required int raceId,
    required int userId,
  }) async {
    final db = await DatabaseHelper.database;

    // Check if user is team member
    final isMember = await db.query(
      'SAN_USERS_TEAMS',
      where: 'TEA_ID = ? AND USE_ID = ?',
      whereArgs: [teamId, userId],
    );

    if (isMember.isNotEmpty) return true;

    // Check if user is team creator
    final team = await db.query(
      'SAN_TEAMS',
      where: 'TEA_ID = ? AND USE_ID = ?',
      whereArgs: [teamId, userId],
    );

    if (team.isNotEmpty) return true;

    // Check if user is race manager
    final isRaceManager = await db.query(
      'SAN_RACES',
      where: 'RAC_ID = ? AND USE_ID = ?',
      whereArgs: [raceId, userId],
    );

    return isRaceManager.isNotEmpty;
  }

  /// Fetches team's dossard number for specific race [web:200].
  Future<int?> getTeamDossardNumber(int teamId, int raceId) async {
    final db = await DatabaseHelper.database;

    final result = await db.query(
      'SAN_TEAMS_RACES',
      columns: ['TER_RACE_NUMBER'],
      where: 'TEA_ID = ? AND RAC_ID = ?',
      whereArgs: [teamId, raceId],
    );

    if (result.isEmpty) return null;
    return result.first['TER_RACE_NUMBER'] as int?;
  }

  /// Fetches team members with race-specific details (PPS, chip).
  Future<List<Map<String, dynamic>>> getTeamMembersWithRaceDetails(
    int teamId,
    int raceId,
  ) async {
    final db = await DatabaseHelper.database;

    return await db.rawQuery(
      '''
      SELECT 
        u.USE_ID, u.USE_NAME, u.USE_LAST_NAME, u.USE_MAIL, 
        u.USE_BIRTHDATE, u.USE_LICENCE_NUMBER, ur.USR_PPS_FORM,
        ur.USR_CHIP_NUMBER, u.USE_GENDER
      FROM SAN_USERS u
      INNER JOIN SAN_USERS_TEAMS ut ON u.USE_ID = ut.USE_ID
      LEFT JOIN SAN_USERS_RACES ur ON u.USE_ID = ur.USE_ID AND ur.RAC_ID = ?
      WHERE ut.TEA_ID = ?
      ORDER BY u.USE_LAST_NAME, u.USE_NAME
    ''',
      [raceId, teamId],
    );
  }

  /// Marks team as invalidated for race (TER_IS_VALID = 0).
  Future<void> invalidateTeamForRace(int teamId, int raceId) async {
    final db = await DatabaseHelper.database;

    await db.update(
      'SAN_TEAMS_RACES',
      {'TER_IS_VALID': 0},
      where: 'TEA_ID = ? AND RAC_ID = ?',
      whereArgs: [teamId, raceId],
    );
  }

  /// Removes member from team and their race registrations.
  Future<void> removeMemberFromTeam(int teamId, int userId) async {
    final db = await DatabaseHelper.database;

    await db.delete(
      'SAN_USERS_TEAMS',
      where: 'TEA_ID = ? AND USE_ID = ?',
      whereArgs: [teamId, userId],
    );

    await db.delete(
      'SAN_USERS_RACES',
      where:
          'USE_ID = ? AND RAC_ID IN (SELECT RAC_ID FROM SAN_TEAMS_RACES WHERE TEA_ID = ?)',
      whereArgs: [userId, teamId],
    );
  }

  /// Deletes team and all associations (race registrations, members).
  Future<void> deleteTeam(int teamId, int raceId) async {
    final db = await DatabaseHelper.database;

    // Remove from race
    await db.delete(
      'SAN_TEAMS_RACES',
      where: 'TEA_ID = ? AND RAC_ID = ?',
      whereArgs: [teamId, raceId],
    );

    await db.delete(
      'SAN_USERS_RACES',
      where:
          'USE_ID IN (SELECT USE_ID FROM SAN_USERS_TEAMS WHERE TEA_ID = ? and RAC_ID = ?)',
      whereArgs: [teamId, raceId],
    );

    // Remove members
    await db.delete(
      'SAN_USERS_TEAMS',
      where: 'TEA_ID = ?',
      whereArgs: [teamId],
    );

    // Remove team
    await db.delete('SAN_TEAMS', where: 'TEA_ID = ?', whereArgs: [teamId]);
  }

  /// Updates user's PPS form status for race.
  Future<void> updateUserPPS(int userId, String? ppsForm, int raceId) async {
    final db = await DatabaseHelper.database;

    await db.update(
      'SAN_USERS_RACES',
      {'USR_PPS_FORM': ppsForm},
      where: 'USE_ID = ? AND RAC_ID = ?',
      whereArgs: [userId, raceId],
    );
  }

  /// Updates user's chip number for race (upserts if needed).
  Future<void> updateUserChipNumber(
    int userId,
    int raceId,
    int? chipNumber,
  ) async {
    final db = await DatabaseHelper.database;

    final existing = await db.query(
      'SAN_USERS_RACES',
      where: 'USE_ID = ? AND RAC_ID = ?',
      whereArgs: [userId, raceId],
    );

    if (existing.isEmpty) {
      await db.insert('SAN_USERS_RACES', {
        'USE_ID': userId,
        'RAC_ID': raceId,
        'USR_CHIP_NUMBER': chipNumber,
      });
    } else {
      await db.update(
        'SAN_USERS_RACES',
        {'USR_CHIP_NUMBER': chipNumber},
        where: 'USE_ID = ? AND RAC_ID = ?',
        whereArgs: [userId, raceId],
      );
    }
  }

  /// Atomic transaction: creates team and registers to race [web:200].
  ///
  /// Steps: Creates team → Adds members → Generates dossard → Registers to race → Registers members individually.
  Future<void> createTeamAndRegisterToRace({
    required Team team,
    required List<int> memberIds,
    required int raceId,
  }) async {
    final db = await DatabaseHelper.database;

    // 1. Create team
    final teamId = await db.insert('SAN_TEAMS', {
      'TEA_ID': team.id,
      'USE_ID': team.managerId,
      'TEA_NAME': team.name,
      'TEA_IMAGE': team.image,
    });

    // 2. Add members to team
    for (final userId in memberIds) {
      await db.insert('SAN_USERS_TEAMS', {'TEA_ID': teamId, 'USE_ID': userId});
    }

    // 3. Generate dossard number
    final result = await db.rawQuery(
      '''
      SELECT COALESCE(MAX(TER_RACE_NUMBER), 0) + 1 as next_number
      FROM SAN_TEAMS_RACES
      WHERE RAC_ID = ?
    ''',
      [raceId],
    );

    final nextDossardNumber = result.first['next_number'] as int;

    // 4. Register team to race
    await db.insert('SAN_TEAMS_RACES', {
      'TEA_ID': teamId,
      'RAC_ID': raceId,
      'TER_IS_VALID': 0,
      'TER_RACE_NUMBER': nextDossardNumber,
      'TER_TIME': null,
    });

    // 5. Register all members to race individually
    for (final userId in memberIds) {
      final existing = await db.query(
        'SAN_USERS_RACES',
        where: 'USE_ID = ? AND RAC_ID = ?',
        whereArgs: [userId, raceId],
      );

      if (existing.isEmpty) {
        await db.insert('SAN_USERS_RACES', {
          'USE_ID': userId,
          'RAC_ID': raceId,
        });
      }
    }
  }

  /// Fetches team with validation status for specific race [web:186].
  Future<Team?> getTeamByIdWithRaceStatus(int teamId, int raceId) async {
    final db = await DatabaseHelper.database;

    final result = await db.rawQuery(
      '''
      SELECT 
        t.*,
        ter.TER_IS_VALID as isValid,
        ter.TER_RACE_NUMBER as dossardNumber
      FROM SAN_TEAMS t
      LEFT JOIN SAN_TEAMS_RACES ter ON t.TEA_ID = ter.TEA_ID AND ter.RAC_ID = ?
      WHERE t.TEA_ID = ?
      LIMIT 1
    ''',
      [raceId, teamId],
    );

    if (result.isEmpty) return null;

    final teamData = result.first;

    return Team(
      id: teamData['TEA_ID'] as int,
      name: teamData['TEA_NAME'] as String,
      managerId: teamData['USE_ID'] as int,
      isValid: teamData['isValid'] == 1,
    );
  }

  /// Fetches race details by ID.
  Future<Map<String, dynamic>?> getRaceDetails(int raceId) async {
    final db = await DatabaseHelper.database;

    final result = await db.query(
      'SAN_RACES',
      where: 'RAC_ID = ?',
      whereArgs: [raceId],
      limit: 1,
    );

    return result.isEmpty ? null : result.first;
  }

  /// Fetches user's races that conflict with target race timing.
  Future<List<Map<String, dynamic>>> getUserConflictingRaces(
    int userId,
    int raceId,
  ) async {
    final db = await DatabaseHelper.database;

    // Fetch target race timing
    final targetRace = await db.query(
      'SAN_RACES',
      where: 'RAC_ID = ?',
      whereArgs: [raceId],
      limit: 1,
    );

    if (targetRace.isEmpty) return [];

    final startTime = targetRace.first['RAC_START_TIME'] as String;
    final endTime = targetRace.first['RAC_END_TIME'] as String;

    // Find overlapping races where user is registered
    return await db.rawQuery(
      '''
      SELECT r.RAC_ID, r.RAC_NAME, r.RAC_START_TIME, r.RAC_END_TIME
      FROM SAN_RACES r
      INNER JOIN SAN_USERS_RACES ur ON r.RAC_ID = ur.RAC_ID
      WHERE ur.USE_ID = ?
        AND r.RAC_ID != ?
        AND (
          -- Overlapping races
          (r.RAC_START_TIME < ? AND r.RAC_END_TIME > ?)
          OR (r.RAC_START_TIME >= ? AND r.RAC_START_TIME < ?)
        )
    ''',
      [userId, raceId, endTime, startTime, startTime, endTime],
    );
  }
}
