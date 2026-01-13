import '../../domain/user_auth.dart';
import '../../domain/exceptions/auth_exceptions.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_sources.dart';

/// Implementation of AuthRepository for local storage
class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalSources _localDataSource;

  AuthRepositoryImpl(this._localDataSource);

  /// Validate email format
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  /// Validate password strength
  bool _isValidPassword(String password) {
    // At least 8 characters
    return password.length >= 8;
  }

  @override
  Future<User> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String birthDate,
    String ? phoneNumber,
    String ? licenceNumber,
  }) async {
    // Validation
    if (!_isValidEmail(email)) {
      throw ValidationException('Email invalide');
    }

    if (!_isValidPassword(password)) {
      throw ValidationException('Le mot de passe doit contenir au moins 8 caractères');
    }

    if (firstName.isEmpty || lastName.isEmpty) {
      throw ValidationException('Le prénom et le nom sont requis');
    }

    if (birthDate.isEmpty) {
      throw ValidationException('La date de naissance est requise');
    }

    // Check if email already exists
    final registeredUsers = _localDataSource.getRegisteredUsers();
    if (registeredUsers.any((user) => user['email'] == email)) {
      throw EmailAlreadyExistsException();
    }

    // Create new user
    final user = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      firstName: firstName,
      lastName: lastName,
      createdAt: DateTime.now(),
      birthDate: birthDate,
      phoneNumber: phoneNumber,
      licenceNumber: licenceNumber,
    );

    // Save to registered users list
    final updatedUsers = [
      ...registeredUsers,
      {
        ...user.toJson(),
        'password': password, // In production, this would be hashed
      }
    ];
    await _localDataSource.saveRegisteredUsers(updatedUsers);

    // Save current user and token
    await _localDataSource.saveUser(user);
    await _localDataSource.saveToken('token_${user.id}');

    return user;
  }

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    // Validation
    if (!_isValidEmail(email)) {
      throw ValidationException('Email invalide');
    }

    if (password.isEmpty) {
      throw ValidationException('Le mot de passe est requis');
    }

    // Find user in registered users
    final registeredUsers = _localDataSource.getRegisteredUsers();
    final userIndex = registeredUsers.indexWhere(
      (user) => user['email'] == email && user['password'] == password,
    );

    if (userIndex == -1) {
      throw InvalidCredentialsException();
    }

    // Create user object
    final userData = registeredUsers[userIndex];
    final user = User.fromJson(userData);

    // Save current user and token
    await _localDataSource.saveUser(user);
    await _localDataSource.saveToken('token_${user.id}');

    return user;
  }

  @override
  Future<User?> getCurrentUser() async {
    return _localDataSource.getUser();
  }

  @override
  Future<void> logout() async {
    await _localDataSource.clearUser();
  }

  @override
  Future<bool> isAuthenticated() async {
    return _localDataSource.isUserLogged();
  }

  @override
  Future<User> updateProfile({
    String? firstName,
    String? lastName,
    String? profileImageUrl,
  }) async {
    final currentUser = _localDataSource.getUser();
    if (currentUser == null) {
      throw AuthErrorException('Utilisateur non connecté');
    }

    final updatedUser = currentUser.copyWith(
      firstName: firstName ?? currentUser.firstName,
      lastName: lastName ?? currentUser.lastName,
      profileImageUrl: profileImageUrl ?? currentUser.profileImageUrl,
    );

    await _localDataSource.saveUser(updatedUser);
    return updatedUser;
  }
}
