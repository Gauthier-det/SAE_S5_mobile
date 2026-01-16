// lib/features/auth/data/datasources/auth_local_sources.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/database/database_helper.dart';
import '../../domain/user_auth.dart';

/// Local authentication data source.
///
/// Manages persistent storage of authentication data using a dual-storage strategy:
/// - **SharedPreferences**: Stores current session data (active user, JWT token) [web:94][web:99]
/// - **SQLite**: Stores the complete registry of registered users [web:100][web:103]
///
/// This separation provides optimal performance for session management while maintaining
/// a robust local database for user accounts [web:99][web:102]. SharedPreferences is
/// ideal for small key-value data like authentication tokens, while SQLite handles
/// relational user data with roles and relationships [web:100][web:102].
///
/// **SharedPreferences Usage:**
/// - Lightweight key-value storage for current session state [web:99][web:101]
/// - Persists across app launches but not suitable for sensitive data [web:99]
/// - Fast read/write operations for authentication state checks [web:94]
///
/// **SQLite Usage:**
/// - Structured storage for user registry with relationships [web:100][web:103]
/// - Supports complex queries and joins (e.g., user roles) [web:103]
/// - Managed by [DatabaseHelper] singleton for database operations [web:100]
///
/// **Security Note:** Authentication tokens should ideally be stored in secure storage
/// (flutter_secure_storage) rather than SharedPreferences for production apps [web:99][web:102].
///
/// Example usage:
/// ```dart
/// final prefs = await SharedPreferences.getInstance();
/// final authLocal = AuthLocalSources(prefs);
///
/// // Save user session
/// await authLocal.saveUser(currentUser);
/// await authLocal.saveToken(jwtToken);
///
/// // Check authentication state
/// if (authLocal.isUserLogged()) {
///   final user = authLocal.getUser();
///   print('Welcome back, ${user?.firstName}!');
/// }
/// ```
class AuthLocalSources {
  /// SharedPreferences key for storing the current user's data.
  ///
  /// The user object is serialized to JSON before storage [web:94][web:101].
  static const String _userKey = 'auth_user';

  /// SharedPreferences key for storing the authentication token.
  ///
  /// Typically stores a JWT token received from the API [web:94][web:99].
  static const String _authTokenKey = 'auth_token';

  /// SharedPreferences instance for key-value storage.
  ///
  /// Injected via constructor to support testing and dependency injection [web:99][web:101].
  final SharedPreferences _prefs;

  /// Creates an [AuthLocalSources] instance.
  ///
  /// Requires a [SharedPreferences] instance which should be initialized
  /// at app startup using `await SharedPreferences.getInstance()` [web:99][web:101].
  AuthLocalSources(this._prefs);

  /// Saves the current authenticated user to local storage.
  ///
  /// Serializes the [User] object to JSON and stores it in SharedPreferences
  /// under the [_userKey] key [web:94][web:101]. This allows the app to
  /// maintain user session state across app restarts.
  ///
  /// **Parameters:**
  /// - [user]: The authenticated user to persist locally
  ///
  /// **Example:**
  /// ```dart
  /// final user = User(id: '1', email: 'user@example.com', ...);
  /// await authLocal.saveUser(user);
  /// ```
  Future<void> saveUser(User user) async {
    final userJson = jsonEncode(user.toJson());
    await _prefs.setString(_userKey, userJson);
  }

  /// Retrieves the currently authenticated user from local storage.
  ///
  /// Deserializes the user data from SharedPreferences and returns a [User]
  /// object, or null if no user is stored or deserialization fails [web:94][web:101].
  ///
  /// **Returns:**
  /// - A [User] object if one is stored and valid
  /// - `null` if no user is found or JSON parsing fails
  ///
  /// **Example:**
  /// ```dart
  /// final user = authLocal.getUser();
  /// if (user != null) {
  ///   print('Current user: ${user.email}');
  /// }
  /// ```
  User? getUser() {
    final userJson = _prefs.getString(_userKey);
    if (userJson == null) return null;

    try {
      final decoded = jsonDecode(userJson) as Map<String, dynamic>;
      return User.fromJson(decoded);
    } catch (e) {
      // Return null if JSON parsing fails (corrupted data)
      return null;
    }
  }

  /// Saves the authentication token to local storage.
  ///
  /// Stores a JWT or session token in SharedPreferences for use in
  /// authenticated API requests [web:94][web:99]. The token is stored
  /// as a plain string.
  ///
  /// **Security Warning:** For production apps, consider using
  /// `flutter_secure_storage` instead of SharedPreferences for token
  /// storage to provide encryption and secure enclave protection [web:99][web:102].
  ///
  /// **Parameters:**
  /// - [token]: The JWT or authentication token to store
  ///
  /// **Example:**
  /// ```dart
  /// await authLocal.saveToken('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...');
  /// ```
  Future<void> saveToken(String token) async {
    await _prefs.setString(_authTokenKey, token);
  }

