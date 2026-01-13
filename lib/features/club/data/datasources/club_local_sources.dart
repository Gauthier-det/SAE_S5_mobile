// lib/features/clubs/data/datasources/club_local_sources.dart
import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../../domain/club.dart';
import '../../../../features/user/domain/user.dart';

class ClubLocalSources {
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

  /// Gets club by ID with address
  Future<Club?> getClubById(int clubId) async {
    final db = await DatabaseHelper.database;
    
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        c.*,
        a.ADD_POSTAL_CODE,
        a.ADD_CITY,
        a.ADD_STREET_NAME,
        a.ADD_STREET_NUMBER
      FROM SAN_CLUBS c
      LEFT JOIN SAN_ADDRESSES a ON c.ADD_ID = a.ADD_ID
      WHERE c.CLU_ID = ?
    ''', [clubId]);
    
    if (maps.isEmpty) return null;
    
    return Club.fromJson(maps.first);
  }
}
