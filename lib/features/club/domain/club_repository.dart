// lib/features/clubs/domain/club_repository.dart
import 'club.dart';
import '../../../features/user/domain/user.dart';

abstract class ClubRepository {
  /// Gets all clubs
  Future<List<Club>> getAllClubs();

  /// Gets all members of a club
  Future<List<User>> getClubMembers(int clubId);

  /// Gets club by ID
  Future<Club?> getClubById(int clubId);

  /// Creates a new club
  Future<Club> createClub({
    required String name,
    required int responsibleId,
    required int addressId,
  });

  /// Updates an existing club
  Future<Club> updateClub({
    required int id,
    String? name,
    int? responsibleId,
    int? addressId,
  });

  /// Deletes a club
  Future<void> deleteClub(int id);
}
