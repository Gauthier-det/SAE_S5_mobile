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
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Raid.fromJson(data);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<List<Raid>> getAllRaids() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/raids'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Raid.fromJson(json)).toList();
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
