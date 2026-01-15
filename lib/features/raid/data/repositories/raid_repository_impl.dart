import 'dart:convert';
import '../../../../core/services/api_client.dart';
import '../../domain/raid.dart';
import '../../../user/domain/user.dart';

class RaidApiSources {
  final ApiClient apiClient;

  RaidApiSources({ApiClient? apiClient})
      : apiClient = apiClient ?? ApiClient();

  /// GET /api/raids
  /// Récupère tous les raids avec leurs adresses et managers (comme le JOIN SQL local)
  Future<List<Raid>> getAllRaids() async {
    try {
      final response = await apiClient.get('/api/raids');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Raid.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch raids: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch raids: $e');
    }
  }

  /// GET /api/raids/{id}
  /// Récupère un raid par ID avec son adresse et son manager (comme le JOIN SQL local)
  Future<Raid?> getRaidById(int id) async {
    try {
      final response = await apiClient.get('/api/raids/$id');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Raid.fromJson(data);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to fetch raid: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('Not found')) {
        return null;
      }
      throw Exception('Failed to fetch raid: $e');
    }
  }

  /// POST /api/raids (requires auth)
  /// Crée un nouveau raid
  Future<Raid> createRaid(Raid raid) async {
    try {
      final response = await apiClient.post(
        '/api/raids',
        body: raid.toJson(),
        requiresAuth: true,
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        return Raid.fromJson(data);
      } else if (response.statusCode == 400) {
        throw Exception('Invalid data: ${response.body}');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Authentication required');
      } else {
        throw Exception('Failed to create raid: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to create raid: $e');
    }
  }

  /// PUT /api/raids/{id} (requires auth)
  /// Met à jour un raid existant
  Future<Raid> updateRaid(int id, Raid raid) async {
    try {
      final response = await apiClient.put(
        '/api/raids/$id',
        body: raid.toJson(),
        requiresAuth: true,
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Raid.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Raid not found');
      } else {
        throw Exception('Failed to update raid: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update raid: $e');
    }
  }

  /// DELETE /api/raids/{id} (requires auth)
  /// Supprime un raid
  Future<void> deleteRaid(int id) async {
    try {
      final response = await apiClient.delete(
        '/api/raids/$id',
        requiresAuth: true,
      );
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete raid: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete raid: $e');
    }
  }

  /// Fonction supplémentaire : Récupère les utilisateurs par rôle
  /// (Pour sélectionner les managers de raid)
  /// Note : Cette fonction nécessite un endpoint côté Laravel
  /// Par exemple : GET /api/roles/{roleId}/users
  Future<List<User>> getUsersByRole(int roleId) async {
    try {
      // Option 1 : Si vous avez un endpoint dédié
      final response = await apiClient.get('/api/roles/$roleId/users');
      
      // Option 2 : Sinon, récupérer tous les users et filtrer côté client
      // final response = await apiClient.get('/api/users', requiresAuth: true);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch users by role: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch users by role: $e');
    }
  }

  /// Fonction batch : Insère plusieurs raids (pour la synchronisation)
  /// Note : Cette fonction n'utilise pas d'endpoint API spécifique
  /// Elle est plutôt utilisée par le repository pour sync les données locales
  /// après avoir récupéré les raids de l'API via getAllRaids()
  Future<void> insertRaids(List<Raid> raids) async {
    // Cette fonction est gérée au niveau du repository
    // Elle n'appelle pas l'API, mais met à jour la base locale
    throw UnimplementedError(
      'insertRaids is handled by the repository layer, not the API layer'
    );
  }

  /// Fonction batch : Supprime tous les raids (pour le cache)
  /// Note : Cette fonction n'utilise pas d'endpoint API
  /// Elle est gérée au niveau local uniquement
  Future<void> clearAllRaids() async {
    // Cette fonction est gérée au niveau du repository
    // Elle n'appelle pas l'API, mais nettoie la base locale
    throw UnimplementedError(
      'clearAllRaids is handled by the repository layer, not the API layer'
    );
  }
}
