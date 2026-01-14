import 'package:sae5_g13_mobile/features/races/domain/category.dart';

import 'race.dart';

abstract class RacesRepository {
  /// Récupère toutes les courses
  Future<List<Race>> getRaces();
  
  /// Récupère les courses d'un raid spécifique
  Future<List<Race>> getRacesByRaidId(int raidId);
  
  /// Récupère une course par son ID
  Future<Race?> getRaceById(int id);
  Future<int> getRegisteredTeamsCount(int raceId);

  Future<int> createRace(Race race, Map<int, double> categoryPrices);
  Future<List<Category>> getCategories();
  Future<Map<int, double>> getRaceCategoryPrices(int raceId);
}
