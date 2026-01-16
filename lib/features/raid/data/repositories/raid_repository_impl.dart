// lib/features/raid/data/repositories/RaidRepositoryImpl.dart
import '../../../raid/domain/raid.dart';
import '../../domain/raid_repository.dart';
import '../datasources/raid_api_sources.dart';
import '../datasources/raid_local_sources.dart';
import '../../../auth/data/datasources/auth_local_sources.dart';

class RaidRepositoryImpl implements RaidRepository {
  final RaidApiSources apiSources;
  final RaidLocalSources localSources;
  final AuthLocalSources authLocalSources;

  RaidRepositoryImpl({
    required this.apiSources,
    required this.localSources,
    required this.authLocalSources,
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
    // Envoyer à l'API en priorité
    try {
      // Récupérer le token d'authentification
      final token = authLocalSources.getToken();
      apiSources.setAuthToken(token);

      final createdRaid = await apiSources.createRaid(raid);
      // Sauvegarder le raid créé (avec l'ID de l'API) en local
      await localSources.insertRaid(createdRaid);
    } catch (e) {
      // Fallback: sauvegarder en local uniquement
      await localSources.insertRaid(raid);
    }
  }

  @override
  Future<Raid> updateRaid(int id, Raid raid) async {
    final token = authLocalSources.getToken();
    apiSources.setAuthToken(token);

    final updatedRaid = await apiSources.updateRaid(id, raid);
    await localSources.insertRaid(updatedRaid);
    return updatedRaid;
  }

  @override
  Future<void> deleteRaid(int id) async {
    final token = authLocalSources.getToken();
    apiSources.setAuthToken(token);

    await apiSources.deleteRaid(id);
    // TODO: Remove from local cache if needed
  }
}
