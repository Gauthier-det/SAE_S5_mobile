// lib/features/auth/data/repositories/auth_repository_impl.dart
import '../../domain/user_auth.dart';
import '../../domain/exceptions/auth_exceptions.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_sources.dart';
import '../datasources/auth_api_sources.dart';
import '../../../../core/services/api_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalSources _localDataSource;
  final AuthApiSources? _apiDataSource;
  final ApiService? _apiService;

  AuthRepositoryImpl(
    this._localDataSource, {
    AuthApiSources? apiDataSource,
    ApiService? apiService,
  }) : _apiDataSource = apiDataSource,
       _apiService = apiService;

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  bool _isValidPassword(String password) {
    return password.length >= 8;
  }

  @override
  Future<User> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? birthDate,
    String? phoneNumber,
    String? licenceNumber,
    String gender = 'Autre',
  }) async {
    if (!_isValidEmail(email)) {
      throw ValidationException('Email invalide');
    }

    if (!_isValidPassword(password)) {
      throw ValidationException(
        'Le mot de passe doit contenir au moins 8 caractères',
      );
    }

    if (firstName.isEmpty || lastName.isEmpty) {
      throw ValidationException('Le prénom et le nom sont requis');
    }

    // Tentative d'inscription via API si disponible
    if (_apiDataSource != null && _apiService != null) {
      final apiUser = await _apiDataSource.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        birthDate: birthDate,
        phoneNumber: phoneNumber,
        licenceNumber: licenceNumber,
        gender: gender,
      );

      // Sauvegarder localement
      final registeredUsers = await _localDataSource.getRegisteredUsers();
      final updatedUsers = [
        ...registeredUsers,
        {...apiUser.toJson(), 'password': password},
      ];
      await _localDataSource.saveRegisteredUsers(updatedUsers);
      await _localDataSource.saveUser(apiUser);
      // Stocker le vrai access_token de l'API
      if (_apiDataSource.accessToken != null) {
        await _localDataSource.saveToken(_apiDataSource.accessToken!);
      }

      return apiUser;
    }

    // Fallback: Inscription locale
    final registeredUsers = await _localDataSource.getRegisteredUsers();
    if (registeredUsers.any((user) => user['email'] == email)) {
      throw EmailAlreadyExistsException();
    }

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

    final updatedUsers = [
      ...registeredUsers,
      {...user.toJson(), 'password': password},
    ];
    await _localDataSource.saveRegisteredUsers(updatedUsers);

    await _localDataSource.saveUser(user);
    await _localDataSource.saveToken('token_${user.id}');

    return user;
  }

  @override
  Future<User> login({required String email, required String password}) async {
    if (!_isValidEmail(email)) {
      throw ValidationException('Email invalide');
    }

    if (password.isEmpty) {
      throw ValidationException('Le mot de passe est requis');
    }

    // Tentative de connexion via API si disponible
    if (_apiDataSource != null && _apiService != null) {
      try {
        final apiUser = await _apiDataSource.login(
          email: email,
          password: password,
        );

        // Sauvegarder localement
        await _localDataSource.saveUser(apiUser);
        // Stocker le vrai access_token de l'API
        if (_apiDataSource.accessToken != null) {
          await _localDataSource.saveToken(_apiDataSource.accessToken!);
        }

        return apiUser;
      } catch (e) {}
    }

    // Fallback: Connexion locale
    final registeredUsers = await _localDataSource.getRegisteredUsers();
    final userIndex = registeredUsers.indexWhere(
      (user) => user['email'] == email && user['password'] == password,
    );

    if (userIndex == -1) {
      throw InvalidCredentialsException();
    }

    final userData = registeredUsers[userIndex];
    final user = User.fromJson(userData);

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
    String? phoneNumber,
    String? birthDate,
    String? club,
    String? licenceNumber,
    String? ppsNumber,
    String? chipNumber,
    String? profileImageUrl,
  }) async {
    final currentUser = _localDataSource.getUser();
    if (currentUser == null) {
      throw AuthErrorException('Utilisateur non connecté');
    }

    // Tentative de mise à jour via API si disponible
    if (_apiDataSource != null && _apiService != null) {
      try {
        final apiUser = await _apiDataSource.updateProfile(
          userId: currentUser.id,
          firstName: firstName,
          lastName: lastName,
          phoneNumber: phoneNumber,
          birthDate: birthDate,
          licenceNumber: licenceNumber,
        );

        // Sauvegarder localement
        await _localDataSource.saveUser(apiUser);
        return apiUser;
      } catch (e) {}
    }

    // Fallback: Mise à jour locale
    final updatedUser = currentUser.copyWith(
      firstName: firstName ?? currentUser.firstName,
      lastName: lastName ?? currentUser.lastName,
      phoneNumber: phoneNumber ?? currentUser.phoneNumber,
      birthDate: birthDate ?? currentUser.birthDate,
      club: club ?? currentUser.club,
      licenceNumber: licenceNumber ?? currentUser.licenceNumber,
      ppsNumber: ppsNumber ?? currentUser.ppsNumber,
      chipNumber: chipNumber ?? currentUser.chipNumber,
      profileImageUrl: profileImageUrl ?? currentUser.profileImageUrl,
    );

    await _localDataSource.saveUser(updatedUser);
    return updatedUser;
  }
}
