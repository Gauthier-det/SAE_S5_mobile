import '../../domain/RaceRepository.dart';
import '../../domain/models/Race.dart';
import '../datasources/RaceApiSources.dart';
import '../datasources/RaceLocalSources.dart';

class RacesRepositoryImpl implements RacesRepository {
  final RaceApiSources apiSources;
  final RaceLocalSources localSources;

  RacesRepositoryImpl({required this.apiSources, required this.localSources});

  @override
  Future<List<Race>> getRaces() async {
    return await localSources.getAllRaces();
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
