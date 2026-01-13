import 'package:sae5_g13_mobile/features/races/domain/Race.dart';

abstract class RacesRepository {
  Future<List<Race>> getRaids();
  // (ou getRacesByRaid, etc. selon ton choix)
}
