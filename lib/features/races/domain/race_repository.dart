import 'models/race.dart';

abstract class RacesRepository {
  /// Récupère toutes les courses
  Future<List<Race>> getRaces();
  
  /// Récupère les courses d'un raid spécifique
  Future<List<Race>> getRacesByRaidId(int raidId);
  
  /// Récupère une course par son ID
  Future<Race?> getRaceById(int id);
}
