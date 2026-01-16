// lib/features/auth/data/datasources/auth_api_sources.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/user_auth.dart';

class AuthApiSources {
  final String baseUrl;
  final http.Client client;
  String? _accessToken; // Stocker le token d'accès

  AuthApiSources({required this.baseUrl, http.Client? client})
    : client = client ?? http.Client();

  /// Getter pour accéder au token
  String? get accessToken => _accessToken;

  /// Inscription via API
  Future<User> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? birthDate,
    String? phoneNumber,
    String? licenceNumber,
    String gender = 'Autre',
  }) async {

    final response = await client
        .post(
          Uri.parse('$baseUrl/register'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'mail': email,
            'password': password,
            'name': firstName,
            'last_name': lastName,
            'gender': gender,
            'birthdate': birthDate,
            'phone_number': phoneNumber,
            'licence_number': licenceNumber,
          }),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 201 || response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final data = responseData['data'];

      // Stocker le token pour les futures requêtes
      _accessToken = data['access_token'];

      return User.fromJson({
        'id': data['user_id'].toString(),
        'email': data['user_mail'] ?? '',
        'firstName': data['user_name'] ?? '',
        'lastName': data['user_last_name'] ?? '',
        'birthDate': data['user_birthdate'],
        'phoneNumber': data['user_phone']?.toString(),
        'licenceNumber': data['user_licence']?.toString(),
        'club': data['user_club']?['CLU_NAME'],
        'ppsNumber': null,
        'chipNumber': null,
        'profileImageUrl': null,
        'createdAt': DateTime.now().toIso8601String(),
        'roles': [],
      });
    } else if (response.statusCode == 422) {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Email déjà utilisé');
    } else {
      throw Exception('Erreur de connexion: ${response.statusCode}');
    }
  }

  /// Connexion via API
  Future<User> login({required String email, required String password}) async {

    final response = await client
        .post(
          Uri.parse('$baseUrl/login'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'mail': email, 'password': password}),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 201 || response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final data = responseData['data'];

      // Stocker le token pour les futures requêtes
      _accessToken = data['access_token'];

      // Extract roles from response
      List<int> roles = [];
      if (data['roles'] != null) {
        roles = (data['roles'] as List<dynamic>).map((r) => r as int).toList();
      } else if (data['user_roles'] != null) {
        roles = (data['user_roles'] as List<dynamic>)
            .map((r) => r as int)
            .toList();
      }

      final userMap = {
        'id': data['user_id'].toString(),
        'email': data['user_mail'] ?? '',
        'firstName': data['user_name'] ?? '',
        'lastName': data['user_last_name'] ?? '',
        'birthDate': data['user_birthdate'],
        'phoneNumber': data['user_phone']?.toString(),
        'licenceNumber': data['user_licence']?.toString(),
        'club': data['user_club']?['CLU_NAME'],
        'ppsNumber': null,
        'chipNumber': null,
        'profileImageUrl': null,
        'createdAt': DateTime.now().toIso8601String(),
        'roles': roles,
      };

      try {
        final user = User.fromJson(userMap);

        // Check if user is admin via separate API call
        final isAdmin = await _checkIsAdmin();
        if (isAdmin) {
          // Return user with site manager role
          return User.fromJson({
            ...userMap,
            'roles': [2],
          });
        }

        return user;
      } catch (e) {

        rethrow;
      }
    } else if (response.statusCode == 401) {
      throw Exception('Email ou mot de passe incorrect');
    } else {
      throw Exception('Erreur de connexion: ${response.statusCode}');
    }
  }

  /// Check if current user is admin
  Future<bool> _checkIsAdmin() async {
    if (_accessToken == null) return false;

    final response = await client
        .get(
          Uri.parse('$baseUrl/user/is-admin'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_accessToken',
          },
        )
        .timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Try different response formats
      return data['is_admin'] == true ||
          data['isAdmin'] == true ||
          data['data'] == true ||
          data == true;
    }
    return false;
  }

  /// Mise à jour du profil via API
  Future<User> updateProfile({
    required String userId,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? birthDate,
    String? licenceNumber,
  }) async {
    final response = await client
        .put(
          Uri.parse('$baseUrl/users/$userId'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            if (firstName != null) 'prenom': firstName,
            if (lastName != null) 'nom': lastName,
            if (phoneNumber != null) 'tel': phoneNumber,
            if (birthDate != null) 'date_naissance': birthDate,
            if (licenceNumber != null) 'numero_licence': licenceNumber,
          }),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return User.fromJson({
        'id': data['id'].toString(),
        'email': data['mail'],
        'firstName': data['prenom'],
        'lastName': data['nom'],
        'birthDate': data['date_naissance'],
        'phoneNumber': data['tel'],
        'licenceNumber': data['numero_licence'],
        'createdAt': DateTime.now().toIso8601String(),
      });
    } else {
      throw Exception('Erreur de mise à jour: ${response.statusCode}');
    }
  }
}
