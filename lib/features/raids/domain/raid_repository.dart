import 'raid.dart';

abstract class RaidRepository {
  Future<Raid?> getRaidById(int id);
  Future<List<Raid>> getAllRaids();
}