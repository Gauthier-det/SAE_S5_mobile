import 'dart:convert';
import '../../../../core/services/api_client.dart';
import '../../domain/club.dart';

class ClubApiSources {
  final ApiClient apiClient;

  ClubApiSources({ApiClient? apiClient})
      : apiClient = apiClient ?? ApiClient();

  /// GET /api/clubs
  Future<List<Club>> getAllClubs() async {
    try {
      final response = await apiClient.get('/api/clubs');
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Club.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch clubs: $e');
    }
  }

  /// GET /api/clubs/{id}
  Future<Club?> getClubById(int id) async {
    try {
      final response = await apiClient.get('/api/clubs/$id');
      final data = json.decode(response.body);
      return Club.fromJson(data);
    } catch (e) {
      if (e.toString().contains('Not found')) {
        return null;
      }
      throw Exception('Failed to fetch club: $e');
    }
  }

  /// POST /api/clubs (requires auth + admin)
  Future<Club> createClub(Club club) async {
    try {
      final response = await apiClient.post(
        '/api/clubs',
        body: club.toJson(),
        requiresAuth: true,
      );
      final data = json.decode(response.body);
      return Club.fromJson(data);
    } catch (e) {
      throw Exception('Failed to create club: $e');
    }
  }

  /// POST /api/clubs/with-address (requires auth + admin)
  Future<Club> createClubWithAddress(Map<String, dynamic> clubWithAddress) async {
    try {
      final response = await apiClient.post(
        '/api/clubs/with-address',
        body: clubWithAddress,
        requiresAuth: true,
      );
      final data = json.decode(response.body);
      return Club.fromJson(data);
    } catch (e) {
      throw Exception('Failed to create club with address: $e');
    }
  }

  /// PUT /api/clubs/{id} (requires auth + admin)
  Future<Club> updateClub(int id, Club club) async {
    try {
      final response = await apiClient.put(
        '/api/clubs/$id',
        body: club.toJson(),
        requiresAuth: true,
      );
      final data = json.decode(response.body);
      return Club.fromJson(data);
    } catch (e) {
      throw Exception('Failed to update club: $e');
    }
  }

  /// DELETE /api/clubs/{id} (requires auth + admin)
  Future<void> deleteClub(int id) async {
    try {
      await apiClient.delete('/api/clubs/$id', requiresAuth: true);
    } catch (e) {
      throw Exception('Failed to delete club: $e');
    }
  }
}
