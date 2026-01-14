// lib/features/club/data/repositories/club_repository_impl.dart
import '../../domain/club_repository.dart';
import '../../domain/club.dart';
import '../../../user/domain/user.dart';
import '../datasources/club_local_sources.dart';
import '../datasources/club_api_sources.dart';

class ClubRepositoryImpl implements ClubRepository {
  final ClubLocalSources localSources;
  final ClubApiSources apiSources;

  ClubRepositoryImpl({required this.localSources, required this.apiSources});

  @override
  Future<List<User>> getClubMembers(int clubId) async {
    try {
      // TODO: L'API retourne List<dynamic>, conversion nécessaire
      return await localSources.getClubMembers(clubId);
    } catch (e) {
      print('API non disponible, utilisation du cache local: $e');
      return await localSources.getClubMembers(clubId);
    }
  }

  @override
  Future<Club?> getClubById(int clubId) async {
    try {
      final club = await apiSources.getClubById(clubId);
      // Note: Pas de mise en cache car insertClub n'existe pas encore
      return club;
    } catch (e) {
      print('API non disponible, utilisation du cache local: $e');
      return await localSources.getClubById(clubId);
    }
  }
}
