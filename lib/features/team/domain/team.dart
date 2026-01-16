// lib/features/teams/domain/team.dart

/// Domain entity representing a race team [web:177][web:176].
///
/// Handles dual-format serialization for API (snake_case) and DB 
/// (UPPERCASE_UNDERSCORE) interoperability. Supports validation state 
/// as both boolean and integer (0/1) [web:191][web:193].
///
/// **Serialization Methods:**
/// - `fromJson`: Parses both API and DB formats
/// - `toApiJson`: Converts to API format for HTTP requests
/// - `toJson`: Converts to DB format for local storage
///
/// Example:
/// ```dart
/// // From API response
/// final team = Team.fromJson({'id': 1, 'name': 'Team A', 'is_valid': true});
/// 
/// // From DB query
/// final team = Team.fromJson({'TEA_ID': 1, 'TEA_NAME': 'Team A', 'TER_IS_VALID': 1});
/// 
/// // Send to API
/// final apiPayload = team.toApiJson();
/// 
/// // Save to DB
/// await db.insert('SAN_TEAMS', team.toJson());
/// ```
class Team {
  final int id;
  final int managerId;
  final String name;
  final String? image;
  final bool? isValid; // Validation status from SAN_TEAMS_RACES.TER_IS_VALID

  Team({
    required this.id,
    required this.managerId,
    required this.name,
    this.image,
    this.isValid,
  });

  /// Creates Team from JSON (supports API and DB formats) [web:191].
  ///
  /// Normalizes:
  /// - API: id, manager_id, name, image, is_valid (boolean)
  /// - DB: TEA_ID, USE_ID, TEA_NAME, TEA_IMAGE, TER_IS_VALID (int 0/1)
  factory Team.fromJson(Map<String, dynamic> json) {
    final isValidVal = json['TER_IS_VALID'] ?? json['is_valid'];
    final bool isValid = isValidVal == 1 || isValidVal == true;

    return Team(
      id: (json['TEA_ID'] ?? json['id'] ?? 0) as int,
      managerId: (json['USE_ID'] ?? json['manager_id'] ?? 0) as int,
      name: (json['TEA_NAME'] ?? json['name'] ?? '') as String,
      image: (json['TEA_IMAGE'] ?? json['image']) as String?,
      isValid: isValid,
    );
  }

  /// Converts to API format for HTTP requests [web:193].
  ///
  /// Omits manager_id (inferred from auth token on backend).
  Map<String, dynamic> toApiJson() {
    return {
      'name': name,
      if (image != null && image!.isNotEmpty) 'image': image,
    };
  }

  /// Converts to DB format for local storage [web:191][web:176].
  ///
  /// Uses UPPERCASE_UNDERSCORE column names matching SAN_TEAMS schema.
  /// Excludes null fields to prevent unnecessary DB updates.
  Map<String, dynamic> toJson() {
    return {
      'TEA_ID': id,
      'USE_ID': managerId,
      'TEA_NAME': name,
      if (image != null) 'TEA_IMAGE': image,
      if (isValid != null) 'TER_IS_VALID': isValid! ? 1 : 0,
    };
  }
}
