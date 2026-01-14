import 'package:sae5_g13_mobile/core/database/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import '../../domain/race.dart';

class RaceLocalSources {
  final Database database;

  RaceLocalSources({required this.database});

  /// Récupère toutes les courses
  Future<List<Race>> getAllRaces() async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        'SAN_RACES',
        orderBy: 'RAC_TIME_START DESC',
      );
      return maps.map((map) => Race.fromJson(map)).toList();
    } catch (e) {
      throw Exception('Database error: $e');
    }
  }

  /// Récupère les courses d'un raid spécifique
  Future<List<Race>> getRacesByRaidId(int raidId) async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        'SAN_RACES',
        where: 'RAI_ID = ?',
        whereArgs: [raidId],
        orderBy: 'RAC_TIME_START ASC',
      );
      return maps.map((map) => Race.fromJson(map)).toList();
    } catch (e) {
      throw Exception('Database error: $e');
    }
  }

  Future<int> getRegisteredTeamsCount(int raceId) async {
  final db = await DatabaseHelper.database;
  
  final result = await db.rawQuery('''
    SELECT COUNT(*) as count
    FROM SAN_TEAMS_RACES
    WHERE RAC_ID = ?
  ''', [raceId]);
  
  return Sqflite.firstIntValue(result) ?? 0;
}

  /// Récupère une course par son ID
  Future<Race?> getRaceById(int id) async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        'SAN_RACES',
        where: 'RAC_ID = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) {
        return null;
      }

      return Race.fromJson(maps.first);
    } catch (e) {
      throw Exception('Database error: $e');
    }
  }
// lib/features/races/data/datasources/race_local_sources.dart

  Future<List<Map<String, dynamic>>> getRaceCategoryPrices(int raceId) async {
    final db = await DatabaseHelper.database;
    return await db.rawQuery('''
      SELECT rc.CAT_ID, c.CAT_LABEL, rc.CAR_PRICE as price
      FROM SAN_CATEGORIES_RACES rc
      INNER JOIN SAN_CATEGORIES c ON rc.CAT_ID = c.CAT_ID
      WHERE rc.RAC_ID = ?
      ORDER BY c.CAT_LABEL
    ''', [raceId]);
  }
  Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await DatabaseHelper.database;
    return await db.query(
      'SAN_CATEGORIES',
      orderBy: 'CAT_LABEL ASC',
    );
  }

  Future<int> createRace(Map<String, dynamic> raceData) async {
    final db = await DatabaseHelper.database;
    return await db.insert('SAN_RACES', raceData);
  }

  Future<void> createRaceCategoryPrice(int raceId, int categoryId, double price) async {
    final db = await DatabaseHelper.database;
    await db.insert('SAN_CATEGORIES_RACES', {
      'RAC_ID': raceId,
      'CAT_ID': categoryId,
      'CAR_PRICE': price,
    });
  }

}
