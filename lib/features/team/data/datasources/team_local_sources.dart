// lib/features/teams/data/datasources/team_local_sources.dart
import 'package:sae5_g13_mobile/features/team/domain/team.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';

class TeamLocalSources {
  Future<List<Map<String, dynamic>>> getRaceTeams(int raceId) async {
    final db = await DatabaseHelper.database;
    
    return await db.rawQuery('''
      SELECT t.*, tr.TER_IS_VALID
      FROM SAN_TEAMS t
      INNER JOIN SAN_TEAMS_RACES tr ON t.TEA_ID = tr.TEA_ID
      WHERE tr.RAC_ID = ?
      ORDER BY t.TEA_NAME
    ''', [raceId]);
  }

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

  Future<int> createTeam(Map<String, dynamic> teamData) async {
    final db = await DatabaseHelper.database;
    return await db.insert('SAN_TEAMS', teamData);
  }

  Future<void> addTeamMember(int teamId, int userId) async {
    final db = await DatabaseHelper.database;
    await db.insert('SAN_USERS_TEAMS', {
      'TEA_ID': teamId,
      'USE_ID': userId,
    });
  }

  Future<void> registerTeamToRace(int teamId, int raceId) async {
    final db = await DatabaseHelper.database;
    final result = await db.rawQuery('''
      SELECT TER_RACE_NUMBER +1 FROM SAN_TEAMS_RACES
      WHERE RAC_ID = ?
    ''', [raceId]);
    int nextNumber;
    if (result.isEmpty) {
      nextNumber = 1;
    } else {
      nextNumber = result.first.values.first as int;
    }

    await db.insert('SAN_TEAMS_RACES', {
      'TEA_ID': teamId,
      'RAC_ID': raceId,
      'TER_IS_VALID': 0, 
      'TER_RACE_NUMBER': nextNumber// Non validé par défaut
    });
  }

