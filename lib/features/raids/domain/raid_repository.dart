// lib/features/raids/domain/raid_repository.dart
import '../../../features/user/domain/user.dart';
import 'raid.dart';

abstract class RaidRepository {
  Future<Raid?> getRaidById(int id);
  Future<List<Raid>> getAllRaids();
  Future<void> createRaid(Raid raid);
  
  
}
