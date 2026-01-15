// lib/features/club/data/datasources/club_local_sources.dart
import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../../domain/club.dart';
import '../../../user/domain/user.dart';

class ClubLocalSources {
  /// Gets all clubs with their responsible person
  Future<List<Club>> getAllClubs() async {
    final db = await DatabaseHelper.database;

    // JOIN avec SAN_USERS pour obtenir le nom du responsable
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT c.CLU_ID, c.CLU_NAME, c.USE_ID, c.ADD_ID,
             u.USE_NAME, u.USE_LAST_NAME
      FROM SAN_CLUBS c
      LEFT JOIN SAN_USERS u ON c.USE_ID = u.USE_ID
      ORDER BY c.CLU_NAME
    ''');

    return maps.map((map) => Club.fromJson(map)).toList();
  }

  /// Gets all members of a club
  Future<List<User>> getClubMembers(int clubId) async {
    final db = await DatabaseHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'SAN_USERS',
      where: 'CLU_ID = ?',
      whereArgs: [clubId],
      orderBy: 'USE_NAME, USE_LAST_NAME',
    );

    return maps.map((map) => User.fromJson(map)).toList();
  }

  /// Gets club by ID with responsible info
  Future<Club?> getClubById(int clubId) async {
    final db = await DatabaseHelper.database;

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT c.CLU_ID, c.CLU_NAME, c.USE_ID, c.ADD_ID,
             u.USE_NAME, u.USE_LAST_NAME
      FROM SAN_CLUBS c
      LEFT JOIN SAN_USERS u ON c.USE_ID = u.USE_ID
      WHERE c.CLU_ID = ?
    ''',
      [clubId],
    );

    if (maps.isEmpty) return null;

    return Club.fromJson(maps.first);
  }

  /// Inserts or updates a club in local database
  Future<void> insertClub(Club club) async {
    final db = await DatabaseHelper.database;
    await db.insert(
      'SAN_CLUBS',
      club.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Inserts or updates multiple clubs in local database
  Future<void> insertClubs(List<Club> clubs) async {
    final db = await DatabaseHelper.database;
    final batch = db.batch();
    for (final club in clubs) {
      batch.insert(
        'SAN_CLUBS',
        club.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }
}
