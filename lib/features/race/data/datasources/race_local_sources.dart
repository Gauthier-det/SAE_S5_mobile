import 'package:sae5_g13_mobile/core/database/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import '../../domain/race.dart';

/// Race local data source (SQLite).
///
/// Handles all database operations for race entities using SQLite as the local
/// storage mechanism [web:158][web:161]. This data source follows Clean Architecture's
/// data layer pattern, providing persistent local storage for race information
/// [web:164][web:166].
///
/// ## Database Schema
///
/// This data source interacts with the following SQLite tables:
///
/// - **SAN_RACES**: Main race table with race details (name, distance, type, etc.)
/// - **SAN_CATEGORIES_RACES**: Junction table linking races to age categories with prices
/// - **SAN_CATEGORIES**: Age category reference table (labels and details)
/// - **SAN_TEAMS_RACES**: Junction table tracking team registrations for races
/// - **SAN_RAIDS**: Parent raid table containing race limits (RAI_NB_RACES)
///
/// ## Features
///
/// - **CRUD Operations**: Full support for Create, Read operations [web:162][web:165]
/// - **Relationship Queries**: Fetches related data across multiple tables using JOINs [web:163]
/// - **Conflict Resolution**: Uses [ConflictAlgorithm.replace] for upsert operations [web:161]
/// - **Data Synchronization**: Supports clearing and replacing data from API [web:164]
/// - **Business Rules**: Validates raid capacity constraints before creation
///
/// ## Query Patterns
///
/// This data source uses both high-level [Database.query] methods and raw SQL
/// queries [web:163]:
/// - Simple queries: Use [Database.query] with where clauses [web:163][web:165]
/// - Complex queries: Use [Database.rawQuery] for JOINs and aggregations [web:163]
/// - Data binding: Uses parameterized queries (?) to prevent SQL injection [web:163]
///
/// ## Singleton Database Instance
///
/// The [database] parameter should be obtained from [DatabaseHelper.database],
/// which provides a singleton instance of the SQLite database [web:162]. This
/// ensures consistent database access throughout the application.
///
/// Example usage:
/// ```dart
/// final db = await DatabaseHelper.database;
/// final raceLocal = RaceLocalSources(database: db);
///
/// // Fetch all races
/// final races = await raceLocal.getAllRaces();
///
/// // Get races for a specific raid
/// final raidRaces = await raceLocal.getRacesByRaidId(5);
///
/// // Check if raid can accept more races
/// final canAdd = await raceLocal.canAddRaceToRaid(5);
/// if (canAdd) {
///   await raceLocal.createRace({
///     'RAC_NAME': 'Trail 10km',
///     'RAC_DISTANCE': 10.0,
///     'RAI_ID': 5,
///   });
/// }
/// ```
class RaceLocalSources {
  /// SQLite database instance.
  ///
  /// Should be obtained from [DatabaseHelper.database] to ensure
  /// singleton pattern and proper database lifecycle management [web:162].
  final Database database;

  /// Creates a [RaceLocalSources] instance.
  ///
  /// The [database] parameter should be the singleton instance from
  /// [DatabaseHelper] to ensure consistent database access [web:162].
  RaceLocalSources({required this.database});

