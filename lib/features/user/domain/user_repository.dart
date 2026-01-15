// lib/features/users/domain/user_repository.dart
import 'user.dart';

abstract class UserRepository {
  /// Gets all users
  Future<List<User>> getAllUsers();

  /// Gets user's club ID if they are club manager
  /// Returns null if user is not a club manager
  Future<int?> getUserClubId(int userId);

  /// Gets user by ID
  Future<User?> getUserById(int userId);

  /// Updates a user's profile
  Future<User> updateUser(User user);

  /// Updates specific fields of a user
  Future<void> updateUserFields(int id, Map<String, dynamic> fields);
}
