import 'package:sae5_g13_mobile/features/races/domain/RaceRepository.dart';


class RacesrepositoryImpl implements RacesRepository {
  final RaceApiDataSource api;
  final RaceLocalDataSource local;

  @override
  Future<List<Race>> getRaces() async {
    try {
      final remote = await api.fetchRaids();
      await local.saveRaids(remote);
      return remote;
    } catch (_) {
      return local.getRaids();
    }
  }
}