  /// Retrieves all races from the database.
  ///
  /// Queries the SAN_RACES table and returns all race records ordered by
  /// start time in descending order (most recent first) [web:158][web:163][web:165].
  ///
  /// **Query:** `SELECT * FROM SAN_RACES ORDER BY RAC_TIME_START DESC`
  ///
  /// **Returns:** A list of [Race] objects representing all races in the database
  ///
  /// **Throws:**
  /// - [Exception] with message 'Database error: {details}' if query fails
  ///
  /// **Example:**
  /// ```dart
  /// try {
  ///   final races = await raceLocal.getAllRaces();
  ///   print('Found ${races.length} races');
  ///   for (var race in races) {
  ///     print('${race.name} - ${race.distance}km on ${race.startTime}');
  ///   }
  /// } catch (e) {
  ///   print('Error: $e');
  /// }
  /// ```
  Future<List<Race>> getAllRaces() async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        'SAN_RACES',
        orderBy: 'RAC_TIME_START DESC',
      );
      return maps.map((map) => Race.fromJson(map)).toList();
    } catch (e) {
      throw Exception('Database error: $e');
    }
  }

  /// Retrieves all races for a specific raid.
  ///
  /// Queries the SAN_RACES table filtering by raid ID and returns races
  /// ordered by start time in ascending order (chronological) [web:158][web:163].
  /// This allows displaying races for a single event in the order they occur.
  ///
  /// **Query:** `SELECT * FROM SAN_RACES WHERE RAI_ID = ? ORDER BY RAC_TIME_START ASC`
  ///
  /// **Parameters:**
  /// - [raidId]: The unique identifier of the parent raid event
  ///
  /// **Returns:** A list of [Race] objects belonging to the specified raid
  ///
  /// **Throws:**
  /// - [Exception] with message 'Database error: {details}' if query fails
  ///
  /// **Example:**
  /// ```dart
  /// final raidRaces = await raceLocal.getRacesByRaidId(5);
  /// print('Raid #5 has ${raidRaces.length} races:');
  /// for (var race in raidRaces) {
  ///   print('- ${race.name} at ${race.startTime}');
  /// }
  /// ```
  Future<List<Race>> getRacesByRaidId(int raidId) async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        'SAN_RACES',
        where: 'RAI_ID = ?',
        whereArgs: [raidId],
        orderBy: 'RAC_TIME_START ASC',
      );
      return maps.map((map) => Race.fromJson(map)).toList();
    } catch (e) {
      throw Exception('Database error: $e');
    }
  }

  /// Counts the number of teams registered for a specific race.
  ///
  /// Queries the SAN_TEAMS_RACES junction table to count team registrations
  /// for the given race [web:163]. This is useful for checking race capacity
  /// and displaying registration statistics.
  ///
  /// **Query:** `SELECT COUNT(*) FROM SAN_TEAMS_RACES WHERE RAC_ID = ?`
  ///
  /// **Parameters:**
  /// - [raceId]: The unique identifier of the race
  ///
  /// **Returns:** The number of teams registered for the race (0 if none)
  ///
  /// **Example:**
  /// ```dart
  /// final registeredCount = await raceLocal.getRegisteredTeamsCount(42);
  /// final maxTeams = race.maxTeams;
  /// print('Race capacity: $registeredCount / $maxTeams teams');
  ///
  /// if (registeredCount >= maxTeams) {
  ///   print('Race is full!');
  /// }
  /// ```
  Future<int> getRegisteredTeamsCount(int raceId) async {
    final db = await DatabaseHelper.database;

    final result = await db.rawQuery(
      '''
    SELECT COUNT(*) as count
    FROM SAN_TEAMS_RACES
    WHERE RAC_ID = ?
  ''',
      [raceId],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Retrieves a specific race by its ID.
  ///
  /// Queries the SAN_RACES table for a single race record [web:158][web:163].
  /// Returns null if the race doesn't exist in the database.
  ///
  /// **Query:** `SELECT * FROM SAN_RACES WHERE RAC_ID = ?`
  ///
  /// **Parameters:**
  /// - [id]: The unique identifier of the race
  ///
  /// **Returns:**
  /// - A [Race] object if found
  /// - `null` if the race doesn't exist
  ///
  /// **Throws:**
  /// - [Exception] with message 'Database error: {details}' if query fails
  ///
  /// **Example:**
  /// ```dart
  /// final race = await raceLocal.getRaceById(42);
  /// if (race != null) {
  ///   print('Found: ${race.name}');
  ///   print('Distance: ${race.distance}km');
  ///   print('Type: ${race.type}');
  /// } else {
  ///   print('Race not found');
  /// }
  /// ```
  Future<Race?> getRaceById(int id) async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        'SAN_RACES',
        where: 'RAC_ID = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) {
        return null;
      }

      return Race.fromJson(maps.first);
    } catch (e) {
      throw Exception('Database error: $e');
    }
  }

  /// Retrieves category prices for a specific race.
  ///
  /// Performs a JOIN query between SAN_CATEGORIES_RACES and SAN_CATEGORIES
  /// tables to fetch both price and category label information [web:163].
  /// This is useful for displaying pricing information to users during registration.
  ///
  /// **Query:**
  /// ```sql
  /// SELECT rc.CAT_ID, c.CAT_LABEL, rc.CAR_PRICE as price
  /// FROM SAN_CATEGORIES_RACES rc
  /// INNER JOIN SAN_CATEGORIES c ON rc.CAT_ID = c.CAT_ID
  /// WHERE rc.RAC_ID = ?
  /// ORDER BY c.CAT_LABEL
  /// ```
  ///
  /// **Parameters:**
  /// - [raceId]: The unique identifier of the race
  ///
  /// **Returns:** A list of maps containing:
  /// - `CAT_ID`: Category ID
  /// - `CAT_LABEL`: Category label (e.g., "Junior", "Senior", "Veteran")
  /// - `price`: Price in cents (e.g., 2500 = 25.00€)
  ///
  /// **Example:**
  /// ```dart
  /// final prices = await raceLocal.getRaceCategoryPrices(42);
  /// for (var category in prices) {
  ///   final label = category['CAT_LABEL'];
  ///   final price = (category['price'] as int) / 100;
  ///   print('$label: €${price.toStringAsFixed(2)}');
  /// }
  /// // Output:
  /// // Junior: €20.00
  /// // Senior: €25.00
  /// // Veteran: €22.50
  /// ```
  Future<List<Map<String, dynamic>>> getRaceCategoryPrices(int raceId) async {
    final db = await DatabaseHelper.database;
    return await db.rawQuery(
      '''
      SELECT rc.CAT_ID, c.CAT_LABEL, rc.CAR_PRICE as price
      FROM SAN_CATEGORIES_RACES rc
      INNER JOIN SAN_CATEGORIES c ON rc.CAT_ID = c.CAT_ID
      WHERE rc.RAC_ID = ?
      ORDER BY c.CAT_LABEL
    ''',
      [raceId],
    );
  }

  /// Retrieves all available age categories.
  ///
  /// Queries the SAN_CATEGORIES table to fetch all category definitions
  /// ordered alphabetically by label [web:158][web:163]. Used for populating
  /// category selection dropdowns and displaying available options.
  ///
  /// **Query:** `SELECT * FROM SAN_CATEGORIES ORDER BY CAT_LABEL ASC`
  ///
  /// **Returns:** A list of maps containing category data (CAT_ID, CAT_LABEL, etc.)
  ///
  /// **Example:**
  /// ```dart
  /// final categories = await raceLocal.getCategories();
  /// for (var cat in categories) {
  ///   print('${cat['CAT_ID']}: ${cat['CAT_LABEL']}');
  /// }
  /// // Output:
  /// // 1: Junior (Under 18)
  /// // 2: Senior (18-39)
  /// // 3: Veteran (40+)
  /// ```
  Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await DatabaseHelper.database;
    return await db.query('SAN_CATEGORIES', orderBy: 'CAT_LABEL ASC');
  }

  /// Creates a new race in the database.
  ///
  /// Inserts a new race record into the SAN_RACES table [web:162][web:165].
  /// The [raceData] map should contain all required fields matching the
  /// database schema.
  ///
  /// **Required Fields:**
  /// - RAC_NAME: Race name
  /// - RAC_DISTANCE: Distance in kilometers
  /// - RAC_TYPE: Race type ('Compétitif' or 'Loisir')
  /// - RAI_ID: Parent raid ID
  /// - RAC_TIME_START: Start time
  /// - RAC_MAX_TEAM_MEMBERS: Maximum team size
  /// - RAC_GENDER: Gender restriction ('Homme', 'Femme', 'Mixte')
  ///
  /// **Parameters:**
  /// - [raceData]: Map containing race field values
  ///
  /// **Returns:** The auto-generated race ID (RAC_ID) of the inserted record
  ///
  /// **Example:**
  /// ```dart
  /// final raceId = await raceLocal.createRace({
  ///   'RAC_NAME': 'Trail 10km',
  ///   'RAC_DISTANCE': 10.0,
  ///   'RAC_TYPE': 'Compétitif',
  ///   'RAI_ID': 5,
  ///   'RAC_TIME_START': '2024-06-15 09:00:00',
  ///   'RAC_MAX_TEAM_MEMBERS': 1,
  ///   'RAC_GENDER': 'Mixte',
  /// });
  /// print('Created race with ID: $raceId');
  /// ```
  Future<int> createRace(Map<String, dynamic> raceData) async {
    final db = await DatabaseHelper.database;
    return await db.insert('SAN_RACES', raceData);
  }

  /// Inserts or updates a race from API data.
  ///
  /// Uses [ConflictAlgorithm.replace] to perform an upsert operation [web:161][web:162].
  /// If a race with the same ID exists, it will be replaced with the new data.
  /// This is useful for synchronizing local data with API responses [web:164].
  ///
  /// **Parameters:**
  /// - [race]: The [Race] entity to insert/update
  ///
  /// **Behavior:**
  /// - If race ID doesn't exist: Inserts new record
  /// - If race ID exists: Replaces existing record with new data
  ///
  /// **Example:**
  /// ```dart
  /// // Sync race from API response
  /// final apiRace = Race.fromJson(apiResponse['data']);
  /// await raceLocal.insertRace(apiRace);
  /// print('Race synchronized: ${apiRace.name}');
  /// ```
  Future<void> insertRace(Race race) async {
    final db = await DatabaseHelper.database;
    await db.insert(
      'SAN_RACES',
      race.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Deletes all races for a specific raid.
  ///
  /// Removes all race records belonging to the specified raid from the
  /// SAN_RACES table [web:165]. This is typically used before synchronizing
  /// raid data from the API to ensure a clean slate [web:164].
  ///
  /// **Query:** `DELETE FROM SAN_RACES WHERE RAI_ID = ?`
  ///
  /// **Parameters:**
  /// - [raidId]: The unique identifier of the raid whose races should be deleted
  ///
  /// **Warning:** This operation is permanent and cannot be undone. Use with
  /// caution, typically only when replacing with fresh API data.
  ///
  /// **Example:**
  /// ```dart
  /// // Clear existing races before syncing from API
  /// await raceLocal.clearRacesByRaidId(5);
  ///
  /// // Insert fresh data from API
  /// for (var apiRace in apiRaces) {
  ///   await raceLocal.insertRace(apiRace);
  /// }
  /// print('Raid races synchronized');
  /// ```
  Future<void> clearRacesByRaidId(int raidId) async {
    final db = await DatabaseHelper.database;
    await db.delete('SAN_RACES', where: 'RAI_ID = ?', whereArgs: [raidId]);
  }

  /// Creates or updates a category price for a race.
  ///
  /// Inserts a new record into the SAN_CATEGORIES_RACES junction table,
  /// linking a race to a category with its associated price [web:162][web:165].
  /// Uses [ConflictAlgorithm.replace] for upsert behavior [web:161].
  ///
  /// **Parameters:**
  /// - [raceId]: The race ID
  /// - [categoryId]: The category ID
  /// - [price]: Price in cents (e.g., 2500 = 25.00€)
  ///
  /// **Example:**
  /// ```dart
  /// // Set pricing for a race
  /// await raceLocal.createRaceCategoryPrice(42, 1, 2000); // Junior: €20
  /// await raceLocal.createRaceCategoryPrice(42, 2, 2500); // Senior: €25
  /// await raceLocal.createRaceCategoryPrice(42, 3, 2250); // Veteran: €22.50
  /// print('Category pricing configured');
  /// ```
  Future<void> createRaceCategoryPrice(
    int raceId,
    int categoryId,
    int price,
  ) async {
    final db = await DatabaseHelper.database;
    await db.insert(
      'SAN_CATEGORIES_RACES',
      {
        'RAC_ID': raceId,
        'CAT_ID': categoryId,
        'CAR_PRICE': price,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Checks if a raid can accept additional races.
  ///
  /// Validates against the raid's race limit (RAI_NB_RACES) by counting
  /// existing races and comparing to the maximum allowed [web:163]. This
  /// implements a business rule constraint to prevent exceeding raid capacity.
  ///
  /// **Logic:**
  /// 1. Fetches raid's RAI_NB_RACES limit from SAN_RAIDS table
  /// 2. If no limit set (null): Returns true (unlimited races)
  /// 3. Counts existing races for the raid
  /// 4. Returns true if current count < limit
  ///
  /// **Parameters:**
  /// - [raidId]: The unique identifier of the raid
  ///
  /// **Returns:**
  /// - `true` if raid can accept more races
  /// - `false` if raid limit reached or raid doesn't exist
  ///
  /// **Example:**
  /// ```dart
  /// if (await raceLocal.canAddRaceToRaid(5)) {
  ///   await raceLocal.createRace({...});
  ///   print('Race added successfully');
  /// } else {
  ///   final max = await raceLocal.getMaxRaceCount(5);
  ///   print('Cannot add race. Limit reached: $max races');
  /// }
  /// ```
  Future<bool> canAddRaceToRaid(int raidId) async {
    final db = await DatabaseHelper.database;

    // Fetch raid with its race limit
    final raidResult = await db.query(
      'SAN_RAIDS',
      columns: ['RAI_NB_RACES'],
      where: 'RAI_ID = ?',
      whereArgs: [raidId],
      limit: 1,
    );

    if (raidResult.isEmpty) return false;

    final maxRaces = raidResult.first['RAI_NB_RACES'] as int?;

    // If no limit defined, allow unlimited races
    if (maxRaces == null) return true;

    // Count existing races for this raid
    final countResult = await db.rawQuery(
      '''
      SELECT COUNT(*) as count
      FROM SAN_RACES
      WHERE RAI_ID = ?
    ''',
      [raidId],
    );

    final currentCount = countResult.first['count'] as int;

    return currentCount < maxRaces;
  }

  /// Retrieves the maximum number of races allowed for a raid.
  ///
  /// Fetches the RAI_NB_RACES value from the SAN_RAIDS table, which defines
  /// the maximum number of races the raid can contain [web:163]. This is used
  /// for displaying capacity information and validation.
  ///
  /// **Query:** `SELECT RAI_NB_RACES FROM SAN_RAIDS WHERE RAI_ID = ?`
  ///
  /// **Parameters:**
  /// - [raidId]: The unique identifier of the raid
  ///
  /// **Returns:**
  /// - An integer representing the maximum race count
  /// - `null` if raid doesn't exist or no limit is set (unlimited)
  ///
  /// **Example:**
  /// ```dart
  /// final maxRaces = await raceLocal.getMaxRaceCount(5);
  /// final currentRaces = await raceLocal.getRacesByRaidId(5);
  ///
  /// if (maxRaces != null) {
  ///   print('Raid capacity: ${currentRaces.length} / $maxRaces races');
  /// } else {
  ///   print('Raid capacity: ${currentRaces.length} races (unlimited)');
  /// }
  /// ```
  Future<int?> getMaxRaceCount(int raidId) async {
    final db = await DatabaseHelper.database;

    final raidResult = await db.query(
      'SAN_RAIDS',
      columns: ['RAI_NB_RACES'],
      where: 'RAI_ID = ?',
      whereArgs: [raidId],
      limit: 1,
    );

    if (raidResult.isEmpty) return null;

    return raidResult.first['RAI_NB_RACES'] as int?;
  }
}
