import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String? _token;
  Map<String, dynamic>? _currentUser;

  // Clés de stockage
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'current_user';

  /// Récupère le token stocké
  Future<String?> getToken() async {
    _token ??= await _storage.read(key: _tokenKey);
    return _token;
  }

  /// Sauvegarde le token
  Future<void> setToken(String token) async {
    _token = token;
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Supprime le token (logout)
  Future<void> clearToken() async {
    _token = null;
    _currentUser = null;
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }

  /// Récupère l'utilisateur courant
  Future<Map<String, dynamic>?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;
    
    final userJson = await _storage.read(key: _userKey);
    if (userJson != null) {
      _currentUser = json.decode(userJson);
    }
    return _currentUser;
  }

  /// Sauvegarde l'utilisateur courant
  Future<void> setCurrentUser(Map<String, dynamic> user) async {
    _currentUser = user;
    await _storage.write(key: _userKey, value: json.encode(user));
  }

  /// Vérifie si l'utilisateur est authentifié
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Vérifie si l'utilisateur est admin
  Future<bool> isAdmin() async {
    final user = await getCurrentUser();
    return user?['is_admin'] == true || user?['role']?['name'] == 'admin';
  }

  /// Retourne les headers HTTP avec le token d'authentification
  Future<Map<String, String>> getAuthHeaders() async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final token = await getToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }
}
