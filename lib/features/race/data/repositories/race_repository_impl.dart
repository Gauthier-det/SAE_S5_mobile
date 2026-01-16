import 'package:sae5_g13_mobile/features/race/domain/category.dart';

import '../../domain/race_repository.dart';
import '../../domain/race.dart';
import '../datasources/race_api_sources.dart';
import '../datasources/race_local_sources.dart';
import '../../../auth/data/datasources/auth_local_sources.dart';

/// Race repository implementation.
///
/// Implements the [RacesRepository] interface following Clean Architecture's
/// repository pattern, which acts as a single source of truth bridging the
/// domain layer and data sources [web:107][web:113][web:167]. This implementation
/// uses an **offline-first architecture** with API synchronization strategy [web:171][web:172].
///
/// ## Architecture Pattern
///
/// The repository pattern provides several key benefits [web:107][web:113][web:167]:
/// - **Abstraction**: Domain layer doesn't know about data source implementations
/// - **Single Source of Truth**: UI components access data through one unified interface
/// - **Testability**: Enables easy mocking of data sources for unit testing
/// - **Flexibility**: Allows switching or combining data sources transparently
/// - **Data Synchronization**: Manages sync between remote API and local cache [web:104][web:168]
///
/// ## Offline-First Strategy
///
/// This implementation follows offline-first principles [web:171][web:172]:
///
/// ### Read Operations
/// 1. **Local-First Reads**: Most read operations return local data immediately for speed
/// 2. **Background Sync**: [getRacesByRaidId] fetches from API and updates local cache
/// 3. **Graceful Fallback**: If API fails, falls back to cached local data [web:127]
///
/// ### Write Operations
/// 1. **API-First Write**: [createRace] attempts API creation first
/// 2. **Dual Persistence**: On success, saves to both API and local database
/// 3. **Offline Creation**: If API fails, creates in local database only [web:171]
///
/// ## Data Flow Examples
///
/// ### Fetching Races (with sync):
/// ```
/// User Request → Repository
///     ↓
/// API Fetch (background)
///     ↓
/// Clear Local Cache
///     ↓
/// Insert Fresh Data
///     ↓
/// Return Fresh Data
///     ↓ (if API fails)
/// Return Cached Data (fallback)
/// ```
///
/// ### Creating Race:
/// ```
/// User Creates Race
///     ↓
/// Try API Create (with auth token)
///     ↓ (success)
/// Save to Local Database
///     ↓
/// Return Race ID
///     ↓ (API fails)
/// Create in Local Only (offline mode)
/// ```
///
/// ## Authentication
///
/// Protected operations (race creation) require authentication. The repository
/// automatically injects the JWT token from [AuthLocalSources] into the API
/// client before making authenticated requests.
///
/// ## Fixed Category Data
///
/// Age categories are fixed and match the Laravel backend seeder:
/// - ID 1: "Mineur" (Minor, under 18)
/// - ID 2: "Majeur non licencié" (Adult without license)
/// - ID 3: "Licencié" (Licensed athlete)
///
/// Example usage:
/// ```dart
/// final raceRepo = RacesRepositoryImpl(
///   apiSources: raceApi,
///   localSources: raceLocal,
///   authLocalSources: authLocal,
/// );
///
/// // Fetch races with background sync
/// final races = await raceRepo.getRacesByRaidId(5);
///
/// // Create race with category pricing
/// final raceId = await raceRepo.createRace(
///   newRace,
///   {1: 2000, 2: 2500, 3: 3000}, // Prices in cents
/// );
/// ```
class RacesRepositoryImpl implements RacesRepository {
  /// API data source for remote operations.
  ///
  /// Handles communication with the race management backend API.
  final RaceApiSources apiSources;

  /// Local data source for persistent storage.
  ///
  /// Manages SQLite database operations for offline access and caching [web:162].
  final RaceLocalSources localSources;

  /// Authentication data source for token management.
  ///
  /// Provides JWT tokens for authenticated API requests.
  final AuthLocalSources authLocalSources;

  /// Creates a [RacesRepositoryImpl] instance.
  ///
  /// All three data sources are required to support both online/offline
  /// operations and authenticated requests [web:167].
  RacesRepositoryImpl({
    required this.apiSources,
    required this.localSources,
    required this.authLocalSources,
  });

  @override
  Future<List<Race>> getRaces() async {
    /// Retrieves all races from local storage.
    ///
    /// Returns cached races immediately without API call for fast performance [web:171].
    /// Use [getRacesByRaidId] if you need fresh data from the API with synchronization.
    ///
    /// **Data Source:** Local SQLite only
    ///
    /// **Returns:** List of all cached races ordered by start time
    ///
    /// **Example:**
    /// ```dart
    /// final races = await raceRepo.getRaces();
    /// print('Found ${races.length} cached races');
    /// ```
    return await localSources.getAllRaces();
  }