  /// Retrieves the stored authentication token.
  ///
  /// Returns the JWT or session token from SharedPreferences, or null
  /// if no token is stored [web:94][web:99].
  ///
  /// **Returns:**
  /// - The stored authentication token as a String
  /// - `null` if no token is found
  ///
  /// **Example:**
  /// ```dart
  /// final token = authLocal.getToken();
  /// if (token != null) {
  ///   // Use token for authenticated API requests
  ///   headers['Authorization'] = 'Bearer $token';
  /// }
  /// ```
  String? getToken() {
    return _prefs.getString(_authTokenKey);
  }

  /// Retrieves all registered users from the SQLite database.
  ///
  /// Queries the `SAN_USERS` table and joins with `SAN_ROLES_USERS` to fetch
  /// complete user data including their assigned roles [web:100][web:103].
  /// This provides access to the local user registry, which is separate from
  /// the current session user stored in SharedPreferences.
  ///
  /// **Database Schema:**
  /// - `SAN_USERS`: Main user table with profile information
  /// - `SAN_ROLES_USERS`: Junction table mapping users to roles (many-to-many) [web:100]
  ///
  /// **Returns:** A list of user maps containing:
  /// - User profile data (id, email, name, etc.)
  /// - Plain text password (development only - should be hashed in production)
  /// - List of role IDs assigned to each user
  ///
  /// **Note:** Passwords are stored in plain text for development purposes.
  /// Production implementations should use proper password hashing (e.g., bcrypt).
  ///
  /// **Example:**
  /// ```dart
  /// final users = await authLocal.getRegisteredUsers();
  /// for (var user in users) {
  ///   print('User: ${user['email']}, Roles: ${user['roles']}');
  /// }
  /// ```
  Future<List<Map<String, dynamic>>> getRegisteredUsers() async {
    final db = await DatabaseHelper.database;

    // Query all users from the database [web:103]
    final List<Map<String, dynamic>> users = await db.query('SAN_USERS');

    // Load all user-role relationships for efficient lookup [web:100]
    final List<Map<String, dynamic>> rolesUsers = await db.query(
      'SAN_ROLES_USERS',
    );

    return users.map((user) {
      // Find all roles assigned to this user [web:100][web:103]
      final userRoles = rolesUsers
          .where((ru) => ru['USE_ID'] == user['USE_ID'])
          .map((ru) => ru['ROL_ID'] as int)
          .toList();

      return {
        'id': user['USE_ID'].toString(),
        'email': user['USE_MAIL'],
        'password': user['USE_PASSWORD'], // Plain text in development
        'firstName': user['USE_NAME'],
        'lastName': user['USE_LAST_NAME'],
        'birthDate': user['USE_BIRTHDATE'],
        'phoneNumber': user['USE_PHONE_NUMBER']?.toString(),
        'licenceNumber': user['USE_LICENCE_NUMBER']?.toString(),
        'createdAt': DateTime.now().toIso8601String(),
        'roles': userRoles,
      };
    }).toList();
  }

  /// Saves registered users to local storage (deprecated).
  ///
  /// This method is no longer needed because user registration is handled
  /// directly by SQLite through [DatabaseHelper] [web:100][web:103].
  /// The method is kept for backward compatibility but performs no operation.
  ///
  /// **Note:** User data should be inserted into SQLite using proper database
  /// operations rather than bulk storage via this method.
  Future<void> saveRegisteredUsers(List<Map<String, dynamic>> users) async {
    // SQLite handles user persistence directly
  }

  /// Clears all authentication data (logout).
  ///
  /// Removes both the user object and authentication token from SharedPreferences,
  /// effectively logging the user out [web:94][web:99]. This does not affect
  /// the user registry stored in SQLite.
  ///
  /// **Use case:** Called when user explicitly logs out or when session expires.
  ///
  /// **Example:**
  /// ```dart
  /// // User logged out
  /// await authLocal.clearUser();
  /// Navigator.pushReplacementNamed(context, '/login');
  /// ```
  Future<void> clearUser() async {
    await _prefs.remove(_userKey);
    await _prefs.remove(_authTokenKey);
  }

  /// Checks if a user is currently logged in.
  ///
  /// Returns true if both a user object and authentication token are present
  /// in SharedPreferences, indicating an active session [web:94][web:99].
  ///
  /// **Returns:**
  /// - `true` if user data and token exist (logged in)
  /// - `false` if either is missing (logged out)
  ///
  /// **Example:**
  /// ```dart
  /// if (authLocal.isUserLogged()) {
  ///   // Navigate to home screen
  ///   Navigator.pushReplacementNamed(context, '/home');
  /// } else {
  ///   // Navigate to login screen
  ///   Navigator.pushReplacementNamed(context, '/login');
  /// }
  /// ```
  bool isUserLogged() {
    return getUser() != null && getToken() != null;
  }
}
