import 'package:sae5_g13_mobile/features/race/domain/category.dart';

import 'race.dart';

/// Race repository interface.
///
/// Defines the contract for race data operations following the repository pattern
/// [web:107][web:113]. This abstract class sits in the domain layer and is implemented
/// by the data layer, enabling dependency inversion and testability [web:167].
///
/// The repository acts as a single source of truth for race data, abstracting
/// whether data comes from API, local database, or both [web:107][web:168].
///
/// Example usage:
/// ```dart
/// // Implementation is injected via dependency injection
/// final RacesRepository raceRepo = RacesRepositoryImpl(...);
///
/// // Fetch races for a raid
/// final races = await raceRepo.getRacesByRaidId(5);
///
/// // Create race with pricing
/// final raceId = await raceRepo.createRace(race, {1: 2000, 2: 2500});
/// ```
abstract class RacesRepository {
  /// Retrieves all races from storage.
  ///
  /// Returns all cached races. For fresh data with API sync, use [getRacesByRaidId].
  Future<List<Race>> getRaces();

  /// Retrieves races for a specific raid with API synchronization.
  ///
  /// Fetches from API when online and updates local cache. Falls back to
  /// cached data if offline [web:171][web:172].
  ///
  /// **Parameters:**
  /// - [raidId]: The parent raid ID
  Future<List<Race>> getRacesByRaidId(int raidId);

  /// Retrieves a single race by ID from local storage.
  ///
  /// **Returns:** [Race] if found, `null` otherwise
  Future<Race?> getRaceById(int id);

  /// Counts registered teams for a race.
  ///
  /// Useful for checking race capacity and registration status.
  Future<int> getRegisteredTeamsCount(int raceId);

  /// Creates a new race with category pricing.
  ///
  /// Attempts API creation first, falls back to local-only if offline [web:171].
  /// Automatically handles authentication token injection.
  ///
  /// **Parameters:**
  /// - [race]: Race entity to create
  /// - [categoryPrices]: Map of category ID → price in cents (e.g., {1: 2500})
  ///
  /// **Returns:** The created race ID
  ///
  /// **Example:**
  /// ```dart
  /// final prices = {1: 2000, 2: 2500, 3: 3000}; // Prices in cents
  /// final raceId = await raceRepo.createRace(newRace, prices);
  /// ```
  Future<int> createRace(Race race, Map<int, int> categoryPrices);

  /// Returns fixed age category definitions.
  ///
  /// Categories are hardcoded: 1=Mineur, 2=Majeur non licencié, 3=Licencié.
  Future<List<Category>> getCategories();

  /// Fetches category prices for a specific race.
  ///
  /// **Returns:** Map of category ID → price in cents
  Future<Map<int, int>> getRaceCategoryPrices(int raceId);

  /// Checks if a raid can accept more races.
  ///
  /// Validates against the raid's RAI_NB_RACES limit.
  ///
  /// **Returns:** `true` if race can be added, `false` if limit reached
  Future<bool> canAddRaceToRaid(int raidId);

  /// Counts races in a raid.
  Future<int> getRaceCount(int raidId);

  /// Gets the maximum race limit for a raid.
  ///
  /// **Returns:** Maximum count, or `null` if unlimited
  Future<int?> getMaxRaceCount(int raidId);
}
