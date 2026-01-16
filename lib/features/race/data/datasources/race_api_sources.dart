import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../domain/race.dart';

class RaceApiSources {
  final String baseUrl;
  final http.Client client;
  String? _authToken;

  RaceApiSources({required this.baseUrl, http.Client? client})
    : client = client ?? http.Client();

  /// Définir le token d'authentification
  void setAuthToken(String? token) {
    _authToken = token;
  }

  /// Récupérer toutes les courses
  Future<List<Race>> getAllRaces() async {
    try {
      final response = await client
          .get(
            Uri.parse('$baseUrl/races'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> racesList = responseData['data'];
        return racesList.map((json) => Race.fromJson(json)).toList();
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Récupérer une course par ID
  Future<Race?> getRaceById(int id) async {
    try {
      final response = await client
          .get(
            Uri.parse('$baseUrl/races/$id'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final raceData = responseData['data'];
        return Race.fromJson(raceData);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Récupérer les courses d'un raid
  Future<List<Race>> getRacesByRaid(int raidId) async {
    try {
      final response = await client
          .get(
            Uri.parse('$baseUrl/raids/$raidId/races'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> racesList = responseData['data'];
        return racesList.map((json) => Race.fromJson(json)).toList();
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Créer une course avec prix
  Future<Race> createRace(Race race, Map<int, int> prices) async {
    try {
      // Convertir en JSON et adapter les champs pour l'API
      final raceJson = race.toJson();

      // Mapper RAC_GENDER vers RAC_GENDER pour l'API
      // L'API accepte uniquement : 'Homme', 'Femme', 'Mixte'
      final sexValue = raceJson.remove('RAC_GENDER') as String?;
      raceJson['RAC_GENDER'] = sexValue ?? 'Mixte';

      // Mapper RAC_MAX_TEAM_MEMBERS vers RAC_MAX_TEAM_MEMBERS pour l'API
      raceJson['RAC_MAX_TEAM_MEMBERS'] = raceJson.remove(
        'RAC_MAX_TEAM_MEMBERS',
      );

      // Ajouter RAC_CHIP_MANDATORY (obligatoire pour l'API)
      // Par défaut 1 si compétitif, 0 sinon
      raceJson['RAC_CHIP_MANDATORY'] = race.type == 'Compétitif' ? 1 : 0;

      // Ajouter les prix par catégorie
      prices.forEach((catId, price) {
        raceJson['CAT_${catId}_PRICE'] = price;
      });

      final body = json.encode(raceJson);

      final headers = {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

      print('🏁 CreateRaceWithPrices - Token présent: ${_authToken != null}');
      print('🏁 CreateRaceWithPrices - Body: $body');

      final response = await client
          .post(
            Uri.parse('$baseUrl/races/with-prices'),
            headers: headers,
            body: body,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final raceData = responseData['data'];
        return Race.fromJson(raceData);
      } else if (response.statusCode == 302) {
        throw Exception(
          'Non authentifié - Vous devez être connecté via l\'API',
        );
      } else if (response.statusCode == 403) {
        throw Exception(
          'Accès refusé - Seul le gestionnaire du raid peut créer des courses',
        );
      } else if (response.statusCode == 422) {
        final errorData = json.decode(response.body);
        throw Exception(
          'Erreur de validation : ${errorData['errors'] ?? response.body}',
        );
      } else {
        throw Exception('Erreur serveur : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Récupérer les détails d'une course (inclus les stats)
  Future<Map<String, dynamic>> getRaceDetails(int id) async {
    try {
      final response = await client
          .get(
            Uri.parse('$baseUrl/races/$id/details'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['data'] as Map<String, dynamic>;
      } else {
        throw Exception('API Error details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
