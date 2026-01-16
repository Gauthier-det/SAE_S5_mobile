// lib/features/auth/data/repositories/auth_repository_impl.dart
import '../../domain/user_auth.dart';
import '../../domain/exceptions/auth_exceptions.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_sources.dart';
import '../datasources/auth_api_sources.dart';
import '../../../../core/services/api_service.dart';

/// Authentication repository implementation.
///
/// Implements the [AuthRepository] interface following Clean Architecture's
/// repository pattern, which acts as a bridge between the domain layer and
/// data layer [web:106][web:107]. This implementation uses an **offline-first
/// architecture** with API fallback strategy [web:109][web:112].
///
/// ## Architecture Pattern
///
/// The repository pattern provides several key benefits [web:106][web:107]:
/// - **Separation of Concerns**: Isolates domain logic from data sources
/// - **Testability**: Enables mocking data sources for unit testing
/// - **Flexibility**: Allows switching between data sources transparently
/// - **Single Source of Truth**: UI and business logic interact only with the repository
///
/// ## Offline-First Strategy
///
/// This implementation follows offline-first principles [web:109][web:112]:
///
/// 1. **API First, Local Fallback**: Attempts API operations when available,
///    gracefully falls back to local storage if API fails or is unavailable
/// 2. **Local Persistence**: Always persists data locally after successful API calls
/// 3. **Deterministic State**: Maintains consistent state regardless of connectivity
/// 4. **Token Synchronization**: Stores API authentication tokens for subsequent requests
///
/// This pattern ensures the app functions reliably on poor networks while
/// leveraging server data when connectivity is available [web:109][web:112].
///
/// ## Data Flow
///
/// ```
/// Domain Layer (Use Cases)
///         ↓
/// AuthRepository Interface
///         ↓
/// AuthRepositoryImpl ← implements interface
///    ↓           ↓
///   API       Local Storage
/// (primary)   (fallback)
/// ```
///
/// Example usage:
/// ```dart
/// final authRepo = AuthRepositoryImpl(
///   localDataSource,
///   apiDataSource: apiDataSource,
///   apiService: apiService,
/// );
///
/// try {
///   final user = await authRepo.login(
///     email: 'user@example.com',
///     password: 'password123',
///   );
///   print('Logged in: ${user.email}');
/// } catch (e) {
///   // Handle authentication errors
/// }
/// ```
class AuthRepositoryImpl implements AuthRepository {
  /// Local data source for persistent storage.
  ///
  /// Required dependency that handles all local data operations
  /// (SharedPreferences and SQLite) [web:109][web:112].
  final AuthLocalSources _localDataSource;

  /// Optional API data source for remote operations.
  ///
  /// When null, the repository operates in offline-only mode.
  /// When provided, enables API-first with local fallback strategy [web:109].
  final AuthApiSources? _apiDataSource;

  /// Optional API service for connectivity and configuration.
  ///
  /// Used to check API availability before attempting remote operations [web:109].
  final ApiService? _apiService;

  /// Creates an [AuthRepositoryImpl] instance.
  ///
  /// The [_localDataSource] is required for offline functionality.
  /// Both [apiDataSource] and [apiService] are optional, allowing the
  /// repository to operate in offline-only mode when not provided [web:109][web:112].
  AuthRepositoryImpl(
    this._localDataSource, {
    AuthApiSources? apiDataSource,
    ApiService? apiService,
  })  : _apiDataSource = apiDataSource,
        _apiService = apiService;

  /// Validates email format using regex pattern.
  ///
  /// Checks for standard email structure: local@domain.tld
  /// This validation happens at the repository layer to ensure data
  /// integrity before attempting storage or API calls [web:106].
  ///
  /// **Returns:** `true` if email format is valid, `false` otherwise
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Validates password meets minimum security requirements.
  ///
  /// Currently enforces minimum length of 8 characters. Production
  /// implementations should add additional requirements (uppercase,
  /// lowercase, numbers, special characters) [web:106].
  ///
  /// **Returns:** `true` if password meets requirements, `false` otherwise
  bool _isValidPassword(String password) {
    return password.length >= 8;
  }

  @override
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
    // Validate input data before processing [web:106]
    if (!_isValidEmail(email)) {
      throw ValidationException('Email invalide');
    }

    if (!_isValidPassword(password)) {
      throw ValidationException(
        'Le mot de passe doit contenir au moins 8 caractères',
      );
    }

    if (firstName.isEmpty || lastName.isEmpty) {
      throw ValidationException('Le prénom et le nom sont requis');
    }

    // Attempt API registration first (offline-first pattern) [web:109][web:112]
    if (_apiDataSource != null && _apiService != null) {
      try {
        final apiUser = await _apiDataSource.register(
          email: email,
          password: password,
          firstName: firstName,
          lastName: lastName,
          birthDate: birthDate,
          phoneNumber: phoneNumber,
          licenceNumber: licenceNumber,
          gender: gender,
        );

        // Persist API response locally for offline access [web:109][web:112]
        final registeredUsers = await _localDataSource.getRegisteredUsers();
        final updatedUsers = [
          ...registeredUsers,
          {...apiUser.toJson(), 'password': password},
        ];
        await _localDataSource.saveRegisteredUsers(updatedUsers);
        await _localDataSource.saveUser(apiUser);

        // Store JWT access token from API for authenticated requests [web:109]
        if (_apiDataSource.accessToken != null) {
          await _localDataSource.saveToken(_apiDataSource.accessToken!);
        }

        return apiUser;
      } catch (e) {
        // Silently fall back to local registration [web:109][web:112]
      }
    }

