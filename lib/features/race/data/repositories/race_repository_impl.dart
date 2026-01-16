import 'package:sae5_g13_mobile/features/race/domain/category.dart';

import '../../domain/race_repository.dart';
import '../../domain/race.dart';
import '../datasources/race_api_sources.dart';
import '../datasources/race_local_sources.dart';
import '../../../auth/data/datasources/auth_local_sources.dart';

class RacesRepositoryImpl implements RacesRepository {
  final RaceApiSources apiSources;
  final RaceLocalSources localSources;
  final AuthLocalSources authLocalSources;

  RacesRepositoryImpl({
    required this.apiSources,
    required this.localSources,
    required this.authLocalSources,
  });

  @override
  Future<List<Race>> getRaces() async {
    return await localSources.getAllRaces();
  }

  @override
  Future<int> getRegisteredTeamsCount(int raceId) async {
    try {
      // 1. Tenter de récupérer depuis l'API via getRaceDetails
      // L'endpoint details renvoie un objet 'stats' avec 'teams_count'
      // On ignore l'authentification ici car getRaceDetails est public (ou token géré par apiSources)
      // Si nécessaire, assurez-vous que apiSources a le token set, mais ici on lit juste.
      final token = authLocalSources.getToken();
      apiSources.setAuthToken(token);

      final details = await apiSources.getRaceDetails(raceId);
      if (details['stats'] != null && details['stats']['teams_count'] != null) {
        return details['stats']['teams_count'] as int;
      }
      return 0;
    } catch (e) {
      print('Erreur récupération count équipes API, fallback local: $e');
      // 2. Fallback sur le local si pas de réseau
      return await localSources.getRegisteredTeamsCount(raceId);
    }
  }

  @override
  Future<List<Race>> getRacesByRaidId(int raidId) async {
    try {
      // Récupérer depuis l'API
      final remoteRaces = await apiSources.getRacesByRaid(raidId);

      // Remplacer le cache local (clear + insert)
      await localSources.clearRacesByRaidId(raidId);
      for (var race in remoteRaces) {
        await localSources.insertRace(race);
      }

      return remoteRaces;
    } catch (e) {
      print('API fetch failed: $e. Falling back to local cache...');

      // Fallback sur le cache local
      return await localSources.getRacesByRaidId(raidId);
    }
  }

  @override
  Future<Race?> getRaceById(int id) async {
    return await localSources.getRaceById(id);
  }

  // lib/features/races/data/repositories/race_repository_impl.dart

  @override
  Future<int> createRace(Race race, Map<int, int> categoryPrices) async {
    // Essayer de créer via l'API
    try {
      // Récupérer le token et l'injecter
      final token = authLocalSources.getToken();
      apiSources.setAuthToken(token);

      final createdRace = await apiSources.createRace(race, categoryPrices);

      // Sauvegarder en local
      await localSources.insertRace(createdRace);

      // Créer les prix par catégorie en local
      for (var entry in categoryPrices.entries) {
        await localSources.createRaceCategoryPrice(
          createdRace.id,
          entry.key,
          entry.value,
        );
      }

      return createdRace.id;
    } catch (e) {
      print('API sync failed, saving locally: $e');

      // Fallback: créer en local uniquement
      int racRequired;
      if (race.type == 'Compétitif') {
        racRequired = 1;
      } else {
        racRequired = 0;
      }

      final raceId = await localSources.createRace({
        'RAI_ID': race.raidId,
        'RAC_NAME': race.name,
        'USE_ID': race.userId,
        'RAC_TYPE': race.type,
        'RAC_DIFFICULTY': race.difficulty,
        'RAC_TIME_START': race.startDate.toIso8601String(),
        'RAC_TIME_END': race.endDate.toIso8601String(),
        'RAC_MIN_PARTICIPANTS': race.minParticipants,
        'RAC_MAX_PARTICIPANTS': race.maxParticipants,
        'RAC_MIN_TEAMS': race.minTeams,
        'RAC_MAX_TEAMS': race.maxTeams,
        'RAC_MAX_TEAM_MEMBERS': race.teamMembers,
        'RAC_AGE_MIN': race.ageMin,
        'RAC_AGE_MIDDLE': race.ageMiddle,
        'RAC_AGE_MAX': race.ageMax,
        'RAC_GENDER': race.sex,
        'RAC_CHIP_MANDATORY': racRequired,
      });

      // Créer les prix par catégorie
      for (var entry in categoryPrices.entries) {
        await localSources.createRaceCategoryPrice(
          raceId,
          entry.key,
          entry.value,
        );
      }

      return raceId;
    }
  }

  @override
  Future<List<Category>> getCategories() async {
    // Categories are fixed data, return them directly
    // Matches Laravel seeder: CAT_ID 1=Mineur, 2=Majeur non licencié, 3=Licencié
    return [
      Category(id: 1, label: 'Mineur'),
      Category(id: 2, label: 'Majeur non licencié'),
      Category(id: 3, label: 'Licencié'),
    ];
  }

  @override
  Future<Map<int, int>> getRaceCategoryPrices(int raceId) async {
    final data = await localSources.getRaceCategoryPrices(raceId);
    return Map.fromEntries(
      data.map(
        (e) => MapEntry(e['CAT_ID'] as int, (e['CAR_PRICE'] as num).toInt()),
      ),
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
