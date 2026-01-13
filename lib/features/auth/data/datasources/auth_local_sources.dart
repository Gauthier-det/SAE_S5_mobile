import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/user_auth.dart';

/// Local data source for authentication using SharedPreferences
class AuthLocalSources {
  static const String _userKey = 'auth_user';
  static const String _authTokenKey = 'auth_token';
  static const String _usersKey = 'registered_users';

  final SharedPreferences _prefs;

  AuthLocalSources(this._prefs);

  /// Save user locally
  Future<void> saveUser(User user) async {
    final userJson = jsonEncode(user.toJson());
    await _prefs.setString(_userKey, userJson);
  }

  /// Get saved user
  User? getUser() {
    final userJson = _prefs.getString(_userKey);
    if (userJson == null) return null;

    try {
      final decoded = jsonDecode(userJson) as Map<String, dynamic>;
      return User.fromJson(decoded);
    } catch (e) {
      return null;
    }
  }

  /// Save authentication token
  Future<void> saveToken(String token) async {
    await _prefs.setString(_authTokenKey, token);
  }

  /// Get authentication token
  String? getToken() {
    return _prefs.getString(_authTokenKey);
  }

  /// Save registered users (for demo purposes)
  Future<void> saveRegisteredUsers(List<Map<String, dynamic>> users) async {
    final usersJson = jsonEncode(users);
    await _prefs.setString(_usersKey, usersJson);
  }

  /// Get registered users
  List<Map<String, dynamic>> getRegisteredUsers() {
    final usersJson = _prefs.getString(_usersKey);
    if (usersJson == null) return [];

    try {
      final decoded = jsonDecode(usersJson);
      return List<Map<String, dynamic>>.from(decoded);
    } catch (e) {
      return [];
    }
  }

  /// Clear user data (logout)
  Future<void> clearUser() async {
    await _prefs.remove(_userKey);
    await _prefs.remove(_authTokenKey);
  }

  /// Check if user is logged in
  bool isUserLogged() {
    return getUser() != null && getToken() != null;
  }
}