    // Local fallback: Register user offline [web:109][web:112]
    final registeredUsers = await _localDataSource.getRegisteredUsers();
    if (registeredUsers.any((user) => user['email'] == email)) {
      throw EmailAlreadyExistsException();
    }

    final user = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      firstName: firstName,
      lastName: lastName,
      createdAt: DateTime.now(),
      birthDate: birthDate,
      phoneNumber: phoneNumber,
      licenceNumber: licenceNumber,
    );

    final updatedUsers = [
      ...registeredUsers,
      {...user.toJson(), 'password': password},
    ];
    await _localDataSource.saveRegisteredUsers(updatedUsers);

    await _localDataSource.saveUser(user);
    await _localDataSource.saveToken('token_${user.id}');

    return user;
  }

  @override
  Future<User> login({required String email, required String password}) async {
    // Validate credentials before attempting authentication [web:106]
    if (!_isValidEmail(email)) {
      throw ValidationException('Email invalide');
    }

    if (password.isEmpty) {
      throw ValidationException('Le mot de passe est requis');
    }

    // Attempt API login first (offline-first strategy) [web:109][web:112]
    if (_apiDataSource != null && _apiService != null) {
      try {
        final apiUser = await _apiDataSource.login(
          email: email,
          password: password,
        );

        // Save authenticated user session locally [web:109][web:112]
        await _localDataSource.saveUser(apiUser);

        // Store JWT access token for subsequent authenticated requests [web:109]
        if (_apiDataSource.accessToken != null) {
          await _localDataSource.saveToken(_apiDataSource.accessToken!);
        }

        return apiUser;
      } catch (e) {
        // Silently fall back to local authentication [web:109][web:112]
      }
    }

    // Local fallback: Authenticate against local user registry [web:109][web:112]
    final registeredUsers = await _localDataSource.getRegisteredUsers();
    final userIndex = registeredUsers.indexWhere(
      (user) => user['email'] == email && user['password'] == password,
    );

    if (userIndex == -1) {
      throw InvalidCredentialsException();
    }

    final userData = registeredUsers[userIndex];
    final user = User.fromJson(userData);

    // Establish local session [web:109][web:112]
    await _localDataSource.saveUser(user);
    await _localDataSource.saveToken('token_${user.id}');

    return user;
  }

  @override
  Future<User?> getCurrentUser() async {
    /// Retrieves the currently authenticated user from local storage.
    ///
    /// This method always reads from local storage, following offline-first
    /// principles where local state is the single source of truth [web:109][web:112].
    ///
    /// **Returns:**
    /// - The authenticated [User] if a session exists
    /// - `null` if no user is logged in
    return _localDataSource.getUser();
  }

  @override
  Future<void> logout() async {
    /// Logs out the current user by clearing all local session data.
    ///
    /// Removes the user object and authentication token from SharedPreferences.
    /// Does not make API calls, as logout is a local operation [web:109].
    ///
    /// **Note:** For complete security, consider calling an API logout endpoint
    /// to invalidate the JWT token on the server side.
    await _localDataSource.clearUser();
  }

  @override
  Future<bool> isAuthenticated() async {
    /// Checks if a user is currently authenticated.
    ///
    /// Verifies the presence of both user data and authentication token
    /// in local storage [web:109][web:112].
    ///
    /// **Returns:**
    /// - `true` if user is authenticated (has valid session)
    /// - `false` if user is not logged in
    return _localDataSource.isUserLogged();
  }

  @override
  Future<User> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? birthDate,
    String? club,
    String? licenceNumber,
    String? ppsNumber,
    String? chipNumber,
    String? profileImageUrl,
  }) async {
    /// Updates the current user's profile information.
    ///
    /// Follows the offline-first pattern: attempts API update first,
    /// falls back to local-only update if API is unavailable [web:109][web:112].
    /// Only non-null parameters are updated, allowing partial updates.
    ///
    /// **Parameters:** All parameters are optional. Only provided values
    /// will be updated in the user profile.
    ///
    /// **Throws:**
    /// - [AuthErrorException] if no user is currently authenticated
    ///
    /// **Returns:** The updated [User] object
    final currentUser = _localDataSource.getUser();
    if (currentUser == null) {
      throw AuthErrorException('Utilisateur non connecté');
    }

    // Attempt API update first [web:109][web:112]
    if (_apiDataSource != null && _apiService != null) {
      try {
        final apiUser = await _apiDataSource.updateProfile(
          userId: currentUser.id,
          firstName: firstName,
          lastName: lastName,
          phoneNumber: phoneNumber,
          birthDate: birthDate,
          licenceNumber: licenceNumber,
        );

        // Persist API response locally [web:109][web:112]
        await _localDataSource.saveUser(apiUser);
        return apiUser;
      } catch (e) {
        // Silently fall back to local update [web:109][web:112]
      }
    }

    // Local fallback: Update user profile offline [web:109][web:112]
    final updatedUser = currentUser.copyWith(
      firstName: firstName ?? currentUser.firstName,
      lastName: lastName ?? currentUser.lastName,
      phoneNumber: phoneNumber ?? currentUser.phoneNumber,
      birthDate: birthDate ?? currentUser.birthDate,
      club: club ?? currentUser.club,
      licenceNumber: licenceNumber ?? currentUser.licenceNumber,
      ppsNumber: ppsNumber ?? currentUser.ppsNumber,
      chipNumber: chipNumber ?? currentUser.chipNumber,
      profileImageUrl: profileImageUrl ?? currentUser.profileImageUrl,
    );

    await _localDataSource.saveUser(updatedUser);
    return updatedUser;
  }
}
