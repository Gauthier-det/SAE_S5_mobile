// lib/features/address/data/datasources/address_api_sources.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../domain/address.dart';

class AddressApiSources {
  final String baseUrl;
  final http.Client client;

  AddressApiSources({required this.baseUrl, http.Client? client})
    : client = client ?? http.Client();

  /// GET /addresses - Récupérer toutes les adresses
  Future<List<Address>> getAllAddresses() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/addresses'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Address.fromJson(json)).toList();
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  /// GET /addresses/{id} - Récupérer une adresse par ID
  Future<Address?> getAddressById(int id) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/addresses/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return Address.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  /// POST /addresses - Créer une nouvelle adresse
  Future<Address> createAddress(Address address) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/addresses'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(address.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Address.fromJson(json.decode(response.body));
      } else if (response.statusCode == 422) {
        final errors = json.decode(response.body);
        throw Exception('Validation: ${errors['message'] ?? errors}');
      } else {
        throw Exception('Erreur création: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  /// PUT /addresses/{id} - Mettre à jour une adresse
  Future<Address> updateAddress(int id, Address address) async {
    try {
      final response = await client.put(
        Uri.parse('$baseUrl/addresses/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(address.toJson()),
      );

      if (response.statusCode == 200) {
        return Address.fromJson(json.decode(response.body));
      } else {
        throw Exception('Erreur mise à jour: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  /// DELETE /addresses/{id} - Supprimer une adresse
  Future<void> deleteAddress(int id) async {
    try {
      final response = await client.delete(
        Uri.parse('$baseUrl/addresses/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Erreur suppression: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }
}
