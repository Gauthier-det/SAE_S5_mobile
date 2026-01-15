import 'dart:convert';
import '../../../../core/services/api_client.dart';
import '../../domain/user.dart';

class UserApiSources {
  final ApiClient apiClient;

  UserApiSources({ApiClient? apiClient})
      : apiClient = apiClient ?? ApiClient();

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

  /// GET /api/users (requires auth)
  Future<List<User>> getAllUsers() async {
    try {
      final response = await apiClient.get('/api/users', requiresAuth: true);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch users: $e');
    }
  }

  /// GET /api/users/{id} (requires auth)
  Future<User?> getUserById(int id) async {
    try {
      final response = await apiClient.get('/api/users/$id', requiresAuth: true);
      final data = json.decode(response.body);
      return User.fromJson(data);
    } catch (e) {
      if (e.toString().contains('Not found')) {
        return null;
      }
      throw Exception('Failed to fetch user: $e');
    }
  }

  /// GET /api/clubs/{clubId}/users
  Future<List<User>> getUsersByClub(int clubId) async {
    try {
      final response = await apiClient.get('/api/clubs/$clubId/users');
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch users by club: $e');
    }
  }

  /// PUT /api/users/{id} (requires auth)
  Future<User> updateUser(int id, Map<String, dynamic> userData) async {
    try {
      final response = await apiClient.put(
        '/api/users/$id',
        body: userData,
        requiresAuth: true,
      );
      final data = json.decode(response.body);
      return User.fromJson(data);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  /// DELETE /api/users/{id} (requires auth)
  Future<void> deleteUser(int id) async {
    try {
      await apiClient.delete('/api/users/$id', requiresAuth: true);
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }
}