  Future<void> registerUserToRace(int userId, int raceId) async {
    final db = await DatabaseHelper.database;
    
    // Vérifier si l'utilisateur n'est pas déjà inscrit
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

  // Remplace getAvailableUsersForRace par cette version améliorée
  Future<List<Map<String, dynamic>>> getAvailableUsersForRace(int raceId) async {
    final db = await DatabaseHelper.database;
    
    // Récupérer les infos de la course
    final raceInfo = await db.query(
      'SAN_RACES',
      where: 'RAC_ID = ?',
      whereArgs: [raceId],
      limit: 1,
    );
    
    if (raceInfo.isEmpty) return [];
    
    final race = raceInfo.first;
    final raceSex = race['RAC_SEX'] as String?;
    final raceStart = race['RAC_TIME_START'] as String;
    final raceEnd = race['RAC_TIME_END'] as String;
    
    // Construire la clause WHERE pour le genre
    String genderFilter = '';
    if (raceSex == 'Masculin') {
      genderFilter = "AND USE_SEX = 'Masculin'";
    } else if (raceSex == 'Féminin') {
      genderFilter = "AND USE_SEX = 'Féminin'";
    }
    // Si Mixte ou autre, pas de filtre (tous les genres acceptés)
    
    return await db.rawQuery('''
      SELECT 
        USE_ID, 
        USE_NAME, 
        USE_LAST_NAME, 
        USE_MAIL, 
        USE_BIRTHDATE,
        USE_SEX,
        ADD_ID, 
        CLU_ID, 
        USE_LICENCE_NUMBER
      FROM SAN_USERS
      WHERE 
        -- Au moins 12 ans
        (julianday('now') - julianday(USE_BIRTHDATE)) / 365.25 >= 12
        
        -- Pas déjà inscrit à cette course
        AND USE_ID NOT IN (
          SELECT USE_ID 
          FROM SAN_USERS_RACES 
          WHERE RAC_ID = ?
        )
        
        -- Filtre de genre
        $genderFilter
        
        -- Pas de conflit horaire avec d'autres courses
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
    ''', [raceId, raceId, raceEnd, raceStart, raceStart, raceEnd]);
  }


  Future<List<Map<String, dynamic>>> getTeamMembers(int teamId) async {
    final db = await DatabaseHelper.database;
    
    return await db.rawQuery('''
      SELECT u.USE_ID, u.USE_NAME, u.USE_LAST_NAME, u.USE_MAIL, u.USE_BIRTHDATE,
             u.ADD_ID, u.CLU_ID, u.USE_LICENCE_NUMBER, u.USE_SEX 
      FROM SAN_USERS u
      INNER JOIN SAN_USERS_TEAMS ut ON u.USE_ID = ut.USE_ID
      WHERE ut.TEA_ID = ?
      ORDER BY u.USE_LAST_NAME, u.USE_NAME
    ''', [teamId]);
  }

  Future<void> validateTeamForRace(int teamId, int raceId) async {
    final db = await DatabaseHelper.database;
    
    await db.update(
      'SAN_TEAMS_RACES',
      {'TER_IS_VALID': 1},
      where: 'TEA_ID = ? AND RAC_ID = ?',
      whereArgs: [teamId, raceId],
    );
  }

  Future<bool> canAccessTeamDetail({
    required int teamId,
    required int raceId,
    required int userId,
  }) async {
    final db = await DatabaseHelper.database;
    
    // Vérifier si l'utilisateur est membre de l'équipe
    final isMember = await db.query(
      'SAN_USERS_TEAMS',
      where: 'TEA_ID = ? AND USE_ID = ?',
      whereArgs: [teamId, userId],
    );
    
    if (isMember.isNotEmpty) return true;
    
    // Vérifier si l'utilisateur est le créateur
    final team = await db.query(
      'SAN_TEAMS',
      where: 'TEA_ID = ? AND USE_ID = ?',
      whereArgs: [teamId, userId],
    );
    
    if (team.isNotEmpty) return true;
    
    // Vérifier si l'utilisateur est responsable de la course
    final isRaceManager = await db.query(
      'SAN_RACES',
      where: 'RAC_ID = ? AND USE_ID = ?',
      whereArgs: [raceId, userId],
    );
    
    return isRaceManager.isNotEmpty;
  }
  
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

  Future<List<Map<String, dynamic>>> getTeamMembersWithRaceDetails(
    int teamId,
    int raceId,
  ) async {
    final db = await DatabaseHelper.database;
    
    return await db.rawQuery('''
      SELECT 
        u.USE_ID, u.USE_NAME, u.USE_LAST_NAME, u.USE_MAIL, 
        u.USE_BIRTHDATE, u.USE_LICENCE_NUMBER, ur.USR_PPS_FORM,
        ur.USR_CHIP_NUMBER, u.USE_SEX
      FROM SAN_USERS u
      INNER JOIN SAN_USERS_TEAMS ut ON u.USE_ID = ut.USE_ID
      LEFT JOIN SAN_USERS_RACES ur ON u.USE_ID = ur.USE_ID AND ur.RAC_ID = ?
      WHERE ut.TEA_ID = ?
      ORDER BY u.USE_LAST_NAME, u.USE_NAME
    ''', [raceId, teamId]);
  }

  Future<void> invalidateTeamForRace(int teamId, int raceId) async {
    final db = await DatabaseHelper.database;
    
    await db.update(
      'SAN_TEAMS_RACES',
      {'TER_IS_VALID': 0},
      where: 'TEA_ID = ? AND RAC_ID = ?',
      whereArgs: [teamId, raceId],
    );
  }

  Future<void> removeMemberFromTeam(int teamId, int userId) async {
    final db = await DatabaseHelper.database;
    
    await db.delete(
      'SAN_USERS_TEAMS',
      where: 'TEA_ID = ? AND USE_ID = ?',
      whereArgs: [teamId, userId],
    );

    await db.delete(
      'SAN_USERS_RACES',
      where: 'USE_ID = ? AND RAC_ID IN (SELECT RAC_ID FROM SAN_TEAMS_RACES WHERE TEA_ID = ?)',
      whereArgs: [userId, teamId],
    );
  }

  Future<void> deleteTeam(int teamId, int raceId) async {
    final db = await DatabaseHelper.database;
    
    // Supprimer de la course
    await db.delete(
      'SAN_TEAMS_RACES',
      where: 'TEA_ID = ? AND RAC_ID = ?',
      whereArgs: [teamId, raceId],
    );

    await db.delete(
      'SAN_USERS_RACES',
      where: 'USE_ID IN (SELECT USE_ID FROM SAN_USERS_TEAMS WHERE TEA_ID = ? and RAC_ID = ?)',
      whereArgs: [teamId, raceId],
    );
    
    // Supprimer les membres
    await db.delete(
      'SAN_USERS_TEAMS',
      where: 'TEA_ID = ?',
      whereArgs: [teamId],
    );
    
    // Supprimer l'équipe
    await db.delete(
      'SAN_TEAMS',
      where: 'TEA_ID = ?',
      whereArgs: [teamId],
    );
  }

  Future<void> updateUserPPS(int userId, String? ppsForm, int raceId) async {
    final db = await DatabaseHelper.database;
    
    await db.update(
      'SAN_USERS_RACES',
      {'USR_PPS_FORM': ppsForm},
      where: 'USE_ID = ? AND RAC_ID = ?',
      whereArgs: [userId, raceId],
    );
  }

  Future<void> updateUserChipNumber(int userId, int raceId, int? chipNumber) async {
    final db = await DatabaseHelper.database;
    
    // Vérifier si l'utilisateur est déjà inscrit à la course
    final existing = await db.query(
      'SAN_USERS_RACES',
      where: 'USE_ID = ? AND RAC_ID = ?',
      whereArgs: [userId, raceId],
    );
    
    if (existing.isEmpty) {
      // Créer l'inscription
      await db.insert('SAN_USERS_RACES', {
        'USE_ID': userId,
        'RAC_ID': raceId,
        'USR_CHIP_NUMBER': chipNumber,
      });
    } else {
      // Mettre à jour
      await db.update(
        'SAN_USERS_RACES',
        {'USR_CHIP_NUMBER': chipNumber},
        where: 'USE_ID = ? AND RAC_ID = ?',
        whereArgs: [userId, raceId],
      );
    }
  }

  Future<void> createTeamAndRegisterToRace({
    required Team team,
    required List<int> memberIds,
    required int raceId,
  }) async {
    final db = await DatabaseHelper.database;

    // 1. Créer l'équipe
    final teamId = await db.insert('SAN_TEAMS', {
      'TEA_ID': team.id,
      'USE_ID': team.managerId,
      'TEA_NAME': team.name,
      'TEA_IMAGE': team.image,
    });

    // 2. Ajouter les membres à l'équipe
    for (final userId in memberIds) {
      await db.insert('SAN_USERS_TEAMS', {
        'TEA_ID': teamId,
        'USE_ID': userId,
      });
    }

    // 3. Générer le numéro de dossard
    final result = await db.rawQuery('''
      SELECT COALESCE(MAX(TER_RACE_NUMBER), 0) + 1 as next_number
      FROM SAN_TEAMS_RACES
      WHERE RAC_ID = ?
    ''', [raceId]);

    final nextDossardNumber = result.first['next_number'] as int;

    // 4. Inscrire l'équipe à la course
    await db.insert('SAN_TEAMS_RACES', {
      'TEA_ID': teamId,
      'RAC_ID': raceId,
      'TER_IS_VALID': 0,
      'TER_RACE_NUMBER': nextDossardNumber,
      'TER_TIME': null,
    });

    // 5. Inscrire tous les membres à la course individuellement
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

  // ✅ NOUVELLE MÉTHODE : Récupère l'équipe avec son statut pour une course
  Future<Team?> getTeamByIdWithRaceStatus(int teamId, int raceId) async {
    final db = await DatabaseHelper.database;
    
    final result = await db.rawQuery('''
      SELECT 
        t.*,
        ter.TER_IS_VALID as isValid,
        ter.TER_RACE_NUMBER as dossardNumber
      FROM SAN_TEAMS t
      LEFT JOIN SAN_TEAMS_RACES ter ON t.TEA_ID = ter.TEA_ID AND ter.RAC_ID = ?
      WHERE t.TEA_ID = ?
      LIMIT 1
    ''', [raceId, teamId]);
    
    if (result.isEmpty) return null;
    
    final teamData = result.first;
    
    print('📊 Team data from DB: $teamData');
    
    // ✅ Créer l'équipe avec le statut de validation
    return Team(
      id: teamData['TEA_ID'] as int,
      name: teamData['TEA_NAME'] as String,
      managerId: teamData['USE_ID'] as int,
      isValid: teamData['isValid'] == 1, // ✅ Récupéré depuis SAN_TEAMS_RACES
    );
  }

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

  Future<List<Map<String, dynamic>>> getUserConflictingRaces(
    int userId, 
    int raceId,
  ) async {
    final db = await DatabaseHelper.database;
    
    // Récupérer les horaires de la course cible
    final targetRace = await db.query(
      'SAN_RACES',
      where: 'RAC_ID = ?',
      whereArgs: [raceId],
      limit: 1,
    );
  
    if (targetRace.isEmpty) return [];
    
    final startTime = targetRace.first['RAC_START_TIME'] as String;
    final endTime = targetRace.first['RAC_END_TIME'] as String;
    
    // Trouver les courses où l'utilisateur est inscrit qui se chevauchent
    return await db.rawQuery('''
      SELECT r.RAC_ID, r.RAC_NAME, r.RAC_START_TIME, r.RAC_END_TIME
      FROM SAN_RACES r
      INNER JOIN SAN_USERS_RACES ur ON r.RAC_ID = ur.RAC_ID
      WHERE ur.USE_ID = ?
        AND r.RAC_ID != ?
        AND (
          -- La course chevauche
          (r.RAC_START_TIME < ? AND r.RAC_END_TIME > ?)
          OR (r.RAC_START_TIME >= ? AND r.RAC_START_TIME < ?)
        )
    ''', [userId, raceId, endTime, startTime, startTime, endTime]);
  }


}
