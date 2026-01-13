// lib/features/raids/domain/models/role.dart

/// Represents a user role in the system
/// Corresponds to SAN_ROLES table
/// Roles: Coureur, Gestionnaire de site, Responsable de club, 
///        Responsable de raid, Responsable de course
class Role {
  final int id;
  final String name;

  Role({
    required this.id,
    required this.name,
  });

  /// Creates Role from database JSON
  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['ROL_ID'],
      name: json['ROL_NAME'],
    );
  }

  /// Converts Role to JSON for database storage
  Map<String, dynamic> toJson() {
    return {
      'ROL_ID': id,
      'ROL_NAME': name,
    };
  }

  /// Role IDs constants for easy reference
  static const int runner = 1;
  static const int siteManager = 2;
  static const int clubManager = 3;
  static const int raidManager = 4;
  static const int raceManager = 5;
}