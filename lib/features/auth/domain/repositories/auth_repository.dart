import '../user_auth.dart';
import '../exceptions/auth_exceptions.dart';

/// Repository interface for authentication operations
abstract class AuthRepository {
  /// Register a new user
  /// 
  /// Throws [ValidationException] if input is invalid
  /// Throws [EmailAlreadyExistsException] if email already exists
  /// Throws [AuthErrorException] for other errors
  Future<User> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  });

  /// Login with email and password
  /// 
  /// Throws [InvalidCredentialsException] if credentials are invalid
  /// Throws [ValidationException] if input is invalid
  /// Throws [AuthErrorException] for other errors
  Future<User> login({
    required String email,
    required String password,
  });

  /// Get current logged-in user
  Future<User?> getCurrentUser();

  /// Logout current user
  Future<void> logout();

  /// Check if user is authenticated
  Future<bool> isAuthenticated();

  /// Update user profile
  Future<User> updateProfile({
    String? firstName,
    String? lastName,
    String? profileImageUrl,
  });
}
