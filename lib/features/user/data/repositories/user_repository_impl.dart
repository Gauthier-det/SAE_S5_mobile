// lib/features/users/data/repositories/user_repository_impl.dart
import '../../domain/user_repository.dart';
import '../../domain/user.dart';
import '../../data/datasources/user_local_sources.dart';
import '../../data/datasources/user_api_sources.dart';
import '../../../auth/data/datasources/auth_local_sources.dart';

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
    print('👥 UserRepositoryImpl.getAllUsers - Start');
    try {
      final token = authLocalSources.getToken();
      print(
        '👥 UserRepositoryImpl.getAllUsers - Token: ${token != null ? "present" : "null"}',
      );
      apiSources.setAuthToken(token);

      final users = await apiSources.getAllUsers();
      print(
        '👥 UserRepositoryImpl.getAllUsers - Got ${users.length} users from API',
      );
      return users;
    } catch (e) {
      print(
        '❌ UserRepositoryImpl.getAllUsers - API failed: $e. Falling back to local...',
      );
      final localUsers = await localSources.getAllUsers();
      print(
        '👥 UserRepositoryImpl.getAllUsers - Got ${localUsers.length} users from local',
      );
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
      // Try fetching from API
      // We might need a token if the endpoint is protected, but usually getById might be public or require token
      // RaidRepository gets token inside the method? No, createRaid does.
      // But RaidRepository.getRaidById doesn't set token. It assumes public?
      // User profile is likely protected. Let's try to set token if available.
      final token = authLocalSources.getToken();
      apiSources.setAuthToken(token);

      final remoteUser = await apiSources.getUserById(userId);

      if (remoteUser != null) {
        // Cache to local
        await localSources.insertUser(remoteUser);
        return remoteUser;
      }

      return null;
    } catch (e) {
      print('API fetch failed: $e. Falling back to local cache...');
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

      // Update local cache
      await localSources.insertUser(updatedUser);

      return updatedUser;
    } catch (e) {
      print('API update failed: $e. Saving locally...');
      // Fallback: save locally
      await localSources.insertUser(user);
      return user;
    }
  }

  @override
  Future<void> updateUserFields(int id, Map<String, dynamic> fields) async {
    final token = authLocalSources.getToken();
    apiSources.setAuthToken(token);

    // We assume this is only called when API is available as it's a specific partial update
    await apiSources.updateUserFields(id, fields);

    // Note: We should ideally update the local cache too, but without a full User object return
    // or a way to patch the local User, we might skip it or rely on next fetch.
    // For now, let's rely on the API success.
  }
}
