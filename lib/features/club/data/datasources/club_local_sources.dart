// lib/features/club/data/datasources/club_local_sources.dart
import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../../domain/club.dart';
import '../../../user/domain/user.dart';

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

  /// Gets club by ID
  Future<Club?> getClubById(int clubId) async {
    final db = await DatabaseHelper.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'SAN_CLUBS',
      where: 'CLU_ID = ?',
      whereArgs: [clubId],
    );
    
    if (maps.isEmpty) return null;
    
    return Club.fromJson(maps.first);
  }
}