  @override
  Future<int> getRegisteredTeamsCount(int raceId) async {
    /// Counts registered teams for a race from local database.
    ///
    /// Queries the SAN_TEAMS_RACES junction table to count team registrations.
    /// This is a local-only operation for performance [web:171].
    ///
    /// **Data Source:** Local SQLite only
    ///
    /// **Parameters:**
    /// - [raceId]: The race ID to count registrations for
    ///
    /// **Returns:** Number of registered teams (0 if none)
    ///
    /// **Example:**
    /// ```dart
    /// final count = await raceRepo.getRegisteredTeamsCount(42);
    /// if (count >= race.maxTeams) {
    ///   print('Race is full!');
    /// }
    /// ```
    return await localSources.getRegisteredTeamsCount(raceId);
  }

  @override
  Future<List<Race>> getRacesByRaidId(int raidId) async {
    /// Retrieves races for a raid with API synchronization.
    ///
    /// Implements the **API-first with local fallback** pattern [web:127][web:171]:
    /// 1. Attempts to fetch fresh data from API
    /// 2. On success: Replaces local cache with fresh data (clear + insert) [web:104][web:168]
    /// 3. On failure: Falls back to cached local data [web:127]
    ///
    /// This ensures users always see data (cached if offline) while keeping
    /// the cache updated when online [web:171][web:172].
    ///
    /// **Data Flow:**
    /// ```
    /// API Fetch → Clear Local Cache → Insert Fresh Data → Return
    ///           ↓ (if error)
    ///        Return Cached Data (fallback)
    /// ```
    ///
    /// **Parameters:**
    /// - [raidId]: The parent raid ID
    ///
    /// **Returns:** List of races for the raid (fresh if online, cached if offline)
    ///
    /// **Example:**
    /// ```dart
    /// try {
    ///   // This will sync with API if online
    ///   final races = await raceRepo.getRacesByRaidId(5);
    ///   print('Fetched ${races.length} races (possibly updated from API)');
    /// } catch (e) {
    ///   print('Using cached data: $e');
    /// }
    /// ```
    try {
      // Attempt to fetch from API (online mode) [web:104][web:168]
      final remoteRaces = await apiSources.getRacesByRaid(raidId);

      // Replace local cache: clear old data, insert fresh data [web:104][web:168]
      await localSources.clearRacesByRaidId(raidId);
      for (var race in remoteRaces) {
        await localSources.insertRace(race);
      }

      return remoteRaces;
    } catch (e) {
      // Fallback: Return cached data (offline mode) [web:127][web:171]
      return await localSources.getRacesByRaidId(raidId);
    }
  }

  @override
  Future<Race?> getRaceById(int id) async {
    /// Retrieves a single race by ID from local storage.
    ///
    /// Returns cached race immediately without API call [web:171]. Returns null
    /// if the race doesn't exist in local database.
    ///
    /// **Data Source:** Local SQLite only
    ///
    /// **Parameters:**
    /// - [id]: The unique race identifier
    ///
    /// **Returns:**
    /// - [Race] object if found in cache
    /// - `null` if not found
    ///
    /// **Example:**
    /// ```dart
    /// final race = await raceRepo.getRaceById(42);
    /// if (race != null) {
    ///   print('Race: ${race.name} - ${race.distance}km');
    /// } else {
    ///   print('Race not found in local cache');
    /// }
    /// ```
    return await localSources.getRaceById(id);
  }

