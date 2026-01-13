// lib/features/raids/data/repositories/RaidRepositoryImpl.dart
import '../../domain/raid.dart';
import '../../domain/raid_repository.dart';
import '../datasources/raid_api_sources.dart';
import '../datasources/raid_local_sources.dart';

class RaidRepositoryImpl implements RaidRepository {
  final RaidApiSources apiSources;
  final RaidLocalSources localSources;

  RaidRepositoryImpl({
    required this.apiSources,
    required this.localSources,
  });

  @override
  Future<Raid?> getRaidById(int id) async {
    try {
      // Tentative de récupération depuis l'API
      final remoteRaid = await apiSources.getRaidById(id);
      
      if (remoteRaid != null) {
        // Sauvegarde en cache local
        await localSources.insertRaid(remoteRaid);
        return remoteRaid;
      }
      
      return null;
    } catch (e) {
      print('API fetch failed: $e. Falling back to local cache...');
      
      // Fallback sur le cache local
      try {
        return await localSources.getRaidById(id);
      } catch (localError) {
        print('Local fetch failed: $localError');
        rethrow;
      }
    }
  }

  @override
  Future<List<Raid>> getAllRaids() async {
    try {
      // Récupération depuis l'API
      final remoteRaids = await apiSources.getAllRaids();
      
      // Mise à jour du cache local
      await localSources.clearAllRaids();
      await localSources.insertRaids(remoteRaids);
      
      return remoteRaids;
    } catch (e) {
      print('API fetch failed: $e. Using local cache...');
      
      // Fallback sur le cache local
      try {
        return await localSources.getAllRaids();
      } catch (localError) {
        print('Local fetch failed: $localError');
        return [];
      }
    }
  }

  @override
  Future<void> createRaid(Raid raid) async {
    // Sauvegarder en local
    await localSources.insertRaid(raid);
    
    // Envoyer à l'API (si disponible)
    try {
      await apiSources.createRaid(raid);
    } catch (e) {
      print('API sync failed, saved locally: $e');
    }
  }
}
