// lib/features/raids/data/repositories/RaidRepositoryImpl.dart
import '../../domain/raid.dart';
import '../../domain/raid_repository.dart';
import '../datasources/raid_api_sources.dart';
import '../datasources/raid_local_sources.dart';

class RaidRepositoryImpl implements RaidRepository {
  final RaidApiSources apiSources;
  final RaidLocalSources localSources;

  RaidRepositoryImpl({required this.apiSources, required this.localSources});

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
      print('API non disponible, utilisation du cache local: $e');

      // Fallback sur le cache local
      try {
        return await localSources.getRaidById(id);
      } catch (localError) {
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
      print('API non disponible, utilisation du cache local: $e');

      // Fallback sur le cache local
      try {
        return await localSources.getAllRaids();
      } catch (localError) {
        return [];
      }
    }
  }

  @override
  Future<void> createRaid(Raid raid) async {
    try {
      // Envoyer à l'API en priorité
      final createdRaid = await apiSources.createRaid(raid);
      // Sauvegarder en local avec l'ID retourné par l'API
      await localSources.insertRaid(createdRaid);
    } catch (e) {
      print('API non disponible, sauvegarde locale uniquement: $e');
      // Sauvegarder en local seulement
      await localSources.insertRaid(raid);
    }
  }
}