  @override
  Future<int> createRace(Race race, Map<int, int> categoryPrices) async {
    /// Creates a new race with category pricing.
    ///
    /// Implements **API-first with local fallback** creation strategy [web:171][web:172]:
    /// 1. **Try API Create**: Attempts to create via API with authentication
    /// 2. **On Success**: Saves race and category prices to local database
    /// 3. **On Failure**: Falls back to local-only creation (offline mode) [web:171]
    ///
    /// This ensures races can be created offline and synced later [web:171][web:172].
    ///
    /// ## Authentication Flow
    ///
    /// Before API creation, automatically injects JWT token from local auth storage:
    /// ```dart
    /// final token = authLocalSources.getToken();
    /// apiSources.setAuthToken(token);
    /// ```
    ///
    /// ## Category Pricing
    ///
    /// The [categoryPrices] map associates age categories with prices in cents:
    /// - Key: Category ID (1=Mineur, 2=Majeur non licencié, 3=Licencié)
    /// - Value: Price in cents (e.g., 2500 = 25.00€)
    ///
    /// Both API and local creation save category prices to enable registration
    /// price calculations.
    ///
    /// ## Field Transformation (Local Fallback)
    ///
    /// When creating locally, the repository transforms domain fields to database format:
    /// - `RAC_CHIP_MANDATORY`: Auto-calculated (1 for 'Compétitif', 0 otherwise)
    /// - Dates: Converted to ISO 8601 strings for SQLite storage
    /// - All race attributes mapped to database column names (RAC_*, USE_ID, RAI_ID)
    ///
    /// **Parameters:**
    /// - [race]: The race entity to create
    /// - [categoryPrices]: Map of category ID to price in cents
    ///
    /// **Returns:** The newly created race ID (from API or local database)
    ///
    /// **Throws:**
    /// - May throw exceptions if both API and local creation fail
    ///
    /// **Example:**
    /// ```dart
    /// final race = Race(
    ///   name: 'Trail 10km',
    ///   distance: 10.0,
    ///   type: 'Compétitif',
    ///   raidId: 5,
    ///   // ... other fields
    /// );
    ///
    /// // Category pricing (in cents)
    /// final prices = {
    ///   1: 2000,  // Mineur: €20.00
    ///   2: 2500,  // Majeur non licencié: €25.00
    ///   3: 3000,  // Licencié: €30.00
    /// };
    ///
    /// try {
    ///   final raceId = await raceRepo.createRace(race, prices);
    ///   print('Race created with ID: $raceId');
    /// } catch (e) {
    ///   print('Failed to create race: $e');
    /// }
    /// ```
    try {
      // Inject authentication token for protected API operation
      final token = authLocalSources.getToken();
      apiSources.setAuthToken(token);

      // Attempt API creation (online mode) [web:104][web:113]
      final createdRace = await apiSources.createRace(race, categoryPrices);

      // Save to local database for offline access [web:168]
      await localSources.insertRace(createdRace);

      // Create category price records in local database
      for (var entry in categoryPrices.entries) {
        await localSources.createRaceCategoryPrice(
          createdRace.id,
          entry.key,
          entry.value,
        );
      }

      return createdRace.id;
    } catch (e) {
      // Fallback: Create in local database only (offline mode) [web:171][web:172]

      // Calculate chip requirement based on race type
      int racRequired;
      if (race.type == 'Compétitif') {
        racRequired = 1;
      } else {
        racRequired = 0;
      }

      // Transform domain entity to database format
      final raceId = await localSources.createRace({
        'RAI_ID': race.raidId,
        'RAC_NAME': race.name,
        'USE_ID': race.userId,
        'RAC_TYPE': race.type,
        'RAC_DIFFICULTY': race.difficulty,
        'RAC_TIME_START': race.startDate.toIso8601String(),
        'RAC_TIME_END': race.endDate.toIso8601String(),
        'RAC_MIN_PARTICIPANTS': race.minParticipants,
        'RAC_MAX_PARTICIPANTS': race.maxParticipants,
        'RAC_MIN_TEAMS': race.minTeams,
        'RAC_MAX_TEAMS': race.maxTeams,
        'RAC_MAX_TEAM_MEMBERS': race.teamMembers,
        'RAC_AGE_MIN': race.ageMin,
        'RAC_AGE_MIDDLE': race.ageMiddle,
        'RAC_AGE_MAX': race.ageMax,
        'RAC_GENDER': race.sex,
        'RAC_CHIP_MANDATORY': racRequired,
      });

      // Create category price records in local database
      for (var entry in categoryPrices.entries) {
        await localSources.createRaceCategoryPrice(
          raceId,
          entry.key,
          entry.value,
        );
      }

      return raceId;
    }
  }

  @override
  Future<List<Category>> getCategories() async {
    /// Returns fixed age category definitions.
    ///
    /// Age categories are hardcoded and match the Laravel backend seeder.
    /// These are not fetched from API or database as they are static reference
    /// data that never changes [web:167].
    ///
    /// **Category Definitions:**
    /// - **ID 1**: "Mineur" - Minor (under 18 years old)
    /// - **ID 2**: "Majeur non licencié" - Adult without orienteering license
    /// - **ID 3**: "Licencié" - Licensed orienteering athlete
    ///
    /// **Returns:** List of three fixed [Category] objects
    ///
    /// **Example:**
    /// ```dart
    /// final categories = await raceRepo.getCategories();
    /// for (var cat in categories) {
    ///   print('${cat.id}: ${cat.label}');
    /// }
    /// // Output:
    /// // 1: Mineur
    /// // 2: Majeur non licencié
    /// // 3: Licencié
    /// ```
    return [
      Category(id: 1, label: 'Mineur'),
      Category(id: 2, label: 'Majeur non licencié'),
      Category(id: 3, label: 'Licencié'),
    ];
  }

