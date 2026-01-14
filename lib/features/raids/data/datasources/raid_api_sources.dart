// lib/features/raids/data/datasources/RaidApiSources.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../domain/raid.dart';

class RaidApiSources {
  final String baseUrl;
  final http.Client client;

  RaidApiSources({
    required this.baseUrl,
    http.Client? client,
  }) : client = client ?? http.Client();

  Future<Raid?> getRaidById(int id) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/raids/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return Raid.fromJson(responseData['data'] ?? responseData);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  Future<List<Raid>> getAllRaids() async {
    try {
      print('🔍 Fetching raids from: $baseUrl/raids');
      final response = await client.get(
        Uri.parse('$baseUrl/raids'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> data = responseData['data'] ?? [];
        print('✅ Parsed ${data.length} raids');
        return data.map((json) => Raid.fromJson(json)).toList();
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('❌ Error fetching raids: $e');
      print('📚 Stack trace: $stackTrace');
      throw Exception('Erreur réseau: $e');
    }
  }

  /// POST /raids - Créer un nouveau raid
  Future<Raid> createRaid(Raid raid, {String? token}) async {
    try {
      // Préparer les données sans RAI_ID (auto-généré)
      final Map<String, dynamic> data = {
        'CLU_ID': raid.clubId,
        'ADD_ID': raid.addressId,
        'USE_ID': raid.userId,
        'RAI_NAME': raid.name,
        'RAI_MAIL': raid.email,
        'RAI_PHONE_NUMBER': raid.phoneNumber,
        'RAI_WEB_SITE': raid.website,
        'RAI_IMAGE': raid.image,
        'RAI_TIME_START': raid.timeStart.toIso8601String(),
        'RAI_TIME_END': raid.timeEnd.toIso8601String(),
        'RAI_REGISTRATION_START': raid.registrationStart.toIso8601String(),
        'RAI_REGISTRATION_END': raid.registrationEnd.toIso8601String(),
      };

      print('🔍 Creating raid with data: ${json.encode(data)}');

      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await client.post(
        Uri.parse('$baseUrl/raids'),
        headers: headers,
        body: json.encode(data),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return Raid.fromJson(responseData['data'] ?? responseData);
      } else if (response.statusCode == 422) {
        final errors = json.decode(response.body);
        print('❌ Validation errors: ${errors}');
        throw Exception('Validation: ${json.encode(errors['errors'] ?? errors['message'] ?? errors)}');
      } else if (response.statusCode == 401) {
        throw Exception('Non authentifié');
      } else if (response.statusCode == 403) {
        throw Exception('Non autorisé');
      } else {
        throw Exception('Erreur création: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error creating raid: $e');
      throw Exception('Erreur réseau: $e');
    }
  }

  /// PUT /raids/{id} - Mettre à jour un raid
  Future<Raid> updateRaid(int id, Raid raid, {String? token}) async {
    try {
      // Préparer les données sans RAI_ID
      final Map<String, dynamic> data = {
        'CLU_ID': raid.clubId,
        'ADD_ID': raid.addressId,
        'USE_ID': raid.userId,
        'RAI_NAME': raid.name,
        'RAI_MAIL': raid.email,
        'RAI_PHONE_NUMBER': raid.phoneNumber,
        'RAI_WEB_SITE': raid.website,
        'RAI_IMAGE': raid.image,
        'RAI_TIME_START': raid.timeStart.toIso8601String(),
        'RAI_TIME_END': raid.timeEnd.toIso8601String(),
        'RAI_REGISTRATION_START': raid.registrationStart.toIso8601String(),
        'RAI_REGISTRATION_END': raid.registrationEnd.toIso8601String(),
      };

      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await client.put(
        Uri.parse('$baseUrl/raids/$id'),
        headers: headers,
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return Raid.fromJson(responseData['data'] ?? responseData);
      } else {
        throw Exception('Erreur mise à jour: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  /// Deletes a raid via DELETE request
  Future<void> deleteRaid(int id, {String? token}) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await client.delete(
        Uri.parse('$baseUrl/raids/$id'),
        headers: headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete raid: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}