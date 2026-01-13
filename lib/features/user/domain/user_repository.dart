// lib/features/users/domain/user_repository.dart
import 'user.dart';

abstract class UserRepository {
  /// Gets user's club ID if they are club manager
  /// Returns null if user is not a club manager
  Future<int?> getUserClubId(int userId);
  
  /// Gets user by ID
  Future<User?> getUserById(int userId);
}