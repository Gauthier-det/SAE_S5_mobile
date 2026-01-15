import 'package:sae5_g13_mobile/features/race/domain/category.dart';

import '../../domain/race_repository.dart';
import '../../domain/race.dart';
import '../datasources/race_api_sources.dart';
import '../datasources/race_local_sources.dart';
import '../../../../core/services/api_service.dart';

class RacesRepositoryImpl implements RacesRepository {
  final RaceApiSources apiSources;
  final RaceLocalSources localSources;
  final ApiService? apiService;

  RacesRepositoryImpl({
    required this.apiSources,
    required this.localSources,
    this.apiService,
  });

  @override
  Future<List<Race>> getRaces() async {
    return await localSources.getAllRaces();
  }

  @override
  Future<int> getRegisteredTeamsCount(int raceId) async {
    return await localSources.getRegisteredTeamsCount(raceId);
  }

  @override
  Future<List<Race>> getRacesByRaidId(int raidId) async {
    return await localSources.getRacesByRaidId(raidId);
  }

  @override
  Future<Race?> getRaceById(int id) async {
    return await localSources.getRaceById(id);
  }

  // lib/features/races/data/repositories/race_repository_impl.dart

  @override
  Future<int> createRace(Race race, Map<int, double> categoryPrices) async {
    int racRequired;
    if (race.type == 'Compétitif') {
      racRequired = 1;
    } else {
      racRequired = 0;
    }

    final raceId = await localSources.createRace({
      'RAI_ID': race.raidId,
      'USE_ID': race.userId,
      'RAC_TYPE': race.type,
      'RAC_DIFFICULTY': race.difficulty,
      'RAC_TIME_START': race.startDate.toIso8601String(), 
      'RAC_TIME_END': race.endDate.toIso8601String(),  
      'RAC_MIN_PARTICIPANTS': race.minParticipants,
      'RAC_MAX_PARTICIPANTS': race.maxParticipants,
      'RAC_MIN_TEAMS': race.minTeams,
      'RAC_MAX_TEAMS': race.maxTeams,
      'RAC_TEAM_MEMBERS': race.teamMembers,
      'RAC_AGE_MIN': race.ageMin,
      'RAC_AGE_MIDDLE': race.ageMiddle,
      'RAC_AGE_MAX': race.ageMax,
      'RAC_SEX': race.sex,
      'RAC_CHIP_REQUIRED': racRequired,
    });

    // Créer les prix par catégorie
    for (var entry in categoryPrices.entries) {
      await localSources.createRaceCategoryPrice(raceId, entry.key, entry.value);
    }

    return raceId;
  }

  @override
  Future<List<Category>> getCategories() async {
    final data = await localSources.getCategories();
    return data.map((json) => Category.fromJson(json)).toList();
  }

  @override
  Future<Map<int, double>> getRaceCategoryPrices(int raceId) async {
    final data = await localSources.getRaceCategoryPrices(raceId);
    return Map.fromEntries(
      data.map((e) => MapEntry(e['CAT_ID'] as int, (e['price'] as num).toDouble())),
    );
  }

  @override
  Future<bool> canAddRaceToRaid(int raidId) async {
    return await localSources.canAddRaceToRaid(raidId);
  }

  @override
  Future<int> getRaceCount(int raidId) async {
    final races = await localSources.getRacesByRaidId(raidId);
    return races.length;
  }

  @override
  Future<int?> getMaxRaceCount(int raidId) async {
    return await localSources.getMaxRaceCount(raidId);
  }

}
