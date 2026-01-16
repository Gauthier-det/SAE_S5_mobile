// lib/features/auth/data/datasources/auth_api_sources.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/user_auth.dart';

/// Authentication API data source.
///
/// Handles all HTTP communication with the authentication backend API, including
/// user registration, login, profile updates, and JWT token management [web:84][web:86].
/// This class follows Flutter's data layer pattern where services interact with
/// external APIs and provide raw data to repositories [web:89][web:92].
///
/// The data source maintains an access token (JWT) for authenticated requests,
/// which is stored after successful login or registration and included in
/// subsequent API calls via Bearer authentication [web:84][web:86].
///
/// **Architecture:**
/// - Part of the data layer in clean architecture [web:89][web:92]
/// - Stateless API communication (except token storage)
/// - Returns domain entities ([User]) for repository consumption
/// - Handles HTTP errors and status codes
///
/// Example usage:
/// ```dart
/// final authApi = AuthApiSources(
///   baseUrl: 'https://api.example.com',
/// );
///
/// try {
///   final user = await authApi.login(
///     email: 'user@example.com',
///     password: 'password123',
///   );
///   print('Logged in: ${user.email}');
/// } catch (e) {
///   print('Login failed: $e');
/// }
/// ```
class AuthApiSources {
  /// Base URL for the authentication API.
  ///
  /// All API endpoints are relative to this base URL.
  /// Example: 'https://api.example.com' or 'http://localhost:3000'
  final String baseUrl;

  /// HTTP client for making network requests.
  ///
  /// Uses the [http] package which provides a composable, Future-based
  /// API for HTTP requests [web:84][web:86]. Can be injected for testing.
  final http.Client client;

  /// JWT access token for authenticated requests.
  ///
  /// Stored after successful login or registration and included in
  /// subsequent API calls using Bearer authentication [web:86][web:90].
  /// Should be persisted to secure storage for session management.
  String? _accessToken;

  /// Creates an [AuthApiSources] instance.
  ///
  /// The [baseUrl] parameter is required and should point to the API root.
  /// The [client] parameter is optional and defaults to a new [http.Client]
  /// instance, allowing for dependency injection during testing [web:84].
  AuthApiSources({required this.baseUrl, http.Client? client})
      : client = client ?? http.Client();

  /// Public getter for the access token.
  ///
  /// Returns the currently stored JWT access token, or null if no user
  /// is authenticated. Used by repositories to check authentication state
  /// or persist tokens to secure storage [web:86][web:90].
  String? get accessToken => _accessToken;

