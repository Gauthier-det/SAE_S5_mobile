// lib/features/users/data/repositories/user_repository_impl.dart
import '../../domain/user_repository.dart';
import '../../domain/user.dart';
import '../../data/datasources/user_local_sources.dart';
import '../../data/datasources/user_api_sources.dart';

class UserRepositoryImpl implements UserRepository {
  final UserLocalSources localSources;
  final UserApiSources apiSources;

  UserRepositoryImpl({required this.localSources, required this.apiSources});

  @override
  Future<int?> getUserClubId(int userId) async {
    try {
      return await apiSources.getUserClubId(userId);
    } catch (e) {
      print('API non disponible, utilisation du cache local: $e');
      return await localSources.getUserClubId(userId);
    }
  }

  @override
  Future<User?> getUserById(int userId) async {
    try {
      final user = await apiSources.getUserById(userId);
      // Note: Pas de mise en cache car insertUser n'existe pas encore
      return user;
    } catch (e) {
      print('API non disponible, utilisation du cache local: $e');
      return await localSources.getUserById(userId);
    }
  }
}
