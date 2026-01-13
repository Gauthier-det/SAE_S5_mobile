// lib/features/clubs/domain/club_repository.dart
import 'club.dart';
import '../../../features/user/domain/user.dart';

abstract class ClubRepository {
  /// Gets all members of a club
  Future<List<User>> getClubMembers(int clubId);
  
  /// Gets club by ID
  Future<Club?> getClubById(int clubId);
}