  /// Registers a new user account via the API.
  ///
  /// Sends user registration data to the `/register` endpoint and returns
  /// a [User] object on success. The access token is automatically stored
  /// for subsequent authenticated requests [web:86].
  ///
  /// **Parameters:**
  /// - [email]: User's email address (required, must be unique)
  /// - [password]: User's password (required)
  /// - [firstName]: User's first name (required)
  /// - [lastName]: User's last name (required)
  /// - [birthDate]: Optional birth date in ISO format
  /// - [phoneNumber]: Optional phone number
  /// - [licenceNumber]: Optional orienteering license number
  /// - [gender]: Gender (defaults to 'Autre')
  ///
  /// **Throws:**
  /// - [Exception] if email is already in use (status 422)
  /// - [Exception] for network errors or invalid responses
  /// - [TimeoutException] if request exceeds 10 seconds
  ///
  /// **Returns:** A [User] object representing the newly registered user
  Future<User> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? birthDate,
    String? phoneNumber,
    String? licenceNumber,
    String gender = 'Autre',
  }) async {
    final response = await client
        .post(
          Uri.parse('$baseUrl/register'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'mail': email,
            'password': password,
            'name': firstName,
            'last_name': lastName,
            'gender': gender,
            'birthdate': birthDate,
            'phone_number': phoneNumber,
            'licence_number': licenceNumber,
          }),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 201 || response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final data = responseData['data'];

      // Store JWT token for future authenticated requests [web:86]
      _accessToken = data['access_token'];

      return User.fromJson({
        'id': data['user_id'].toString(),
        'email': data['user_mail'] ?? '',
        'firstName': data['user_name'] ?? '',
        'lastName': data['user_last_name'] ?? '',
        'birthDate': data['user_birthdate'],
        'phoneNumber': data['user_phone']?.toString(),
        'licenceNumber': data['user_licence']?.toString(),
        'club': data['user_club']?['CLU_NAME'],
        'ppsNumber': null,
        'chipNumber': null,
        'profileImageUrl': null,
        'createdAt': DateTime.now().toIso8601String(),
        'roles': [],
      });
    } else if (response.statusCode == 422) {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Email déjà utilisé');
    } else {
      throw Exception('Erreur de connexion: ${response.statusCode}');
    }
  }

  /// Authenticates a user via the API.
  ///
  /// Sends login credentials to the `/login` endpoint and returns a [User]
  /// object on success. The JWT access token is automatically stored and
  /// included in subsequent authenticated requests [web:84][web:86].
  ///
  /// After successful login, performs an additional check via `/user/is-admin`
  /// to verify admin status and update user roles accordingly [web:84].
  ///
  /// **Parameters:**
  /// - [email]: User's email address
  /// - [password]: User's password
  ///
  /// **Throws:**
  /// - [Exception] with message 'Email ou mot de passe incorrect' (status 401)
  /// - [Exception] for network errors or invalid responses
  /// - [TimeoutException] if request exceeds 10 seconds
  ///
  /// **Returns:** A [User] object with authentication token and role information
  Future<User> login({required String email, required String password}) async {
    final response = await client
        .post(
          Uri.parse('$baseUrl/login'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'mail': email, 'password': password}),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 201 || response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final data = responseData['data'];

      // Store JWT token for authenticated requests [web:86][web:90]
      _accessToken = data['access_token'];

      // Extract user roles from API response
      List<int> roles = [];
      if (data['roles'] != null) {
        roles = (data['roles'] as List<dynamic>).map((r) => r as int).toList();
      } else if (data['user_roles'] != null) {
        roles = (data['user_roles'] as List<dynamic>)
            .map((r) => r as int)
            .toList();
      }

      final userMap = {
        'id': data['user_id'].toString(),
        'email': data['user_mail'] ?? '',
        'firstName': data['user_name'] ?? '',
        'lastName': data['user_last_name'] ?? '',
        'birthDate': data['user_birthdate'],
        'phoneNumber': data['user_phone']?.toString(),
        'licenceNumber': data['user_licence']?.toString(),
        'club': data['user_club']?['CLU_NAME'],
        'ppsNumber': null,
        'chipNumber': null,
        'profileImageUrl': null,
        'createdAt': DateTime.now().toIso8601String(),
        'roles': roles,
      };

      final user = User.fromJson(userMap);

      // Verify admin status via separate API endpoint [web:84]
      try {
        final isAdmin = await _checkIsAdmin();
        if (isAdmin) {
          // Return user with site manager role (role ID: 2)
          return User.fromJson({
            ...userMap,
            'roles': [2],
          });
        }
      } catch (e) {
        // Continue with original roles if admin check fails
      }

      return user;
    } else if (response.statusCode == 401) {
      throw Exception('Email ou mot de passe incorrect');
    } else {
      throw Exception('Erreur de connexion: ${response.statusCode}');
    }
  }

  /// Checks if the current authenticated user has admin privileges.
  ///
  /// Makes an authenticated request to `/user/is-admin` endpoint using
  /// the stored access token via Bearer authentication [web:84][web:86].
  /// This is a private helper method called during login to verify admin status.
  ///
  /// **Returns:**
  /// - `true` if user is an admin
  /// - `false` if user is not an admin, not authenticated, or request fails
  ///
  /// **Note:** This method silently returns false on errors rather than throwing,
  /// allowing the login process to continue with basic user roles.
  Future<bool> _checkIsAdmin() async {
    if (_accessToken == null) return false;

    final response = await client
        .get(
          Uri.parse('$baseUrl/user/is-admin'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_accessToken',
          },
        )
        .timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Handle multiple possible response formats
      return data['is_admin'] == true ||
          data['isAdmin'] == true ||
          data['data'] == true ||
          data == true;
    }
    return false;
  }

  /// Updates user profile information via the API.
  ///
  /// Sends a PUT request to `/users/{userId}` with the updated profile data.
  /// Only provided (non-null) fields will be included in the update request [web:84].
  ///
  /// **Parameters:**
  /// - [userId]: ID of the user to update
  /// - [firstName]: Updated first name (optional)
  /// - [lastName]: Updated last name (optional)
  /// - [phoneNumber]: Updated phone number (optional)
  /// - [birthDate]: Updated birth date (optional)
  /// - [licenceNumber]: Updated license number (optional)
  ///
  /// **Throws:**
  /// - [Exception] for network errors or invalid responses
  /// - [TimeoutException] if request exceeds 10 seconds
  ///
  /// **Returns:** A [User] object with the updated profile information
  ///
  /// **Note:** This method currently doesn't include authentication headers.
  /// Consider adding `Authorization: Bearer $_accessToken` header for
  /// authenticated profile updates [web:84].
  Future<User> updateProfile({
    required String userId,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? birthDate,
    String? licenceNumber,
  }) async {
    final response = await client
        .put(
          Uri.parse('$baseUrl/users/$userId'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            if (firstName != null) 'prenom': firstName,
            if (lastName != null) 'nom': lastName,
            if (phoneNumber != null) 'tel': phoneNumber,
            if (birthDate != null) 'date_naissance': birthDate,
            if (licenceNumber != null) 'numero_licence': licenceNumber,
          }),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return User.fromJson({
        'id': data['id'].toString(),
        'email': data['mail'],
        'firstName': data['prenom'],
        'lastName': data['nom'],
        'birthDate': data['date_naissance'],
        'phoneNumber': data['tel'],
        'licenceNumber': data['numero_licence'],
        'createdAt': DateTime.now().toIso8601String(),
      });
    } else {
      throw Exception('Erreur de mise à jour: ${response.statusCode}');
    }
  }
}
