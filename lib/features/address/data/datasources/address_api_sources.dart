import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../domain/address.dart';

class AddressApiSources {
  final String baseUrl;
  final http.Client client;
  String? _authToken;

  AddressApiSources({required this.baseUrl, http.Client? client})
    : client = client ?? http.Client();

  void setAuthToken(String? token) {
    _authToken = token;
  }

  Future<List<Address>> getAllAddresses() async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

      final response = await client.get(
        Uri.parse('$baseUrl/addresses'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> addressesJson =
            responseData['data'] ?? responseData;
        return addressesJson.map((json) => Address.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch addresses: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Address?> getAddressById(int id) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

      final response = await client.get(
        Uri.parse('$baseUrl/addresses/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final addressData = responseData['data'] ?? responseData;
        return Address.fromJson(addressData);
      } else if (response.statusCode == 404) {
        return null; // Not found
      } else {
        throw Exception('Failed to fetch address: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<int> createAddress(Address address) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

      final body = json.encode(address.toJson());

      final response = await client.post(
        Uri.parse('$baseUrl/addresses'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = json.decode(response.body);
        // Assuming the backend returns the created address object or ID
        final data = responseData['data'] ?? responseData;
        return data['ADD_ID'] ?? data['id'];
      } else {
        throw Exception('Failed to create address: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
