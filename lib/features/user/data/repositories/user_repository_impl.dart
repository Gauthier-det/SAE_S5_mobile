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
    try {
      final token = authLocalSources.getToken();

      apiSources.setAuthToken(token);

      final users = await apiSources.getAllUsers();

      return users;
    } catch (e) {
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
