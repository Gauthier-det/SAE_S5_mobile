import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/auth_local_sources.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/user_auth.dart';
import '../../domain/exceptions/auth_exceptions.dart';

/// Provider for managing authentication state
class AuthProvider extends ChangeNotifier {
  final AuthRepositoryImpl _repository;

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider(this._repository);

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  /// Factory constructor to initialize with SharedPreferences
  static Future<AuthProvider> create() async {
    final prefs = await SharedPreferences.getInstance();
    final localDataSource = AuthLocalSources(prefs);
    final repository = AuthRepositoryImpl(localDataSource);

    return AuthProvider(repository)..checkAuth();
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
  Future<void> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _repository.login(
        email: email,
        password: password,
      );
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
