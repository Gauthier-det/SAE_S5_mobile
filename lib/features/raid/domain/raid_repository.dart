// lib/features/raid/domain/raid_repository.dart
import '../../raid/domain/raid.dart';

/// Repository interface for raid data operations.
///
/// Defines contract for CRUD operations on raids. Implementations handle
/// data sources (API, local database, mock) [web:176][web:186].
///
/// Example implementation:
/// ```dart
/// class RaidRepositoryImpl implements RaidRepository {
///   final RaidApiSources apiSource;
///   final RaidLocalSource localSource;
///   
///   @override
///   Future<Raid?> getRaidById(int id) async {
///     // Try local first, fallback to API
///     return await localSource.getRaidById(id) 
///       ?? await apiSource.getRaidById(id);
///   }
///   // ... other methods
/// }
/// ```
abstract class RaidRepository {
  /// Fetches raid by ID. Returns null if not found.
  Future<Raid?> getRaidById(int id);

  /// Fetches all raids.
  Future<List<Raid>> getAllRaids();

  /// Creates new raid. Throws on error.
  Future<void> createRaid(Raid raid);

  /// Updates existing raid. Returns updated raid.
  Future<Raid> updateRaid(int id, Raid raid);

  /// Deletes raid by ID. Throws on error.
  Future<void> deleteRaid(int id);
}
