// lib/features/raid/domain/raid_repository.dart
import '../../raid/domain/raid.dart';

abstract class RaidRepository {
  Future<Raid?> getRaidById(int id);
  Future<List<Raid>> getAllRaids();
  Future<void> createRaid(Raid raid);
  Future<Raid> updateRaid(int id, Raid raid);
  Future<void> deleteRaid(int id);
}
