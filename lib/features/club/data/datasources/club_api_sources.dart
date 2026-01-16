// lib/features/club/data/datasources/club_api_sources.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/club.dart';
import '../../../user/domain/user.dart';

/// Club API data source.
///
/// Handles all HTTP communication with the club management backend API, implementing
/// full CRUD (Create, Read, Update, Delete) operations for club entities [web:124][web:125].
/// This data source follows Clean Architecture principles where services wrap external
/// APIs and handle data transformation [web:92][web:127].
///
/// ## Features
///
/// - **CRUD Operations**: Complete set of operations for club management [web:128]
/// - **Bearer Authentication**: JWT token-based authentication for secured endpoints [web:129][web:132]
/// - **Member Management**: Fetch club members with user details
/// - **Error Handling**: HTTP status code validation with descriptive exceptions [web:127]
/// - **JSON Transformation**: Converts raw JSON responses to domain entities [web:130]
///
/// ## Authentication
///
/// This data source uses Bearer token authentication [web:129][web:132]. The token must
/// be set via [setAuthToken] before making authenticated requests. The token is included
/// in the `Authorization` header as `Bearer {token}` for all API calls [web:129].
///
/// ## API Response Format
///
/// The API is expected to return responses in the following formats:
/// - Success: `{ "data": {...} }` or direct object
/// - List: `{ "data": [...] }` or direct array
/// - Error: Various HTTP status codes with optional error details
///
/// ## HTTP Status Codes
///
/// - **200/201**: Success (GET, POST, PUT operations)
/// - **204**: Success with no content (DELETE operations)
/// - **401**: Unauthorized - Invalid or missing authentication token
/// - **403**: Forbidden - Insufficient permissions (admin rights required)
/// - **404**: Not Found - Resource doesn't exist
/// - **422**: Validation Error - Invalid request data
///
/// Example usage:
/// ```dart
/// final clubApi = ClubApiSources(
///   baseUrl: 'https://api.example.com',
/// );
///
/// // Set authentication token
/// clubApi.setAuthToken('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...');
///
/// // Fetch all clubs
/// try {
///   final clubs = await clubApi.getClubs();
///   print('Found ${clubs.length} clubs');
/// } catch (e) {
///   print('Error: $e');
/// }
/// ```
class ClubApiSources {
  /// Base URL for the club API.
  ///
  /// All API endpoints are relative to this base URL.
  /// Example: 'https://api.example.com' or 'http://localhost:3000'
  final String baseUrl;

  /// HTTP client for making network requests.
  ///
  /// Uses the [http] package for REST API communication [web:124][web:125].
  /// Can be injected for testing purposes.
  final http.Client client;

  /// JWT authentication token for secured API requests.
  ///
  /// Set via [setAuthToken] method. When present, included in the
  /// `Authorization` header as `Bearer {token}` [web:129][web:132].
  String? _authToken;

  /// Creates a [ClubApiSources] instance.
  ///
  /// The [baseUrl] parameter is required and should point to the API root.
  /// The [client] parameter is optional and defaults to a new [http.Client],
  /// enabling dependency injection for testing [web:124].
  ClubApiSources({required this.baseUrl, http.Client? client})
      : client = client ?? http.Client();

  /// Sets the authentication token for API requests.
  ///
  /// The token is stored and automatically included in the `Authorization`
  /// header for all subsequent API calls [web:129][web:132]. Call this method
  /// after user login or when refreshing tokens.
  ///
  /// **Parameters:**
  /// - [token]: JWT access token, or null to clear authentication
  ///
  /// **Example:**
  /// ```dart
  /// clubApi.setAuthToken(loginResponse.accessToken);
  /// ```
  void setAuthToken(String? token) {
    _authToken = token;
  }

  /// Retrieves all clubs from the API.
  ///
  /// Makes a GET request to `/clubs` endpoint and returns a list of all
  /// registered clubs in the system [web:124][web:125]. Requires authentication
  /// token to be set via [setAuthToken] [web:129].
  ///
  /// **Authentication:** Required (Bearer token) [web:129][web:132]
  ///
  /// **Returns:** A list of [Club] objects representing all clubs
  ///
  /// **Throws:**
  /// - [Exception] with message 'Non authentifié...' if token is invalid (401)
  /// - [Exception] with message 'Failed to fetch clubs...' for other HTTP errors
  /// - [Exception] with message 'Network error...' for connection failures
  ///
  /// **Example:**
  /// ```dart
  /// try {
  ///   final clubs = await clubApi.getClubs();
  ///   for (var club in clubs) {
  ///     print('${club.name} - ${club.memberCount} members');
  ///   }
  /// } catch (e) {
  ///   print('Error fetching clubs: $e');
  /// }
  /// ```
  Future<List<Club>> getClubs() async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

