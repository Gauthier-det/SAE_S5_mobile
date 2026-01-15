import 'dart:convert';
import 'package:sae5_g13_mobile/features/auth/domain/user_auth.dart';

import '../../../../core/services/api_client.dart';
import '../../domain/raid.dart';

class RaidApiSources {
  final ApiClient apiClient;

  RaidApiSources({ApiClient? apiClient})
      : apiClient = apiClient ?? ApiClient();

  /// GET /api/raids
  Future<List<Raid>> getAllRaids() async {
    try {
      final response = await apiClient.get('/api/raids');
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Raid.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch raids: $e');
    }
  }

  /// GET /api/raids/{id}
  Future<Raid?> getRaidById(int id) async {
    try {
      final response = await apiClient.get('/api/raids/$id');
      final data = json.decode(response.body);
      return Raid.fromJson(data);
    } catch (e) {
      if (e.toString().contains('Not found')) {
        return null;
      }
      throw Exception('Failed to fetch raid: $e');
    }
  }

  /// POST /api/raids (requires auth)
  Future<Raid> createRaid(Raid raid) async {
    try {
      final response = await apiClient.post(
        '/api/raids',
        body: raid.toJson(),
        requiresAuth: true,
      );
      final data = json.decode(response.body);
      return Raid.fromJson(data);
    } catch (e) {
      throw Exception('Failed to create raid: $e');
    }
  }

  /// PUT /api/raids/{id} (requires auth)
  Future<Raid> updateRaid(int id, Raid raid) async {
    try {
      final response = await apiClient.put(
        '/api/raids/$id',
        body: raid.toJson(),
        requiresAuth: true,
      );
      final data = json.decode(response.body);
      return Raid.fromJson(data);
    } catch (e) {
      throw Exception('Failed to update raid: $e');
    }
  }

  /// DELETE /api/raids/{id} (requires auth)
  Future<void> deleteRaid(int id) async {
    try {
      await apiClient.delete('/api/raids/$id', requiresAuth: true);
    } catch (e) {
      throw Exception('Failed to delete raid: $e');
    }
  }

  Future<List<User>> getUsersByRole(int roleId) async {
    try {
      // Récupérer TOUS les utilisateurs
      final response = await apiClient.get('/api/users', requiresAuth: true);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final allUsers = data.map((json) => User.fromJson(json)).toList();
        
        // Filtrer côté client (moins performant)
        return allUsers.where((user) {
          return user.roles?.any((role) => role.id == roleId) ?? false;
        }).toList();
      } else {
        throw Exception('Failed to fetch users: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch users by role: $e');
    }
  }

}
