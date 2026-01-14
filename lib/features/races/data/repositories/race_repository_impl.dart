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
}
