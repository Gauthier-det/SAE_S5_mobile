import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/club.dart';

/// Provider for managing clubs
class ClubProvider extends ChangeNotifier {
  List<Club> _clubs = [];
  bool _isLoading = false;
  String? _errorMessage;

  static const String _clubsKey = 'clubs_data';

  List<Club> get clubs => _clubs;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ClubProvider() {
    _loadClubs();
  }

  /// Load clubs from local storage
  Future<void> _loadClubs() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final clubsJson = prefs.getString(_clubsKey);
      
      if (clubsJson != null) {
        final List<dynamic> decoded = json.decode(clubsJson);
        _clubs = decoded.map((item) => Club.fromJson(item)).toList();
      }
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des clubs';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Save clubs to local storage
  Future<void> _saveClubs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final clubsJson = json.encode(_clubs.map((c) => c.toJson()).toList());
      await prefs.setString(_clubsKey, clubsJson);
    } catch (e) {
      _errorMessage = 'Erreur lors de la sauvegarde des clubs';
    }
  }

  /// Create a new club
  Future<void> createClub({
    required String name,
    required String responsibleName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final club = Club(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        responsibleName: responsibleName,
        createdAt: DateTime.now(),
      );

      _clubs.add(club);
      await _saveClubs();
    } catch (e) {
      _errorMessage = 'Erreur lors de la création du club';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update an existing club
  Future<void> updateClub({
    required String id,
    String? name,
    String? responsibleName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final index = _clubs.indexWhere((c) => c.id == id);
      if (index != -1) {
        _clubs[index] = _clubs[index].copyWith(
          name: name,
          responsibleName: responsibleName,
        );
        await _saveClubs();
      }
    } catch (e) {
      _errorMessage = 'Erreur lors de la mise à jour du club';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete a club
  Future<void> deleteClub(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _clubs.removeWhere((c) => c.id == id);
      await _saveClubs();
    } catch (e) {
      _errorMessage = 'Erreur lors de la suppression du club';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get a club by ID
  Club? getClubById(String id) {
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
