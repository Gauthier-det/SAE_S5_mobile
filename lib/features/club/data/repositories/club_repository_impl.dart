// lib/features/club/data/repositories/club_repository_impl.dart
import '../../domain/club_repository.dart';
import '../../domain/club.dart';
import '../../../user/domain/user.dart';
import '../datasources/club_local_sources.dart';
import '../datasources/club_api_sources.dart';

class ClubRepositoryImpl implements ClubRepository {
  final ClubLocalSources localSources;
  final ClubApiSources apiSources;

  ClubRepositoryImpl({
    required this.localSources,
    required this.apiSources,
  });

  @override
  Future<List<User>> getClubMembers(int clubId) async {
    return await localSources.getClubMembers(clubId);
  }

  @override
  Future<Club?> getClubById(int clubId) async {
    return await localSources.getClubById(clubId);
  }
}
