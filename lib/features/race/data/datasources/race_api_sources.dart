import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../domain/race.dart';

/// Race API data source.
///
/// Handles all HTTP communication with the race management backend API, implementing
/// CRUD operations (Create, Read) for race entities within the orienteering event
/// system [web:124][web:127]. This data source follows Clean Architecture principles
/// where services wrap external APIs and handle data transformation [web:92][web:127].
///
/// ## Features
///
/// - **Race Retrieval**: Fetch all races, single race by ID, or races filtered by raid
/// - **Race Creation**: Create races with associated category pricing
/// - **Bearer Authentication**: JWT token-based authentication for secured endpoints [web:129]
/// - **Field Transformation**: Handles API-specific field mapping and data normalization [web:154][web:157]
/// - **Error Handling**: HTTP status code validation with descriptive exceptions [web:127]
/// - **JSON Transformation**: Converts between domain entities and API format [web:152][web:155]
///
/// ## Authentication
///
/// This data source uses Bearer token authentication for protected endpoints (create operations).
/// The token must be set via [setAuthToken] before making authenticated requests [web:129].
/// Public read operations (getAllRaces, getRaceById) do not require authentication.
///
/// ## Field Mapping
///
/// The [createRace] method performs special field transformations to match API requirements:
/// - **RAC_GENDER**: Normalized to API-accepted values ('Homme', 'Femme', 'Mixte')
/// - **RAC_CHIP_MANDATORY**: Auto-calculated (1 for competitive races, 0 otherwise)
/// - **Category Prices**: Transformed to flat structure (CAT_{id}_PRICE format)
///
/// ## API Response Format
///
/// The API returns responses in the following structure:
/// - Success: `{ "data": {...} }` for single objects or `{ "data": [...] }` for lists
/// - Errors: Various HTTP status codes with optional error details in response body
///
/// ## HTTP Status Codes
///
/// - **200/201**: Success (GET, POST operations)
/// - **302**: Authentication required (redirect to login)
/// - **403**: Forbidden - Insufficient permissions (raid manager rights required)
/// - **404**: Not Found - Race doesn't exist
/// - **422**: Validation Error - Invalid request data
///
/// Example usage:
/// ```dart
/// final raceApi = RaceApiSources(
///   baseUrl: 'https://api.example.com',
/// );
///
/// // Set authentication token for protected operations
/// raceApi.setAuthToken('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...');
///
/// // Fetch all races (no auth required)
/// final races = await raceApi.getAllRaces();
///
/// // Create race with pricing (auth required)
/// final newRace = await raceApi.createRace(
///   race,
///   {1: 2500, 2: 3000}, // Category prices in cents
/// );
/// ```
class RaceApiSources {
  /// Base URL for the race API.
  ///
  /// All API endpoints are relative to this base URL.
  /// Example: 'https://api.example.com' or 'http://localhost:3000'
  final String baseUrl;

  /// HTTP client for making network requests.
  ///
  /// Uses the [http] package for REST API communication [web:124][web:152][web:155].
  /// Can be injected for testing purposes.
  final http.Client client;

  /// JWT authentication token for secured API requests.
  ///
  /// Set via [setAuthToken] method. When present, included in the
  /// `Authorization` header as `Bearer {token}` [web:129].
  String? _authToken;

  /// Creates a [RaceApiSources] instance.
  ///
  /// The [baseUrl] parameter is required and should point to the API root.
  /// The [client] parameter is optional and defaults to a new [http.Client],
  /// enabling dependency injection for testing [web:124][web:152].
  RaceApiSources({required this.baseUrl, http.Client? client})
      : client = client ?? http.Client();

  /// Sets the authentication token for API requests.
  ///
  /// The token is stored and automatically included in the `Authorization`
  /// header for protected endpoints (create operations) [web:129]. Call this
  /// method after user login or when refreshing tokens.
  ///
  /// **Parameters:**
  /// - [token]: JWT access token, or null to clear authentication
  ///
  /// **Example:**
  /// ```dart
  /// raceApi.setAuthToken(loginResponse.accessToken);
  /// ```
  void setAuthToken(String? token) {
    _authToken = token;
  }

