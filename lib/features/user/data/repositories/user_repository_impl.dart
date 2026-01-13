// lib/features/users/data/repositories/user_repository_impl.dart
import '../../domain/user_repository.dart';
import '../../domain/user.dart';
import '../../data/datasources/user_local_sources.dart';
import '../../data/datasources/user_api_sources.dart';

class UserRepositoryImpl implements UserRepository {
  final UserLocalSources localSources;
  final UserApiSources apiSources;

  UserRepositoryImpl({
    required this.localSources,
    required this.apiSources,
  });

  @override
  Future<int?> getUserClubId(int userId) async {
    return await localSources.getUserClubId(userId);
  }

  @override
  Future<User?> getUserById(int userId) async {
    return await localSources.getUserById(userId);
  }
}