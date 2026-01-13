import 'package:sqflite/sqflite.dart';
import '../../domain/models/Race.dart';

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

  /// Insère une course
  Future<void> insertRace(Race race) async {
    await database.insert(
      'SAN_RACES',
      race.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Insère plusieurs courses
  Future<void> insertRaces(List<Race> races) async {
    final batch = database.batch();
    for (var race in races) {
      batch.insert(
        'SAN_RACES',
        race.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  /// Supprime une course
  Future<void> deleteRace(int id) async {
    await database.delete('SAN_RACES', where: 'RAC_ID = ?', whereArgs: [id]);
  }

  /// Supprime toutes les courses
  Future<void> deleteAllRaces() async {
    await database.delete('SAN_RACES');
  }
}
