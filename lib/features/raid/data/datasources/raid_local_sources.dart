// lib/features/raids/data/datasources/raid_local_sources.dart
import 'package:sae5_g13_mobile/core/database/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import '../../../raid/domain/raid.dart';
import 'package:sae5_g13_mobile/features/user/domain/user.dart';

class RaidLocalSources {
  /// Fetches all raids with their addresses and manager names (JOIN query)
  Future<List<Raid>> getAllRaids() async {
    final db = await DatabaseHelper.database;
    
    // SQL JOIN with ALIASES to avoid column conflicts
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        r.*,
        a.ADD_POSTAL_CODE,
        a.ADD_CITY,
        a.ADD_STREET_NAME,
        a.ADD_STREET_NUMBER,
        u.USE_ID as MANAGER_ID,
        u.USE_NAME as MANAGER_NAME,
        u.USE_LAST_NAME as MANAGER_LAST_NAME,
        u.USE_MAIL as MANAGER_MAIL,
        u.ADD_ID as MANAGER_ADD_ID
      FROM SAN_RAIDS r
      LEFT JOIN SAN_ADDRESSES a ON r.ADD_ID = a.ADD_ID
      LEFT JOIN SAN_USERS u ON r.USE_ID = u.USE_ID
      ORDER BY r.RAI_TIME_START DESC
    ''');
    
    return maps.map((map) => Raid.fromJson(map)).toList();
  }

  /// Fetches a single raid by ID with its address and manager (JOIN query)
  Future<Raid?> getRaidById(int id) async {
    final db = await DatabaseHelper.database;
    
    // SQL JOIN with ALIASES to avoid column conflicts
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        r.*,
        a.ADD_POSTAL_CODE,
        a.ADD_CITY,
        a.ADD_STREET_NAME,
        a.ADD_STREET_NUMBER,
        u.USE_ID as MANAGER_ID,
        u.USE_NAME as MANAGER_NAME,
        u.USE_LAST_NAME as MANAGER_LAST_NAME,
        u.USE_MAIL as MANAGER_MAIL,
        u.ADD_ID as MANAGER_ADD_ID
      FROM SAN_RAIDS r
      LEFT JOIN SAN_ADDRESSES a ON r.ADD_ID = a.ADD_ID
      LEFT JOIN SAN_USERS u ON r.USE_ID = u.USE_ID
      WHERE r.RAI_ID = ?
    ''', [id]);
    
    if (maps.isEmpty) return null;
    
    return Raid.fromJson(maps.first);
  }

  /// Inserts a new raid into the database
  Future<void> insertRaid(Raid raid) async {
    final db = await DatabaseHelper.database;
    await db.insert(
      'SAN_RAIDS',
      raid.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Clears all raids from the database
  Future<void> clearAllRaids() async {
    final db = await DatabaseHelper.database;
    await db.delete('SAN_RAIDS');
  }

  /// Inserts multiple raids (used for API sync)
  Future<void> insertRaids(List<Raid> raids) async {
    final db = await DatabaseHelper.database;
    final batch = db.batch();
    
    for (var raid in raids) {
      batch.insert(
        'SAN_RAIDS',
        raid.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    await batch.commit(noResult: true);
  }

  /// Fetches users with a specific role (for raid manager selection)
  Future<List<User>> getUsersByRole(int roleId) async {
    final db = await DatabaseHelper.database;
    
    // SQL JOIN to get users who have the specified role
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT u.*
      FROM SAN_USERS u
      INNER JOIN SAN_ROLES_USERS ru ON u.USE_ID = ru.USE_ID
      WHERE ru.ROL_ID = ?
      ORDER BY u.USE_NAME, u.USE_LAST_NAME
    ''', [roleId]);
    
    return maps.map((map) => User.fromJson(map)).toList();
  }
}