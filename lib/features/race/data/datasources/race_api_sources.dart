import 'dart:convert';
import '../../../../core/services/api_client.dart';
import '../../domain/race.dart';

class RaceApiSources {
  final ApiClient apiClient;

  RaceApiSources({ApiClient? apiClient})
      : apiClient = apiClient ?? ApiClient();

  /// GET /api/races
  Future<List<Race>> getAllRaces() async {
    try {
      final response = await apiClient.get('/api/races');
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Race.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch races: $e');
    }
  }

  /// GET /api/races/{id}
  Future<Race?> getRaceById(int id) async {
    try {
      final response = await apiClient.get('/api/races/$id');
      final data = json.decode(response.body);
      return Race.fromJson(data);
    } catch (e) {
      if (e.toString().contains('Not found')) {
        return null;
      }
      throw Exception('Failed to fetch race: $e');
    }
  }

  /// GET /api/races/{id}/details
  Future<Map<String, dynamic>> getRaceDetails(int id) async {
    try {
      final response = await apiClient.get('/api/races/$id/details');
      return json.decode(response.body);
    } catch (e) {
      throw Exception('Failed to fetch race details: $e');
    }
  }

  /// GET /api/races/{raceId}/results
  Future<List<dynamic>> getRaceResults(int raceId) async {
    try {
      final response = await apiClient.get('/api/races/$raceId/results');
      return json.decode(response.body);
    } catch (e) {
      throw Exception('Failed to fetch race results: $e');
    }
  }

  /// GET /api/races/{raceId}/prices
  Future<List<dynamic>> getRacePrices(int raceId) async {
    try {
      final response = await apiClient.get('/api/races/$raceId/prices');
      return json.decode(response.body);
    } catch (e) {
      throw Exception('Failed to fetch race prices: $e');
    }
  }

  /// GET /api/raids/{raidId}/races
  Future<List<Race>> getRacesByRaid(int raidId) async {
    try {
      final response = await apiClient.get('/api/raids/$raidId/races');
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Race.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch races by raid: $e');
    }
  }

  /// POST /api/races (requires auth)
  Future<Race> createRace(Race race) async {
    try {
      final response = await apiClient.post(
        '/api/races',
        body: race.toJson(),
        requiresAuth: true,
      );
      final data = json.decode(response.body);
      return Race.fromJson(data);
    } catch (e) {
      throw Exception('Failed to create race: $e');
    }
  }

  /// POST /api/races/with-prices (requires auth)
  Future<Race> createRaceWithPrices(Map<String, dynamic> raceWithPrices) async {
    try {
      final response = await apiClient.post(
        '/api/races/with-prices',
        body: raceWithPrices,
        requiresAuth: true,
      );
      final data = json.decode(response.body);
      return Race.fromJson(data);
    } catch (e) {
      throw Exception('Failed to create race with prices: $e');
    }
  }

  /// PUT /api/races/{id} (requires auth)
  Future<Race> updateRace(int id, Race race) async {
    try {
      final response = await apiClient.put(
        '/api/races/$id',
        body: race.toJson(),
        requiresAuth: true,
      );
      final data = json.decode(response.body);
      return Race.fromJson(data);
    } catch (e) {
      throw Exception('Failed to update race: $e');
    }
  }

  /// DELETE /api/races/{id} (requires auth)
  Future<void> deleteRace(int id) async {
    try {
      await apiClient.delete('/api/races/$id', requiresAuth: true);
    } catch (e) {
      throw Exception('Failed to delete race: $e');
    }
  }
}
