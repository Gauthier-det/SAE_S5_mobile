import 'dart:convert';
import 'package:sae5_g13_mobile/features/auth/domain/user_auth.dart';

import '../../../../core/services/api_client.dart';
import '../../../../core/services/auth_service.dart';

class AuthApiSources {
  final ApiClient apiClient;
  final AuthService authService = AuthService();

  AuthApiSources({ApiClient? apiClient})
      : apiClient = apiClient ?? ApiClient();

  /// POST /api/login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await apiClient.post(
        '/api/login',
        body: {
          'email': email,
          'password': password,
        },
      );

      final data = json.decode(response.body);
      
      // Sauvegarder le token
      if (data['token'] != null) {
        await authService.setToken(data['token']);
      }
      
      // Sauvegarder l'utilisateur
      if (data['user'] != null) {
        await authService.setCurrentUser(data['user']);
      }

      return data;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  /// POST /api/register
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? firstName,
    String? phone,
    int? clubId,
  }) async {
    try {
      final response = await apiClient.post(
        '/api/register',
        body: {
          'name': name,
          'email': email,
          'password': password,
          if (firstName != null) 'first_name': firstName,
          if (phone != null) 'phone': phone,
          if (clubId != null) 'club_id': clubId,
        },
      );

      final data = json.decode(response.body);

      // Sauvegarder le token
      if (data['token'] != null) {
        await authService.setToken(data['token']);
      }

      // Sauvegarder l'utilisateur
      if (data['user'] != null) {
        await authService.setCurrentUser(data['user']);
      }

      return data;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  /// POST /api/logout (requires auth)
  Future<void> logout() async {
    try {
      await apiClient.post('/api/logout', requiresAuth: true);
      await authService.clearToken();
    } catch (e) {
      // Même en cas d'erreur, on clear le token local
      await authService.clearToken();
      throw Exception('Logout failed: $e');
    }
  }

  /// GET /api/user (requires auth)
  Future<User> getUserInfo() async {
    try {
      final response = await apiClient.get('/api/user', requiresAuth: true);
      final data = json.decode(response.body);
      return User.fromJson(data);
    } catch (e) {
      throw Exception('Failed to get user info: $e');
    }
  }

  /// GET /api/user/is-admin (requires auth)
  Future<bool> checkIsAdmin() async {
    try {
      final response = await apiClient.get('/api/user/is-admin', requiresAuth: true);
      final data = json.decode(response.body);
      return data['is_admin'] == true;
    } catch (e) {
      throw Exception('Failed to check admin status: $e');
    }
  }
}
