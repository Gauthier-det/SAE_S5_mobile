import 'package:sae5_g13_mobile/features/races/domain/RaceRepository.dart';
import 'package:sae5_g13_mobile/features/races/domain/models/Race.dart';

class RacesrepositoryImpl implements RacesRepository {
  // TODO: Implémenter les data sources
  // final RaceApiDataSource api;
  // final RaceLocalDataSource local;

  @override
  Future<List<Race>> getRaces() async {
    // TODO: Implémenter la logique avec les data sources
    return [];
    // try {
    //   final remote = await api.fetchRaces();
    //   await local.saveRaces(remote);
    //   return remote;
    // } catch (_) {
    //   return local.getRaces();
    // }
  }
}
