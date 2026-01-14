// lib/features/auth/data/datasources/auth_api_sources.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthApiSources {
  final String baseUrl;
  final http.Client client;

  AuthApiSources({required this.baseUrl, http.Client? client})
      : client = client ?? http.Client();

  /// Login user via POST /login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Identifiants invalides');
      } else {
        throw Exception('Erreur de connexion: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  /// Register user via POST /register
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? birthDate,
    String? phoneNumber,
    String? licenceNumber,
  }) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'password_confirmation': password,
          'first_name': firstName,
          'last_name': lastName,
          if (birthDate != null) 'birth_date': birthDate,
          if (phoneNumber != null) 'phone_number': phoneNumber,
          if (licenceNumber != null) 'licence_number': licenceNumber,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 422) {
        final errors = json.decode(response.body);
        throw Exception('Validation: ${errors['message'] ?? errors}');
      } else {
        throw Exception('Erreur d\'inscription: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  /// Logout user via POST /logout
  Future<void> logout(String token) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Erreur de déconnexion: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  /// Get current user via GET /user
  Future<Map<String, dynamic>> getCurrentUser(String token) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/user'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Non authentifié');
      } else {
        throw Exception('Erreur: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }
}