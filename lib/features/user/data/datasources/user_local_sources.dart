// lib/features/users/data/datasources/user_local_sources.dart
import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../../domain/user.dart';

class UserLocalSources {
  /// Gets the club ID if user is a club manager
  /// Returns null if user is not a club manager
  Future<int?> getUserClubId(int userId) async {
    final db = await DatabaseHelper.database;
    
    // Check if user is club manager (their USE_ID is in SAN_CLUBS)
    final List<Map<String, dynamic>> maps = await db.query(
      'SAN_CLUBS',
      columns: ['CLU_ID'],
      where: 'USE_ID = ?',
      whereArgs: [userId],
      limit: 1,
    );
    
    if (maps.isEmpty) return null;
    
    return maps.first['CLU_ID'] as int;
  }

  /// Gets user by ID
  Future<User?> getUserById(int userId) async {
    final db = await DatabaseHelper.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'SAN_USERS',
      where: 'USE_ID = ?',
      whereArgs: [userId],
    );
    
    if (maps.isEmpty) return null;
    
    return User.fromJson(maps.first);
  }
}