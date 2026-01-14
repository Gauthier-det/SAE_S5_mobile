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
      print('🔐 Attempting API login to: $baseUrl/login');
      print('🔐 Request body: {mail: $email, password: ***}');
      
      final response = await client.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'mail': email, 'password': password}),
      );

      print('🔐 Login response status: ${response.statusCode}');
      print('🔐 Login response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Identifiants invalides');
      } else {
        throw Exception('Erreur de connexion: ${response.statusCode}');
      }
    } catch (e) {
      print('🔐 Login API error: $e');
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
      final requestBody = {
        'mail': email, // Laravel attend 'mail' pas 'email'
        'password': password,
        'name': firstName, // Laravel attend 'name' pas 'first_name'
        'last_name': lastName,
      };
      
      print('📤 Register request to: $baseUrl/register');
      print('📤 Request body: $requestBody');
      
      final response = await client.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      );

      print('📥 Register response status: ${response.statusCode}');
      print('📥 Register response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 422) {
        final errors = json.decode(response.body);
        throw Exception('Validation: ${errors['message'] ?? errors}');
      } else {
        throw Exception('Erreur d\'inscription: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Register error: $e');
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

  /// Update user profile via PUT /users/{id}
  Future<Map<String, dynamic>> updateProfile({
    required int userId,
    required String token,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? birthDate,
    int? clubId,
    String? licenceNumber,
    String? ppsNumber,
    String? chipNumber,
    String? profileImageUrl,
    String? streetNumber,
    String? streetName,
    String? postalCode,
    String? city,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      
      if (firstName != null) data['USE_NAME'] = firstName;
      if (lastName != null) data['USE_LAST_NAME'] = lastName;
      if (phoneNumber != null) data['USE_PHONE_NUMBER'] = phoneNumber;
      if (birthDate != null) data['USE_BIRTH_DATE'] = birthDate;
      if (clubId != null) data['CLU_ID'] = clubId;
      if (licenceNumber != null) data['USE_LICENCE_NUMBER'] = licenceNumber;
      if (ppsNumber != null) data['USE_PPS_NUMBER'] = ppsNumber;
      if (chipNumber != null) data['USE_CHIP_NUMBER'] = chipNumber;
      if (profileImageUrl != null) data['USE_PROFILE_IMAGE_URL'] = profileImageUrl;
      if (streetNumber != null) data['ADD_STREET_NUMBER'] = streetNumber;
      if (streetName != null) data['ADD_STREET_NAME'] = streetName;
      if (postalCode != null) data['ADD_POSTAL_CODE'] = postalCode;
      if (city != null) data['ADD_CITY'] = city;

      print('🔍 Updating profile for user $userId with data: ${json.encode(data)}');

      final response = await client.put(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(data),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['data'] ?? responseData;
      } else if (response.statusCode == 422) {
        final errors = json.decode(response.body);
        print('❌ Validation errors: ${errors}');
        throw Exception('Validation: ${json.encode(errors['errors'] ?? errors['message'] ?? errors)}');
      } else if (response.statusCode == 401) {
        throw Exception('Non authentifié');
      } else {
        throw Exception('Erreur mise à jour profil: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error updating profile: $e');
      throw Exception('Erreur réseau: $e');
    }
  }
}