  /// Retrieves all races from the API.
  ///
  /// Makes a GET request to `/races` endpoint and returns a list of all
  /// registered races in the system [web:124][web:152]. This is a public
  /// endpoint that does not require authentication.
  ///
  /// **Authentication:** Not required (public endpoint)
  ///
  /// **Timeout:** 10 seconds [web:152]
  ///
  /// **Returns:** A list of [Race] objects representing all races
  ///
  /// **Throws:**
  /// - [Exception] with message 'API Error: {code}' for non-200 status codes
  /// - [Exception] with message 'Network error: {details}' for connection failures
  ///
  /// **Example:**
  /// ```dart
  /// try {
  ///   final races = await raceApi.getAllRaces();
  ///   print('Found ${races.length} races');
  ///   for (var race in races) {
  ///     print('${race.name} - ${race.distance}km');
  ///   }
  /// } catch (e) {
  ///   print('Error fetching races: $e');
  /// }
  /// ```
  Future<List<Race>> getAllRaces() async {
    try {
      final response = await client
          .get(
            Uri.parse('$baseUrl/races'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> racesList = responseData['data'];
        return racesList.map((json) => Race.fromJson(json)).toList();
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Retrieves a specific race by its ID.
  ///
  /// Makes a GET request to `/races/{id}` endpoint to fetch details of a
  /// single race [web:124][web:152]. Returns null if the race doesn't exist.
  /// This is a public endpoint that does not require authentication.
  ///
  /// **Authentication:** Not required (public endpoint)
  ///
  /// **Timeout:** 10 seconds [web:152]
  ///
  /// **Parameters:**
  /// - [id]: The unique identifier of the race to retrieve
  ///
  /// **Returns:**
  /// - A [Race] object if found
  /// - `null` if the race doesn't exist (404 status)
  ///
  /// **Throws:**
  /// - [Exception] with message 'API Error: {code}' for non-200/404 status codes
  /// - [Exception] with message 'Network error: {details}' for connection failures
  ///
  /// **Example:**
  /// ```dart
  /// final race = await raceApi.getRaceById(42);
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
      final response = await client
          .get(
            Uri.parse('$baseUrl/races/$id'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final raceData = responseData['data'];
        return Race.fromJson(raceData);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Retrieves all races associated with a specific raid.
  ///
  /// Makes a GET request to `/raids/{raidId}/races` endpoint to fetch all
  /// races that belong to the specified raid event [web:124][web:152]. This
  /// allows filtering races by their parent raid. This is a public endpoint
  /// that does not require authentication.
  ///
  /// **Authentication:** Not required (public endpoint)
  ///
  /// **Timeout:** 10 seconds [web:152]
  ///
  /// **Parameters:**
  /// - [raidId]: The unique identifier of the parent raid event
  ///
  /// **Returns:** A list of [Race] objects belonging to the raid
  ///
  /// **Throws:**
  /// - [Exception] with message 'API Error: {code}' for non-200 status codes
  /// - [Exception] with message 'Network error: {details}' for connection failures
  ///
  /// **Example:**
  /// ```dart
  /// final raidRaces = await raceApi.getRacesByRaid(5);
  /// print('Raid has ${raidRaces.length} races:');
  /// for (var race in raidRaces) {
  ///   print('- ${race.name} (${race.distance}km)');
  /// }
  /// ```
  Future<List<Race>> getRacesByRaid(int raidId) async {
    try {
      final response = await client
          .get(
            Uri.parse('$baseUrl/raids/$raidId/races'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> racesList = responseData['data'];
        return racesList.map((json) => Race.fromJson(json)).toList();
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Creates a new race with associated category pricing.
  ///
  /// Makes a POST request to `/races/with-prices` endpoint to create a new
  /// race entity with prices for each age category [web:124][web:155]. Requires
  /// authentication and raid manager permissions. Performs complex field
  /// transformations to match API requirements [web:154][web:157].
  ///
  /// **Authentication:** Required (Bearer token + Raid Manager rights) [web:129]
  ///
  /// **Timeout:** 10 seconds [web:152]
  ///
  /// ## Field Transformations
  ///
  /// This method performs several transformations on the race data before
  /// sending to the API [web:154][web:157]:
  ///
  /// 1. **Gender Normalization**: Maps RAC_GENDER to API-accepted values
  ///    ('Homme', 'Femme', 'Mixte'). Defaults to 'Mixte' if not specified.
  ///
  /// 2. **Chip Mandatory Calculation**: Automatically sets RAC_CHIP_MANDATORY
  ///    based on race type (1 for 'Compétitif', 0 otherwise).
  ///
  /// 3. **Price Flattening**: Transforms the prices map into flat fields
  ///    (CAT_1_PRICE, CAT_2_PRICE, etc.) as required by the API.
  ///
  /// **Parameters:**
  /// - [race]: The [Race] entity to create (domain object)
  /// - [prices]: Map of category ID to price in cents (e.g., {1: 2500} = 25.00€)
  ///
  /// **Returns:** A [Race] object representing the newly created race with
  /// assigned ID and any server-generated fields
  ///
  /// **Throws:**
  /// - [Exception] 'Non authentifié...' if token is invalid or missing (302)
  /// - [Exception] 'Accès refusé...' if user is not the raid manager (403)
  /// - [Exception] 'Erreur de validation...' for invalid data with error details (422)
  /// - [Exception] 'Erreur serveur: {code}' for other HTTP errors
  /// - [Exception] 'Network error: {details}' for connection failures
  ///
  /// **Example:**
  /// ```dart
  /// // Create a competitive 10km race with category pricing
  /// final race = Race(
  ///   name: 'Trail 10km',
  ///   distance: 10.0,
  ///   type: 'Compétitif',
  ///   gender: 'Mixte',
  ///   maxTeamMembers: 1,
  ///   raidId: 5,
  /// );
  ///
  /// // Define prices for age categories (in cents)
  /// final prices = {
  ///   1: 2500,  // Category 1: 25.00€
  ///   2: 3000,  // Category 2: 30.00€
  ///   3: 2000,  // Category 3: 20.00€
  /// };
  ///
  /// try {
  ///   final createdRace = await raceApi.createRace(race, prices);
  ///   print('Race created with ID: ${createdRace.id}');
  ///   print('Chip mandatory: ${createdRace.chipMandatory ? "Yes" : "No"}');
  /// } catch (e) {
  ///   print('Failed to create race: $e');
  /// }
  /// ```
  Future<Race> createRace(Race race, Map<int, int> prices) async {
    try {
      // Convert race domain object to JSON [web:157]
      final raceJson = race.toJson();

      // Field transformation: Normalize gender to API-accepted values [web:154][web:157]
      // API only accepts: 'Homme', 'Femme', 'Mixte'
      final sexValue = raceJson.remove('RAC_GENDER') as String?;
      raceJson['RAC_GENDER'] = sexValue ?? 'Mixte';

      // Preserve max team members field (no transformation needed)
      raceJson['RAC_MAX_TEAM_MEMBERS'] = raceJson.remove(
        'RAC_MAX_TEAM_MEMBERS',
      );

      // Auto-calculate chip requirement based on race type [web:154]
      // Competitive races require timing chips, recreational do not
      raceJson['RAC_CHIP_MANDATORY'] = race.type == 'Compétitif' ? 1 : 0;

      // Transform prices map into flat API structure [web:154]
      // Converts {1: 2500, 2: 3000} to {CAT_1_PRICE: 2500, CAT_2_PRICE: 3000}
      prices.forEach((catId, price) {
        raceJson['CAT_${catId}_PRICE'] = price;
      });

      final body = json.encode(raceJson);

      final headers = {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

      final response = await client
          .post(
            Uri.parse('$baseUrl/races/with-prices'),
            headers: headers,
            body: body,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final raceData = responseData['data'];
        return Race.fromJson(raceData);
      } else if (response.statusCode == 302) {
        throw Exception(
          'Non authentifié - Vous devez être connecté via l\'API',
        );
      } else if (response.statusCode == 403) {
        throw Exception(
          'Accès refusé - Seul le gestionnaire du raid peut créer des courses',
        );
      } else if (response.statusCode == 422) {
        final errorData = json.decode(response.body);
        throw Exception(
          'Erreur de validation : ${errorData['errors'] ?? response.body}',
        );
      } else {
        throw Exception('Erreur serveur : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Récupérer les détails d'une course (inclus les stats)
  Future<Map<String, dynamic>> getRaceDetails(int id) async {
    try {
      final response = await client
          .get(
            Uri.parse('$baseUrl/races/$id/details'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['data'] as Map<String, dynamic>;
      } else {
        throw Exception('API Error details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
