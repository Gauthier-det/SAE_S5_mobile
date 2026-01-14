import '../../domain/race_repository.dart';
import '../../domain/race.dart';
import '../datasources/race_api_sources.dart';
import '../datasources/race_local_sources.dart';

class RacesRepositoryImpl implements RacesRepository {
  final RaceApiSources apiSources;
  final RaceLocalSources localSources;

  RacesRepositoryImpl({required this.apiSources, required this.localSources});

  @override
  Future<List<Race>> getRaces() async {
    try {
      final races = await apiSources.getAllRaces();
      // Mise à jour du cache local
      for (var race in races) {
        await localSources.insertRace(race);
      }
      return races;
    } catch (e) {
      print('API non disponible, utilisation du cache local: $e');
      return await localSources.getAllRaces();
    }
  }

  @override
  Future<int> getRegisteredTeamsCount(int raceId) async {
    return await localSources.getRegisteredTeamsCount(raceId);
  }

  @override
  Future<List<Race>> getRacesByRaidId(int raidId) async {
    try {
      final races = await apiSources.getRacesByRaid(raidId);
      // Mise à jour du cache local
      for (var race in races) {
        await localSources.insertRace(race);
      }
      return races;
    } catch (e) {
      print('API non disponible, utilisation du cache local: $e');
      return await localSources.getRacesByRaidId(raidId);
    }
  }

  @override
  Future<Race?> getRaceById(int id) async {
    try {
      final race = await apiSources.getRaceById(id);
      if (race != null) {
        await localSources.insertRace(race);
      }
      return race;
    } catch (e) {
      print('API non disponible, utilisation du cache local: $e');
      return await localSources.getRaceById(id);
    }
  }
}