      final url = '$baseUrl/clubs';

      final response = await client.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> clubsJson = responseData['data'] ?? responseData;
        return clubsJson.map((json) => Club.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Non authentifié - Token invalide ou manquant');
      } else {
        throw Exception('Failed to fetch clubs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Retrieves a specific club by its ID.
  ///
  /// Makes a GET request to `/clubs/{id}` endpoint to fetch details of a
  /// single club [web:124][web:125]. Returns null if the club doesn't exist.
  ///
  /// **Authentication:** Required (Bearer token) [web:129][web:132]
  ///
  /// **Parameters:**
  /// - [id]: The unique identifier of the club to retrieve
  ///
  /// **Returns:**
  /// - A [Club] object if found
  /// - `null` if the club doesn't exist (404 status)
  ///
  /// **Throws:**
  /// - [Exception] with message 'Non authentifié...' if token is invalid (401)
  /// - [Exception] with message 'Failed to fetch club...' for other HTTP errors
  /// - [Exception] with message 'Network error...' for connection failures
  ///
  /// **Example:**
  /// ```dart
  /// final club = await clubApi.getClubById(42);
  /// if (club != null) {
  ///   print('Found: ${club.name}');
  /// } else {
  ///   print('Club not found');
  /// }
  /// ```
  Future<Club?> getClubById(int id) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

      final url = '$baseUrl/clubs/$id';

      final response = await client.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final clubJson = responseData['data'] ?? responseData;

        return Club.fromJson(clubJson);
      } else if (response.statusCode == 404) {
        return null;
      } else if (response.statusCode == 401) {
        throw Exception('Non authentifié - Token invalide ou manquant');
      } else {
        throw Exception('Failed to fetch club: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Retrieves all members of a specific club.
  ///
  /// Makes a GET request to `/clubs/{clubId}/users` endpoint to fetch the list
  /// of users who are members of the specified club [web:124][web:125].
  ///
  /// **Authentication:** Required (Bearer token) [web:129][web:132]
  ///
  /// **Parameters:**
  /// - [clubId]: The unique identifier of the club
  ///
  /// **Returns:** A list of [User] objects representing club members
  ///
  /// **Throws:**
  /// - [Exception] with message 'Non authentifié...' if token is invalid (401)
  /// - [Exception] with message 'Failed to fetch club members...' for other HTTP errors
  /// - [Exception] with message 'Network error...' for connection failures
  ///
  /// **Example:**
  /// ```dart
  /// final members = await clubApi.getClubMembers(42);
  /// print('${members.length} members in this club');
  /// for (var member in members) {
  ///   print('${member.firstName} ${member.lastName}');
  /// }
  /// ```
  Future<List<User>> getClubMembers(int clubId) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

      final url = '$baseUrl/clubs/$clubId/users';

      final response = await client.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> membersJson = responseData['data'] ?? responseData;

        return membersJson.map((json) => User.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Non authentifié - Token invalide ou manquant');
      } else {
        throw Exception('Failed to fetch club members: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Creates a new club via the API.
  ///
  /// Makes a POST request to `/clubs` endpoint with club data to create a new
  /// club entity [web:125][web:128]. Requires admin permissions to execute successfully.
  ///
  /// **Authentication:** Required (Bearer token + Admin rights) [web:129][web:132]
  ///
  /// **Parameters:**
  /// - [name]: The name of the new club (CLU_NAME in API)
  /// - [responsibleId]: User ID of the club's responsible person (USE_ID in API)
  /// - [addressId]: Address ID for the club's location (ADD_ID in API)
  ///
  /// **Returns:** A [Club] object representing the newly created club
  ///
  /// **Throws:**
  /// - [Exception] with message 'Non authentifié...' if token is invalid (401)
  /// - [Exception] with message 'Accès refusé - Droits admin requis' if not admin (403)
  /// - [Exception] with message 'Erreur de validation...' for invalid data (422)
  /// - [Exception] with message 'Failed to create club...' for other HTTP errors
  /// - [Exception] with message 'Network error...' for connection failures
  ///
  /// **Example:**
  /// ```dart
  /// try {
  ///   final newClub = await clubApi.createClub(
  ///     name: 'Alpine Orienteering Club',
  ///     responsibleId: 123,
  ///     addressId: 456,
  ///   );
  ///   print('Created club: ${newClub.name} (ID: ${newClub.id})');
  /// } catch (e) {
  ///   print('Failed to create club: $e');
  /// }
  /// ```
  Future<Club> createClub({
    required String name,
    required int responsibleId,
    required int addressId,
  }) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

      final body = json.encode({
        'CLU_NAME': name,
        'USE_ID': responsibleId,
        'ADD_ID': addressId,
      });

      final response = await client.post(
        Uri.parse('$baseUrl/clubs'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final clubJson = responseData['data'] ?? responseData;

        return Club.fromJson(clubJson);
      } else if (response.statusCode == 401) {
        throw Exception('Non authentifié - Token invalide ou manquant');
      } else if (response.statusCode == 403) {
        throw Exception('Accès refusé - Droits admin requis');
      } else if (response.statusCode == 422) {
        final errorData = json.decode(response.body);
        throw Exception(
          'Erreur de validation: ${errorData['errors'] ?? response.body}',
        );
      } else {
        throw Exception('Failed to create club: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Updates an existing club via the API.
  ///
  /// Makes a PUT request to `/clubs/{id}` endpoint to update club information
  /// [web:125][web:128]. Only provided (non-null) fields will be updated, allowing
  /// partial updates. Requires admin permissions to execute successfully.
  ///
  /// **Authentication:** Required (Bearer token + Admin rights) [web:129][web:132]
  ///
  /// **Parameters:**
  /// - [id]: The unique identifier of the club to update
  /// - [name]: New club name (optional)
  /// - [responsibleId]: New responsible person ID (optional)
  /// - [addressId]: New address ID (optional)
  ///
  /// **Returns:** A [Club] object with the updated information
  ///
  /// **Throws:**
  /// - [Exception] with message 'Non authentifié' if token is invalid (401)
  /// - [Exception] with message 'Accès refusé - Droits admin requis' if not admin (403)
  /// - [Exception] with message 'Failed to update club...' for other HTTP errors
  /// - [Exception] with message 'Network error...' for connection failures
  ///
  /// **Example:**
  /// ```dart
  /// // Update only the club name
  /// final updated = await clubApi.updateClub(
  ///   id: 42,
  ///   name: 'New Club Name',
  /// );
  /// print('Club updated: ${updated.name}');
  /// ```
  Future<Club> updateClub({
    required int id,
    String? name,
    int? responsibleId,
    int? addressId,
  }) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

      // Build request body with only non-null fields
      final bodyMap = <String, dynamic>{};
      if (name != null) bodyMap['CLU_NAME'] = name;
      if (responsibleId != null) bodyMap['USE_ID'] = responsibleId;
      if (addressId != null) bodyMap['ADD_ID'] = addressId;

      final body = json.encode(bodyMap);

      final response = await client.put(
        Uri.parse('$baseUrl/clubs/$id'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final clubJson = responseData['data'] ?? responseData;

        return Club.fromJson(clubJson);
      } else if (response.statusCode == 401) {
        throw Exception('Non authentifié');
      } else if (response.statusCode == 403) {
        throw Exception('Accès refusé - Droits admin requis');
      } else {
        throw Exception('Failed to update club: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Deletes a club via the API.
  ///
  /// Makes a DELETE request to `/clubs/{id}` endpoint to permanently remove
  /// a club from the system [web:125][web:128]. Requires admin permissions.
  ///
  /// **Authentication:** Required (Bearer token + Admin rights) [web:129][web:132]
  ///
  /// **Parameters:**
  /// - [id]: The unique identifier of the club to delete
  ///
  /// **Returns:** Completes successfully with no return value
  ///
  /// **Throws:**
  /// - [Exception] with message 'Non authentifié' if token is invalid (401)
  /// - [Exception] with message 'Accès refusé - Droits admin requis' if not admin (403)
  /// - [Exception] with message 'Failed to delete club...' for other HTTP errors
  /// - [Exception] with message 'Network error...' for connection failures
  ///
  /// **Warning:** This operation is permanent and cannot be undone. Ensure
  /// confirmation before calling this method.
  ///
  /// **Example:**
  /// ```dart
  /// try {
  ///   await clubApi.deleteClub(42);
  ///   print('Club deleted successfully');
  /// } catch (e) {
  ///   print('Failed to delete club: $e');
  /// }
  /// ```
  Future<void> deleteClub(int id) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

      final response = await client.delete(
        Uri.parse('$baseUrl/clubs/$id'),
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
      } else if (response.statusCode == 401) {
        throw Exception('Non authentifié');
      } else if (response.statusCode == 403) {
        throw Exception('Accès refusé - Droits admin requis');
      } else {
        throw Exception('Failed to delete club: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
