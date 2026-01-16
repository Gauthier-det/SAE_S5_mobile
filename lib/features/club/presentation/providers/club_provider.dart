import 'package:flutter/foundation.dart';
import '../../domain/club_repository.dart';
import '../../domain/club.dart';

/// Provider for managing clubs
class ClubProvider extends ChangeNotifier {
  List<Club> _clubs = [];
  bool _isLoading = false;
  String? _errorMessage;

  final ClubRepository _repository;

  List<Club> get clubs => _clubs;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ClubProvider({required ClubRepository repository})
    : _repository = repository {
    loadClubs();
  }

  /// Load clubs from API (with local fallback)
  Future<void> loadClubs() async {
    _isLoading = true;
    notifyListeners();

    try {
      _clubs = await _repository.getAllClubs();
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des clubs: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh clubs from database
  Future<void> refreshClubs() async {
    await loadClubs();
  }

  /// Create a new club
  Future<Club> createClub({
    required String name,
    required int responsibleId,
    required int addressId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newClub = await _repository.createClub(
        name: name,
        responsibleId: responsibleId,
        addressId: addressId,
      );

      // Recharger la liste
      await loadClubs();

      return newClub;
    } catch (e) {
      _errorMessage = 'Erreur lors de la création du club: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update an existing club
  Future<void> updateClub({required int id, String? name}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.updateClub(id: id, name: name);
      await loadClubs();
    } catch (e) {
      _errorMessage = 'Erreur lors de la mise à jour du club: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete a club
  Future<void> deleteClub(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteClub(id);
      await loadClubs();
    } catch (e) {
      _errorMessage = 'Erreur lors de la suppression du club: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get a club by ID
  Club? getClubById(int id) {
    try {
      return _clubs.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
