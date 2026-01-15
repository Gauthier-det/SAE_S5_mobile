import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/services/api_service.dart';
import '../../data/datasources/auth_api_sources.dart';
import '../../data/datasources/auth_local_sources.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/user_auth.dart';
import '../../domain/exceptions/auth_exceptions.dart';
import '../../../user/domain/user_repository.dart';
import '../../../user/data/repositories/user_repository_impl.dart';
import '../../../user/data/datasources/user_api_sources.dart';
import '../../../user/data/datasources/user_local_sources.dart';

/// Provider for managing authentication state
class AuthProvider extends ChangeNotifier {
  final AuthRepositoryImpl _repository;
  final UserRepository? _userRepository;

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider(this._repository, [this._userRepository]);

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  /// Factory constructor to initialize with SharedPreferences
  static Future<AuthProvider> create() async {
    final prefs = await SharedPreferences.getInstance();
    final localDataSource = AuthLocalSources(prefs);
    final apiDataSource = AuthApiSources(baseUrl: AppConfig.apiBaseUrl);
    final apiService = ApiService();
    final repository = AuthRepositoryImpl(
      localDataSource,
      apiDataSource: apiDataSource,
      apiService: apiService,
    );

    // Initialize UserRepository for profile updates
    final userApiSources = UserApiSources(baseUrl: AppConfig.apiBaseUrl);
    final userLocalSources = UserLocalSources();
    final userRepository = UserRepositoryImpl(
      apiSources: userApiSources,
      localSources: userLocalSources,
      authLocalSources: localDataSource, // Reuse auth local source for token
    );

    return AuthProvider(repository, userRepository)..checkAuth();
  }

  /// Check if user is already authenticated
  Future<void> checkAuth() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _repository.getCurrentUser();
      _currentUser = user;
    } catch (e) {
      _errorMessage = e.toString();
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Register a new user
  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? birthDate,
    String? phoneNumber,
    String? licenceNumber,
    String gender = 'Autre',
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _repository.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        birthDate: birthDate,
        phoneNumber: phoneNumber,
        licenceNumber: licenceNumber,
        gender: gender,
      );
      _currentUser = user;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      rethrow;
    } catch (e) {
      _errorMessage = 'Erreur lors de l\'inscription';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Login user
  Future<void> login({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _repository.login(email: email, password: password);
      _currentUser = user;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      rethrow;
    } catch (e) {
      _errorMessage = 'Erreur lors de la connexion';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Logout user
  Future<void> logout() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.logout();
      _currentUser = null;
    } catch (e) {
      _errorMessage = 'Erreur lors de la déconnexion';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update user profile
  Future<void> updateProfile({
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
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_userRepository != null && _currentUser != null) {
        print('📝 UpdateProfile - Using UserRepository');
        print('📝 UpdateProfile - User ID: ${_currentUser!.id}');

        // Prepare fields for API update - use API field names (USE_* format)
        final fields = <String, dynamic>{};
        if (firstName != null) fields['USE_NAME'] = firstName;
        if (lastName != null) fields['USE_LAST_NAME'] = lastName;
        if (phoneNumber != null) fields['USE_PHONE_NUMBER'] = phoneNumber;
        if (birthDate != null) fields['USE_BIRTHDATE'] = birthDate;
        if (licenceNumber != null) fields['USE_LICENCE_NUMBER'] = licenceNumber;

        print('📝 UpdateProfile - Fields to update: $fields');

        // Call UserRepository with fields map
        await _userRepository.updateUserFields(
          int.parse(_currentUser!.id),
          fields,
        );

        print('📝 UpdateProfile - API call succeeded');

        // Update local state manually since we don't get a full user object back that matches Auth User
        _currentUser = _currentUser!.copyWith(
          firstName: firstName,
          lastName: lastName,
          phoneNumber: phoneNumber,
          birthDate: birthDate,
          club:
              club, // Local only update if not sent to API (API doesn't seem to take club string)
          licenceNumber: licenceNumber,
          ppsNumber: ppsNumber,
          chipNumber: chipNumber,
          profileImageUrl: profileImageUrl,
        );
        print('📝 UpdateProfile - Local state updated');
      } else {
        print('📝 UpdateProfile - Falling back to AuthRepository');
        print(
          '📝 UpdateProfile - _userRepository is null: ${_userRepository == null}',
        );
        print(
          '📝 UpdateProfile - _currentUser is null: ${_currentUser == null}',
        );
        // Fallback to legacy AuthRepository if UserRepository is not available
        final updatedUser = await _repository.updateProfile(
          firstName: firstName,
          lastName: lastName,
          phoneNumber: phoneNumber,
          birthDate: birthDate,
          club: club,
          licenceNumber: licenceNumber,
          ppsNumber: ppsNumber,
          chipNumber: chipNumber,
          profileImageUrl: profileImageUrl,
        );
        _currentUser = updatedUser;
      }
    } catch (e, stackTrace) {
      print('❌ UpdateProfile - Error: $e');
      print('❌ UpdateProfile - StackTrace: $stackTrace');
      _errorMessage = 'Erreur lors de la mise à jour du profil: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
