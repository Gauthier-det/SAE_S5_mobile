// lib/features/raid/data/repositories/RaidRepositoryImpl.dart
import '../../../raid/domain/raid.dart';
import '../../domain/raid_repository.dart';
import '../datasources/raid_api_sources.dart';
import '../datasources/raid_local_sources.dart';
import '../../../auth/data/datasources/auth_local_sources.dart';

/// Repository implementation with API-first, local-fallback strategy.
///
/// Handles data synchronization between REST API and local SQLite cache.
/// Uses token-based authentication for write operations [web:138][web:186].
///
/// **Data Flow:**
/// - Read: Try API → cache result → fallback to local on error
/// - Write: Send to API → cache result → fallback to local-only on error
/// - Refresh: Clear local → fetch API → cache all
///
/// Example:
/// ```dart
/// final repository = RaidRepositoryImpl(
///   apiSources: raidApi,
///   localSources: raidLocalDb,
///   authLocalSources: authLocalDb,
/// );
/// final raids = await repository.getAllRaids(); // API + cache
/// ```
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
      // Fetch from API
      final remoteRaid = await apiSources.getRaidById(id);

      if (remoteRaid != null) {
        // Cache locally
        await localSources.insertRaid(remoteRaid);
        return remoteRaid;
      }

      return null;
    } catch (e) {
      // Fallback to local cache
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
      // Fetch from API
      final remoteRaids = await apiSources.getAllRaids();

      // Clear and refresh local cache
      await localSources.clearAllRaids();
      await localSources.insertRaids(remoteRaids);

      return remoteRaids;
    } catch (e) {
      // Fallback to local cache
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
      // Inject auth token [web:138]
      final token = authLocalSources.getToken();
      apiSources.setAuthToken(token);

      // Send to API
      final createdRaid = await apiSources.createRaid(raid);
      
      // Cache with server-generated ID
      await localSources.insertRaid(createdRaid);
    } catch (e) {
      // Fallback: save locally only
      await localSources.insertRaid(raid);
    }
  }

  @override
  Future<Raid> updateRaid(int id, Raid raid) async {
    // Inject auth token [web:138]
    final token = authLocalSources.getToken();
    apiSources.setAuthToken(token);

    final updatedRaid = await apiSources.updateRaid(id, raid);
    await localSources.insertRaid(updatedRaid);
    return updatedRaid;
  }

  @override
  Future<void> deleteRaid(int id) async {
    // Inject auth token [web:138]
    final token = authLocalSources.getToken();
    apiSources.setAuthToken(token);

    await apiSources.deleteRaid(id);
    // TODO: Remove from local cache if needed
  }
}
