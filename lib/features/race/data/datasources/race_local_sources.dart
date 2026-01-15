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

    final result = await db.rawQuery(
      '''
    SELECT COUNT(*) as count
    FROM SAN_TEAMS_RACES
    WHERE RAC_ID = ?
  ''',
      [raceId],
    );

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
    return await db.rawQuery(
      '''
      SELECT rc.CAT_ID, c.CAT_LABEL, rc.CAR_PRICE as price
      FROM SAN_CATEGORIES_RACES rc
      INNER JOIN SAN_CATEGORIES c ON rc.CAT_ID = c.CAT_ID
      WHERE rc.RAC_ID = ?
      ORDER BY c.CAT_LABEL
    ''',
      [raceId],
    );
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await DatabaseHelper.database;
    return await db.query('SAN_CATEGORIES', orderBy: 'CAT_LABEL ASC');
  }

  Future<int> createRace(Map<String, dynamic> raceData) async {
    final db = await DatabaseHelper.database;
    return await db.insert('SAN_RACES', raceData);
  }

  /// Insère ou met à jour une course (depuis l'API)
  Future<void> insertRace(Race race) async {
    final db = await DatabaseHelper.database;
    await db.insert(
      'SAN_RACES',
      race.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> createRaceCategoryPrice(
    int raceId,
    int categoryId,
    double price,
  ) async {
    final db = await DatabaseHelper.database;
    await db.insert('SAN_CATEGORIES_RACES', {
      'RAC_ID': raceId,
      'CAT_ID': categoryId,
      'CAR_PRICE': price,
    });
  }

  // Ajoute cette méthode pour vérifier le nombre de courses
  Future<bool> canAddRaceToRaid(int raidId) async {
    final db = await DatabaseHelper.database;

    // Récupérer le raid avec sa limite
    final raidResult = await db.query(
      'SAN_RAIDS',
      columns: ['RAI_RACE_COUNT'],
      where: 'RAI_ID = ?',
      whereArgs: [raidId],
      limit: 1,
    );

    if (raidResult.isEmpty) return false;

    final maxRaces = raidResult.first['RAI_RACE_COUNT'] as int?;

    // Si pas de limite définie, autoriser
    if (maxRaces == null) return true;

    // Compter le nombre de courses existantes
    final countResult = await db.rawQuery(
      '''
      SELECT COUNT(*) as count
      FROM SAN_RACES
      WHERE RAI_ID = ?
    ''',
      [raidId],
    );

    final currentCount = countResult.first['count'] as int;

    return currentCount < maxRaces;
  }

  Future<int?> getMaxRaceCount(int raidId) async {
    final db = await DatabaseHelper.database;

    final raidResult = await db.query(
      'SAN_RAIDS',
      columns: ['RAI_RACE_COUNT'],
      where: 'RAI_ID = ?',
      whereArgs: [raidId],
      limit: 1,
    );
    if (raidResult.isEmpty) return null;

    return raidResult.first['RAI_RACE_COUNT'] as int?;
  }
}
