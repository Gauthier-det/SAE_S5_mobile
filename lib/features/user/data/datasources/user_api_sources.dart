// lib/features/users/data/datasources/user_api_sources.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../domain/user.dart';

/// API data source for user operations in data layer [web:299][web:300][web:302].
///
/// Handles HTTP requests to Laravel backend with bearer token authentication.
/// Converts raw JSON responses to User domain models and handles API-specific
/// error codes (401, 403, 404, 422) [web:303][web:304][web:306].
///
/// **Features:**
/// - Bearer token authentication [web:304][web:307]
/// - Laravel response format handling (data wrapping)
/// - Comprehensive HTTP error handling [web:303][web:306]
/// - Injectable http.Client for testing [web:299]
///
/// **API Response Format:**
/// Laravel wraps data in `{data: {...}}` structure. Methods extract
/// the inner data object for User.fromJson parsing.
///
/// **Error Handling [web:303][web:306]:**
/// - 401: Authentication failure
/// - 403: Authorization failure (insufficient permissions)
/// - 404: Resource not found
/// - 422: Validation error
/// - Network errors: Wrapped in Exception
///
/// Example:
/// ```dart
/// final apiSource = UserApiSources(
///   baseUrl: 'https://api.example.com',
///   client: http.Client(),
/// );
/// 
/// apiSource.setAuthToken(authToken);
/// final users = await apiSource.getAllUsers();
/// ```
class UserApiSources {
  final String baseUrl;
  final http.Client client;
  String? _authToken;

  UserApiSources({required this.baseUrl, http.Client? client})
      : client = client ?? http.Client();

  /// Sets authentication token for subsequent requests [web:304][web:307].
  void setAuthToken(String? token) {
    _authToken = token;
  }

  /// Fetches all users from API [web:299][web:301].
  Future<List<User>> getAllUsers() async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

      final response = await client.get(
        Uri.parse('$baseUrl/users'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> usersJson = responseData['data'] ?? responseData;

        return usersJson.map((json) => User.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Non authentifié - Token invalide ou manquant');
      } else {
        throw Exception('Failed to fetch users: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Fetches single user by ID [web:299][web:301].
  ///
  /// Returns null if user not found (404).
  Future<User?> getUserById(int id) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

      final response = await client.get(
        Uri.parse('$baseUrl/users/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        // Laravel wraps response in {data: {...}}
        final userData = responseData['data'];
        return User.fromJson(userData);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Updates user with full object via PUT [web:299][web:303].
  ///
  /// Throws specific exceptions for validation and permission errors.
  Future<User> updateUser(User user) async {
    try {
      final body = json.encode(user.toJson());

      final headers = {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

      final response = await client.put(
        Uri.parse('$baseUrl/users/${user.id}'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final userData = responseData['data'];
        return User.fromJson(userData);
      } else if (response.statusCode == 401) {
        throw Exception('Non authentifié - Token invalide ou manquant');
      } else if (response.statusCode == 403) {
        throw Exception('Accès refusé - Vous n\'avez pas les droits');
      } else if (response.statusCode == 422) {
        final errorData = json.decode(response.body);
        throw Exception(
          'Erreur de validation : ${errorData['errors'] ?? response.body}',
        );
      } else {
        throw Exception('Failed to update user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Partially updates user with specific fields [web:299][web:303].
  ///
  /// Accepts Map of fields to update instead of full User object.
  /// Returns updated user data as Map.
  Future<Map<String, dynamic>> updateUserFields(
    int id,
    Map<String, dynamic> fields,
  ) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

      final url = '$baseUrl/users/$id';

      final response = await client.put(
        Uri.parse(url),
        headers: headers,
        body: json.encode(fields),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        return responseData['data'] ?? {};
      } else if (response.statusCode == 401) {
        throw Exception('Non authentifié - Token invalide ou manquant');
      } else if (response.statusCode == 403) {
        throw Exception('Accès refusé - Vous n\'avez pas les droits');
      } else if (response.statusCode == 422) {
        final errorData = json.decode(response.body);
        throw Exception(
          'Erreur de validation : ${errorData['errors'] ?? response.body}',
        );
      } else {
        throw Exception('Failed to update user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
