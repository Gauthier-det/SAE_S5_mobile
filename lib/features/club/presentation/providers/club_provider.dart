import 'package:flutter/foundation.dart';
import '../../data/datasources/club_local_sources.dart';
import '../../domain/club.dart';
import '../../../../core/database/database_helper.dart';

/// Provider for managing clubs
class ClubProvider extends ChangeNotifier {
  List<Club> _clubs = [];
  bool _isLoading = false;
  String? _errorMessage;

  final ClubLocalSources _localSources = ClubLocalSources();

  List<Club> get clubs => _clubs;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ClubProvider() {
    loadClubs();
  }

  /// Load clubs from SQLite database
  Future<void> loadClubs() async {
    _isLoading = true;
    notifyListeners();

    try {
      _clubs = await _localSources.getAllClubs();
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des clubs: $e';
      debugPrint('Error loading clubs: $e');
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
  Future<void> createClub({
    required String name,
    required int responsibleId,
    required int addressId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final db = await DatabaseHelper.database;
      
      // Récupérer le prochain ID
      final result = await db.rawQuery('SELECT MAX(CLU_ID) as maxId FROM SAN_CLUBS');
      final maxId = (result.first['maxId'] as int?) ?? 0;
      final newId = maxId + 1;

      await db.insert('SAN_CLUBS', {
        'CLU_ID': newId,
        'USE_ID': responsibleId,
        'ADD_ID': addressId,
        'CLU_NAME': name,
      });

      // Recharger la liste
      await loadClubs();
    } catch (e) {
      _errorMessage = 'Erreur lors de la création du club: $e';
      debugPrint('Error creating club: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update an existing club
  Future<void> updateClub({
    required int id,
    String? name,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final db = await DatabaseHelper.database;
      
      final updateData = <String, dynamic>{};
      if (name != null) updateData['CLU_NAME'] = name;
      
      if (updateData.isNotEmpty) {
        await db.update(
          'SAN_CLUBS',
          updateData,
          where: 'CLU_ID = ?',
          whereArgs: [id],
        );
        await loadClubs();
      }
    } catch (e) {
      _errorMessage = 'Erreur lors de la mise à jour du club';
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
      final db = await DatabaseHelper.database;
      await db.delete(
        'SAN_CLUBS',
        where: 'CLU_ID = ?',
        whereArgs: [id],
      );
      await loadClubs();
    } catch (e) {
      _errorMessage = 'Erreur lors de la suppression du club';
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
