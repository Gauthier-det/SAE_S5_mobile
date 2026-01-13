// lib/features/raids/data/datasources/RaidLocalSources.dart
import 'package:sqflite/sqflite.dart';
import '../../domain/raid.dart';

class RaidLocalSources {
  final Database database;

  RaidLocalSources({required this.database});

  Future<Raid?> getRaidById(int id) async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        'SAN_RAIDS',
        where: 'RAI_ID = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) {
        return null;
      }

      return Raid.fromJson(maps.first);
    } catch (e) {
      throw Exception('Database error: $e');
    }
  }

  Future<List<Raid>> getAllRaids() async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        'SAN_RAIDS',
        orderBy: 'RAI_TIME_START DESC',
      );
      return maps.map((map) => Raid.fromJson(map)).toList();
    } catch (e) {
      throw Exception('Database error: $e');
    }
  }

  Future<void> insertRaid(Raid raid) async {
    await database.insert(
      'SAN_RAIDS',
      raid.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertRaids(List<Raid> raids) async {
    final batch = database.batch();
    for (var raid in raids) {
      batch.insert(
        'SAN_RAIDS',
        raid.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<void> deleteRaid(int id) async {
    await database.delete(
      'SAN_RAIDS',
      where: 'RAI_ID = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearAllRaids() async {
    await database.delete('SAN_RAIDS');
  }

  Future<int> getRaidsCount() async {
    final result = await database.rawQuery('SELECT COUNT(*) as count FROM SAN_RAIDS');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
