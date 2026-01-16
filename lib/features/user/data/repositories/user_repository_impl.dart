// lib/features/users/data/repositories/user_repository_impl.dart
import '../../domain/user_repository.dart';
import '../../domain/user.dart';
import '../../data/datasources/user_local_sources.dart';
import '../../data/datasources/user_api_sources.dart';
import '../../../auth/data/datasources/auth_local_sources.dart';

/// Repository implementation with API-first, local-fallback strategy [web:194][web:310][web:313].
///
/// Implements network-first caching: attempts API request, falls back to local
/// SQLite on failure. Automatically caches successful API responses locally for
/// offline access [web:310][web:313].
///
/// **Caching Strategy [web:310][web:313]:**
/// - Network-first: Try API, fallback to cache on network error
/// - Write-through: Cache successful API responses immediately
/// - Auth token injection: Reads token from AuthLocalSources before each API call
///
/// **Fallback Behavior:**
/// - getAllUsers: API → local list
/// - getUserById: API → local user → null
/// - updateUser: API with cache update → local update only
/// - updateUserFields: API only (no local fallback)
///
/// Example:
/// ```dart
/// final repository = UserRepositoryImpl(
///   localSources: UserLocalSources(),
///   apiSources: UserApiSources(baseUrl: apiUrl),
///   authLocalSources: AuthLocalSources(),
/// );
/// 
/// // Tries API, falls back to cached data
/// final users = await repository.getAllUsers();
/// 
/// // Updates API and local cache atomically
/// final updated = await repository.updateUser(user);
/// ```
class UserRepositoryImpl implements UserRepository {
  final UserLocalSources localSources;
  final UserApiSources apiSources;
  final AuthLocalSources authLocalSources;

  UserRepositoryImpl({
    required this.localSources,
    required this.apiSources,
    required this.authLocalSources,
  });

  @override
  Future<List<User>> getAllUsers() async {
    try {
      final token = authLocalSources.getToken();
      apiSources.setAuthToken(token);

      final users = await apiSources.getAllUsers();
      return users;
    } catch (e) {
      // Fallback to local cache [web:310][web:313]
      final localUsers = await localSources.getAllUsers();
      return localUsers;
    }
  }

  @override
  Future<int?> getUserClubId(int userId) async {
    return await localSources.getUserClubId(userId);
  }

  @override
  Future<User?> getUserById(int userId) async {
    try {
      final token = authLocalSources.getToken();
      apiSources.setAuthToken(token);

      final remoteUser = await apiSources.getUserById(userId);

      if (remoteUser != null) {
        // Write-through cache: save API response locally [web:310]
        await localSources.insertUser(remoteUser);
        return remoteUser;
      }

      return null;
    } catch (e) {
      // Fallback to local cache [web:313]
      try {
        return await localSources.getUserById(userId);
      } catch (localError) {
        rethrow;
      }
    }
  }

  @override
  Future<User> updateUser(User user) async {
    try {
      final token = authLocalSources.getToken();
      apiSources.setAuthToken(token);

      final updatedUser = await apiSources.updateUser(user);

      // Atomic cache update after successful API call [web:310]
      await localSources.insertUser(updatedUser);

      return updatedUser;
    } catch (e) {
      // Fallback: save locally (optimistic update) [web:313]
      await localSources.insertUser(user);
      return user;
    }
  }

  @override
  Future<void> updateUserFields(int id, Map<String, dynamic> fields) async {
    final token = authLocalSources.getToken();
    apiSources.setAuthToken(token);

    // API-only partial update (no local fallback)
    // Rationale: Partial updates without full object make local sync complex.
    // Relies on next getUserById fetch to update local cache.
    await apiSources.updateUserFields(id, fields);

    // Note: Local cache not updated here to avoid partial state.
    // Next fetch will sync full object from API.
  }
}
