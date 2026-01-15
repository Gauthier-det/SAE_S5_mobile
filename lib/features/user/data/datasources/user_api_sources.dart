// lib/features/users/data/datasources/user_api_sources.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../domain/user.dart';

class UserApiSources {
  final String baseUrl;
  final http.Client client;
  String? _authToken;

  UserApiSources({required this.baseUrl, http.Client? client})
    : client = client ?? http.Client();

  /// Sets the authentication token
  void setAuthToken(String? token) {
    _authToken = token;
  }

  /// Gets user by ID from API
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

  /// Updates an existing user via PUT request
  Future<User> updateUser(User user) async {
    try {
      final body = json.encode(
        user.toJson(),
      ); // User.toJson matches DB/API format generally

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
        // Laravel wraps response in {data: {...}}
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

  /// Updates a user's profile with specific fields
  Future<Map<String, dynamic>> updateUserFields(
    int id,
    Map<String, dynamic> fields,
  ) async {
    print('🔄 UserApiSources.updateUserFields - Start');
    print('🔄 UserApiSources.updateUserFields - User ID: $id');
    print('🔄 UserApiSources.updateUserFields - Fields: $fields');
    print(
      '🔄 UserApiSources.updateUserFields - Token présent: ${_authToken != null}',
    );

    try {
      final headers = {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

      final url = '$baseUrl/users/$id';
      print('🔄 UserApiSources.updateUserFields - URL: $url');
      print('🔄 UserApiSources.updateUserFields - Headers: $headers');
      print(
        '🔄 UserApiSources.updateUserFields - Body: ${json.encode(fields)}',
      );

      final response = await client.put(
        Uri.parse(url),
        headers: headers,
        body: json.encode(fields),
      );

      print(
        '🔄 UserApiSources.updateUserFields - Response status: ${response.statusCode}',
      );
      print(
        '🔄 UserApiSources.updateUserFields - Response body: ${response.body}',
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('✅ UserApiSources.updateUserFields - Success');
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
      print('❌ UserApiSources.updateUserFields - Error: $e');
      throw Exception('Network error: $e');
    }
  }
}
