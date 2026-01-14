import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/auth_local_sources.dart';
import '../../data/datasources/AuthApiSources.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/user_auth.dart';
import '../../domain/exceptions/auth_exceptions.dart';
import '../../../../core/config/app_config.dart';

/// Provider for managing authentication state
class AuthProvider extends ChangeNotifier {
  final AuthRepositoryImpl _repository;
  final AuthLocalSources _localDataSource;

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider(this._repository, this._localDataSource);

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  
  /// Expose AuthLocalSources for accessing tokens
  AuthLocalSources getAuthLocalSources() => _localDataSource;
  
  /// Expose SharedPreferences (for compatibility)
  Future<SharedPreferences> getSharedPreferences() async {
    return SharedPreferences.getInstance();
  }

  /// Factory constructor to initialize with SharedPreferences
  static Future<AuthProvider> create() async {
    final prefs = await SharedPreferences.getInstance();
    final localDataSource = AuthLocalSources(prefs);
    final apiDataSource = AuthApiSources(baseUrl: AppConfig.apiBaseUrl);
    final repository = AuthRepositoryImpl(localDataSource, apiDataSource);

    return AuthProvider(repository, localDataSource)..checkAuth();
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
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedUser = await _repository.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        birthDate: birthDate,
        club: club,
        clubId: clubId,
        licenceNumber: licenceNumber,
        ppsNumber: ppsNumber,
        chipNumber: chipNumber,
        profileImageUrl: profileImageUrl,
        streetNumber: streetNumber,
        streetName: streetName,
        postalCode: postalCode,
        city: city,
      );
      _currentUser = updatedUser;
    } catch (e) {
      _errorMessage = 'Erreur lors de la mise à jour du profil';
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
