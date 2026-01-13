import 'models/Race.dart';

abstract class RacesRepository {
  Future<List<Race>> getRaces();
  // (ou getRacesByRaid, etc. selon ton choix)
}
