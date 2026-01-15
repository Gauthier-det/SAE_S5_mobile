import 'dart:convert';
import '../../../../core/services/api_client.dart';
import '../../domain/address.dart';

class AddressApiSources {
  final ApiClient apiClient;

  AddressApiSources({ApiClient? apiClient})
      : apiClient = apiClient ?? ApiClient();

  /// GET /api/addresses (requires auth + admin)
  Future<List<Address>> getAllAddresses() async {
    try {
      final response = await apiClient.get('/api/addresses', requiresAuth: true);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Address.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch addresses: $e');
    }
  }

  /// GET /api/addresses/{id} (requires auth)
  Future<Address?> getAddressById(int id) async {
    try {
      final response = await apiClient.get('/api/addresses/$id', requiresAuth: true);
      final data = json.decode(response.body);
      return Address.fromJson(data);
    } catch (e) {
      if (e.toString().contains('Not found')) {
        return null;
      }
      throw Exception('Failed to fetch address: $e');
    }
  }

  /// POST /api/addresses (requires auth)
  Future<Address> createAddress(Address address) async {
    try {
      final response = await apiClient.post(
        '/api/addresses',
        body: address.toJson(),
        requiresAuth: true,
      );
      final data = json.decode(response.body);
      return Address.fromJson(data);
    } catch (e) {
      throw Exception('Failed to create address: $e');
    }
  }

  /// PUT /api/addresses/{id} (requires auth)
  Future<Address> updateAddress(int id, Address address) async {
    try {
      final response = await apiClient.put(
        '/api/addresses/$id',
        body: address.toJson(),
        requiresAuth: true,
      );
      final data = json.decode(response.body);
      return Address.fromJson(data);
    } catch (e) {
      throw Exception('Failed to update address: $e');
    }
  }

  /// DELETE /api/addresses/{id} (requires auth + admin)
  Future<void> deleteAddress(int id) async {
    try {
      await apiClient.delete('/api/addresses/$id', requiresAuth: true);
    } catch (e) {
      throw Exception('Failed to delete address: $e');
    }
  }
}