  @override
  Future<Map<int, int>> getRaceCategoryPrices(int raceId) async {
    /// Retrieves category prices for a specific race.
    ///
    /// Fetches pricing information from the local SAN_CATEGORIES_RACES table
    /// and transforms it into a map for easy lookup [web:107]. Prices are
    /// stored and returned in cents (e.g., 2500 = €25.00).
    ///
    /// **Data Source:** Local SQLite only
    ///
    /// **Parameters:**
    /// - [raceId]: The race ID to fetch prices for
    ///
    /// **Returns:** Map of category ID → price in cents
    ///
    /// **Example:**
    /// ```dart
    /// final prices = await raceRepo.getRaceCategoryPrices(42);
    /// for (var entry in prices.entries) {
    ///   final categoryId = entry.key;
    ///   final priceEuros = entry.value / 100;
    ///   print('Category $categoryId: €${priceEuros.toStringAsFixed(2)}');
    /// }
    /// // Output:
    /// // Category 1: €20.00
    /// // Category 2: €25.00
    /// // Category 3: €30.00
    /// ```
    final data = await localSources.getRaceCategoryPrices(raceId);
    return Map.fromEntries(
      data.map(
        (e) => MapEntry(e['CAT_ID'] as int, (e['CAR_PRICE'] as num).toInt()),
      ),
    );
  }

  @override
  Future<bool> canAddRaceToRaid(int raidId) async {
    /// Checks if a raid can accept additional races.
    ///
    /// Validates against the raid's race limit (RAI_NB_RACES) by checking
    /// the current race count. This implements a business rule constraint
    /// to prevent exceeding raid capacity [web:167].
    ///
    /// **Data Source:** Local SQLite only
    ///
    /// **Parameters:**
    /// - [raidId]: The raid ID to check
    ///
    /// **Returns:**
    /// - `true` if raid can accept more races (below limit or no limit set)
    /// - `false` if raid limit reached or raid doesn't exist
    ///
    /// **Example:**
    /// ```dart
    /// if (await raceRepo.canAddRaceToRaid(5)) {
    ///   final raceId = await raceRepo.createRace(newRace, prices);
    ///   print('Race added successfully');
    /// } else {
    ///   final max = await raceRepo.getMaxRaceCount(5);
    ///   print('Cannot add race. Limit reached: $max races');
    /// }
    /// ```
    return await localSources.canAddRaceToRaid(raidId);
  }

  @override
  Future<int> getRaceCount(int raidId) async {
    /// Counts the number of races in a raid.
    ///
    /// Queries local database to count existing race records for the
    /// specified raid [web:107]. Useful for displaying raid statistics
    /// and capacity information.
    ///
    /// **Data Source:** Local SQLite only
    ///
    /// **Parameters:**
    /// - [raidId]: The raid ID to count races for
    ///
    /// **Returns:** Number of races in the raid (0 if none)
    ///
    /// **Example:**
    /// ```dart
    /// final count = await raceRepo.getRaceCount(5);
    /// final max = await raceRepo.getMaxRaceCount(5);
    /// if (max != null) {
    ///   print('Raid capacity: $count / $max races');
    /// } else {
    ///   print('Raid has $count races (unlimited)');
    /// }
    /// ```
    final races = await localSources.getRacesByRaidId(raidId);
    return races.length;
  }

  @override
  Future<int?> getMaxRaceCount(int raidId) async {
    /// Retrieves the maximum race limit for a raid.
    ///
    /// Fetches the RAI_NB_RACES value from the SAN_RAIDS table, which defines
    /// the maximum number of races the raid can contain. Returns null if no
    /// limit is set (unlimited races) [web:107].
    ///
    /// **Data Source:** Local SQLite only
    ///
    /// **Parameters:**
    /// - [raidId]: The raid ID
    ///
    /// **Returns:**
    /// - Integer representing max race count
    /// - `null` if no limit is set (unlimited) or raid doesn't exist
    ///
    /// **Example:**
    /// ```dart
    /// final maxRaces = await raceRepo.getMaxRaceCount(5);
    /// if (maxRaces != null) {
    ///   print('This raid can have up to $maxRaces races');
    /// } else {
    ///   print('This raid has no race limit');
    /// }
    /// ```
    return await localSources.getMaxRaceCount(raidId);
  }
}
