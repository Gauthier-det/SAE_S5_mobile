import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/app_config.dart';
import 'auth_service.dart';
import 'connectivity_service.dart';

class ApiClient {
  final String baseUrl;
  final http.Client client;
  final AuthService _authService = AuthService();
  final ConnectivityService _connectivityService = ConnectivityService();

  ApiClient({
    String? baseUrl,
    http.Client? client,
  })  : baseUrl = baseUrl ?? AppConfig.apiBaseUrl,
        client = client ?? http.Client();

  /// GET request
  Future<http.Response> get(String endpoint, {bool requiresAuth = false}) async {
    if (!await _connectivityService.isConnected()) {
      throw Exception('No internet connection');
    }

    final headers = requiresAuth 
        ? await _authService.getAuthHeaders()
        : {'Content-Type': 'application/json', 'Accept': 'application/json'};

    final uri = Uri.parse('$baseUrl$endpoint');
    final response = await client.get(uri, headers: headers);

    _handleResponse(response);
    return response;
  }

  /// POST request
  Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) async {
    if (!await _connectivityService.isConnected()) {
      throw Exception('No internet connection');
    }

    final headers = requiresAuth 
        ? await _authService.getAuthHeaders()
        : {'Content-Type': 'application/json', 'Accept': 'application/json'};

    final uri = Uri.parse('$baseUrl$endpoint');
    final response = await client.post(
      uri,
      headers: headers,
      body: body != null ? json.encode(body) : null,
    );

    _handleResponse(response);
    return response;
  }

  /// PUT request
  Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) async {
    if (!await _connectivityService.isConnected()) {
      throw Exception('No internet connection');
    }

    final headers = requiresAuth 
        ? await _authService.getAuthHeaders()
        : {'Content-Type': 'application/json', 'Accept': 'application/json'};

    final uri = Uri.parse('$baseUrl$endpoint');
    final response = await client.put(
      uri,
      headers: headers,
      body: body != null ? json.encode(body) : null,
    );

    _handleResponse(response);
    return response;
  }

  /// DELETE request
  Future<http.Response> delete(
    String endpoint, {
    bool requiresAuth = false,
  }) async {
    if (!await _connectivityService.isConnected()) {
      throw Exception('No internet connection');
    }

    final headers = requiresAuth 
        ? await _authService.getAuthHeaders()
        : {'Content-Type': 'application/json', 'Accept': 'application/json'};

    final uri = Uri.parse('$baseUrl$endpoint');
    final response = await client.delete(uri, headers: headers);

    _handleResponse(response);
    return response;
  }

  /// Gestion centralisée des erreurs HTTP
  void _handleResponse(http.Response response) {
    if (response.statusCode == 401) {
      _authService.clearToken();
      throw Exception('Unauthorized - Token expired or invalid');
    } else if (response.statusCode == 403) {
      throw Exception('Forbidden - Insufficient permissions');
    } else if (response.statusCode == 404) {
      throw Exception('Not found');
    } else if (response.statusCode >= 500) {
      throw Exception('Server error: ${response.statusCode}');
    } else if (response.statusCode >= 400) {
      throw Exception('Client error: ${response.body}');
    }
  }
}
