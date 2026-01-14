// lib/features/auth/data/repositories/auth_repository_impl.dart
import '../../domain/user_auth.dart';
import '../../domain/exceptions/auth_exceptions.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_sources.dart';
import '../datasources/AuthApiSources.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalSources _localDataSource;
  final AuthApiSources _apiDataSource;

  AuthRepositoryImpl(this._localDataSource, this._apiDataSource);

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

    try {
      // Tentative d'inscription via l'API
      final apiResponse = await _apiDataSource.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        birthDate: birthDate,
        phoneNumber: phoneNumber,
        licenceNumber: licenceNumber,
      );

      print('✅ API Response for register: $apiResponse');

      // Extraire les données de la réponse (format: {data: {...}})
      final data = apiResponse['data'] ?? apiResponse;

      // Créer l'objet User depuis la réponse API
      final user = User(
        id:
            data['user_id']?.toString() ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        email: data['user_mail'] ?? email,
        firstName: data['user_name'] ?? firstName,
        lastName: data['user_last_name'] ?? lastName,
        createdAt: DateTime.now(),
        birthDate: birthDate,
        phoneNumber: phoneNumber,
        licenceNumber: licenceNumber,
      );

      // Sauvegarder en local
      await _localDataSource.saveUser(user);
      await _localDataSource.saveToken(
        data['access_token'] ?? 'token_${user.id}',
      );

      return user;
    } catch (e) {
      print('API non disponible pour l\'inscription, utilisation locale: $e');

      // Fallback sur l'inscription locale
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
  }

  @override
  Future<User> login({required String email, required String password}) async {
    if (!_isValidEmail(email)) {
      throw ValidationException('Email invalide');
    }

    if (password.isEmpty) {
      throw ValidationException('Le mot de passe est requis');
    }

    try {
      // Tentative de connexion via l'API
      final apiResponse = await _apiDataSource.login(
        email: email,
        password: password,
      );

      print('✅ API Response for login: $apiResponse');

      // Extraire les données de la réponse (format: {data: {...}})
      final data = apiResponse['data'] ?? apiResponse;
      
      print('📦 Data extracted: $data');
      print('🏢 user_club value: ${data['user_club']}');
      print('🏢 user_club_id value: ${data['user_club_id']}');
      
      // Extraire le clubId depuis user_club si présent, sinon user_club_id
      int? clubId;
      String? clubName;
      if (data['user_club'] != null && data['user_club'] is Map) {
        print('🏢 user_club content: ${data['user_club']}');
        clubId = data['user_club']['CLU_ID'];
        clubName = data['user_club']['CLU_NAME'];
        print('🏢 Extracted clubId from user_club: $clubId, clubName: $clubName');
      } else if (data['user_club_id'] != null) {
        clubId = data['user_club_id'];
        print('🏢 Extracted clubId from user_club_id: $clubId');
      } else {
        print('⚠️ user_club and user_club_id are both null in response');
      }

      // Créer l'objet User depuis la réponse API
      final user = User(
        id: data['user_id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
        email: data['user_mail'] ?? email,
        firstName: data['user_name'] ?? '',
        lastName: data['user_last_name'] ?? '',
        createdAt: DateTime.now(),
        birthDate: data['user_birthdate'],
        phoneNumber: data['user_phone']?.toString(),
        licenceNumber: data['user_licence']?.toString(),
        clubId: clubId,
        club: clubName,
        ppsNumber: data['user_pps'],
      );

      // Sauvegarder en local
      await _localDataSource.saveUser(user);
      await _localDataSource.saveToken(
        data['access_token'] ?? 'token_${user.id}',
      );

      return user;
    } catch (e) {
      print('API non disponible pour la connexion, utilisation locale: $e');

      // Fallback sur la connexion locale
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
  }

  @override
  Future<User?> getCurrentUser() async {
    return _localDataSource.getUser();
  }

  @override
  Future<void> logout() async {
    try {
      final token = await _localDataSource.getToken();
      if (token != null) {
        await _apiDataSource.logout(token);
      }
    } catch (e) {
      print('API non disponible pour la déconnexion: $e');
    } finally {
      // Toujours nettoyer les données locales
      await _localDataSource.clearUser();
    }
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
    int? clubId,
    String? licenceNumber,
    String? ppsNumber,
    String? chipNumber,
    String? profileImageUrl,
    String? streetNumber,
    String? streetName,
    String? postalCode,
    String? city,
  }) async {
    final currentUser = _localDataSource.getUser();
    if (currentUser == null) {
      throw AuthErrorException('Utilisateur non connecté');
    }

    final updatedUser = currentUser.copyWith(
      firstName: firstName ?? currentUser.firstName,
      lastName: lastName ?? currentUser.lastName,
      phoneNumber: phoneNumber ?? currentUser.phoneNumber,
      birthDate: birthDate ?? currentUser.birthDate,
      club: club ?? currentUser.club,
      clubId: clubId ?? currentUser.clubId,
      licenceNumber: licenceNumber ?? currentUser.licenceNumber,
      ppsNumber: ppsNumber ?? currentUser.ppsNumber,
      chipNumber: chipNumber ?? currentUser.chipNumber,
      profileImageUrl: profileImageUrl ?? currentUser.profileImageUrl,
      streetNumber: streetNumber ?? currentUser.streetNumber,
      streetName: streetName ?? currentUser.streetName,
      postalCode: postalCode ?? currentUser.postalCode,
      city: city ?? currentUser.city,
    );

    await _localDataSource.saveUser(updatedUser);
    return updatedUser;
  }
}
