// lib/features/club/data/repositories/club_repository_impl.dart
import '../../domain/club_repository.dart';
import '../../domain/club.dart';
import '../../../user/domain/user.dart';
import '../datasources/club_local_sources.dart';
import '../datasources/club_api_sources.dart';
import '../../../auth/data/datasources/auth_local_sources.dart';

class ClubRepositoryImpl implements ClubRepository {
  final ClubLocalSources localSources;
  final ClubApiSources apiSources;
  final AuthLocalSources authLocalSources;

  ClubRepositoryImpl({
    required this.localSources,
    required this.apiSources,
    required this.authLocalSources,
  });

  @override
  Future<List<Club>> getAllClubs() async {
    try {
      // Set auth token
      final token = authLocalSources.getToken();
      apiSources.setAuthToken(token);

      // Try API first
      final clubs = await apiSources.getClubs();

      // Cache the results locally
      await localSources.insertClubs(clubs);

      return clubs;
    } catch (e) {
      print('🏢 API getAllClubs failed: $e. Falling back to local...');
      // Fallback to local
      return await localSources.getAllClubs();
    }
  }

  @override
  Future<List<User>> getClubMembers(int clubId) async {
    try {
      // Set auth token
      final token = authLocalSources.getToken();
      apiSources.setAuthToken(token);

      // Try API first
      return await apiSources.getClubMembers(clubId);
    } catch (e) {
      print('🏢 API getClubMembers failed: $e. Falling back to local...');
      // Fallback to local
      return await localSources.getClubMembers(clubId);
    }
  }

  @override
  Future<Club?> getClubById(int clubId) async {
    try {
      // Set auth token
      final token = authLocalSources.getToken();
      apiSources.setAuthToken(token);

      // Try API first
      final club = await apiSources.getClubById(clubId);

      // Cache the result locally if found
      if (club != null) {
        await localSources.insertClub(club);
      }

      return club;
    } catch (e) {
      print('🏢 API getClubById failed: $e. Falling back to local...');
      // Fallback to local
      return await localSources.getClubById(clubId);
    }
  }

  @override
  Future<Club> createClub({
    required String name,
    required int responsibleId,
    required int addressId,
  }) async {
    final token = authLocalSources.getToken();
    apiSources.setAuthToken(token);

    // Create via API
    final club = await apiSources.createClub(
      name: name,
      responsibleId: responsibleId,
      addressId: addressId,
    );

    // Cache locally
    await localSources.insertClub(club);

    return club;
  }

  @override
  Future<Club> updateClub({
    required int id,
    String? name,
    int? responsibleId,
    int? addressId,
  }) async {
    final token = authLocalSources.getToken();
    apiSources.setAuthToken(token);

    final club = await apiSources.updateClub(
      id: id,
      name: name,
      responsibleId: responsibleId,
      addressId: addressId,
    );

    await localSources.insertClub(club);
    return club;
  }

  @override
  Future<void> deleteClub(int id) async {
    final token = authLocalSources.getToken();
    apiSources.setAuthToken(token);

    await apiSources.deleteClub(id);

    // TODO: Remove from local cache if needed
  }
}
