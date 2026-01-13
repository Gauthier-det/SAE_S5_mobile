// lib/features/auth/data/datasources/auth_local_sources.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/database/database_helper.dart';
import '../../domain/user_auth.dart';

class AuthLocalSources {
  static const String _userKey = 'auth_user';
  static const String _authTokenKey = 'auth_token';

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

  /// Get registered users FROM SQLITE (not SharedPreferences)
  Future<List<Map<String, dynamic>>> getRegisteredUsers() async {
    final db = await DatabaseHelper.database;
    
    final List<Map<String, dynamic>> users = await db.query('SAN_USERS');
    
    return users.map((user) => {
      'id': user['USE_ID'].toString(),
      'email': user['USE_MAIL'],
      'password': user['USE_PASSWORD'], // Plain text in dev
      'firstName': user['USE_NAME'],
      'lastName': user['USE_LAST_NAME'],
      'birthDate': user['USE_BIRTHDATE'],
      'phoneNumber': user['USE_PHONE_NUMBER']?.toString(),
      'licenceNumber': user['USE_LICENCE_NUMBER']?.toString(),
      'createdAt': DateTime.now().toIso8601String(),
    }).toList();
  }

  /// Save registered users (not needed with SQLite)
  Future<void> saveRegisteredUsers(List<Map<String, dynamic>> users) async {
    // SQLite handles this
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
