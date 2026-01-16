// lib/features/race/domain/race.dart

/// Race domain entity.
///
/// Represents an orienteering race within a raid event. This immutable entity
/// belongs to the domain layer and contains business logic independent of data
/// sources [web:176][web:184][web:187].
///
/// All fields are final for immutability [web:177][web:184]. To modify, use
/// [copyWith] to create a new instance [web:185][web:188].
///
/// Example:
/// ```dart
/// final race = Race(
///   id: 1,
///   name: 'Trail 10km',
///   type: 'Compétitif',
///   sex: 'Mixte',
///   // ... other fields
/// );
/// ```
class Race {
  final int id; // RAC_ID
  final String name; // RAC_NAME
  final int userId; // USE_ID - Race manager/creator
  final int raidId; // RAI_ID - Parent raid event
  final DateTime startDate; // RAC_TIME_START
  final DateTime endDate; // RAC_TIME_END
  final String type; // RAC_TYPE ('Compétitif' or 'Loisir')
  final String difficulty; // RAC_DIFFICULTY
  final String sex; // RAC_GENDER ('Homme', 'Femme', 'Mixte')
  final int minParticipants; // RAC_MIN_PARTICIPANTS
  final int maxParticipants; // RAC_MAX_PARTICIPANTS
  final int minTeams; // RAC_MIN_TEAMS
  final int maxTeams; // RAC_MAX_TEAMS
  final int minTeamMembers; // RAC_MIN_TEAM_MEMBERS
  final int teamMembers; // RAC_MAX_TEAM_MEMBERS
  final int ageMin; // RAC_AGE_MIN
  final int ageMiddle; // RAC_AGE_MIDDLE
  final int ageMax; // RAC_AGE_MAX
  final int chipMandatory; // RAC_CHIP_MANDATORY (0 or 1)

  Race({
    required this.id,
    required this.name,
    required this.userId,
    required this.raidId,
    required this.startDate,
    required this.endDate,
    required this.type,
    required this.difficulty,
    required this.sex,
    required this.minParticipants,
    required this.maxParticipants,
    required this.minTeams,
    required this.maxTeams,
    required this.minTeamMembers,
    required this.teamMembers,
    required this.ageMin,
    required this.ageMiddle,
    required this.ageMax,
    required this.chipMandatory,
  });

  /// Returns the difficulty label.
  String get difficultyLabel => difficulty;

  /// Creates a Race from JSON (API/database).
  ///
  /// Handles DateTime parsing and provides safe defaults for missing fields [web:186][web:189].
  /// Supports both 'RAC_GENDER' field names for compatibility.
  factory Race.fromJson(Map<String, dynamic> json) {
    return Race(
      id: json['RAC_ID'] as int? ?? 0,
      name: json['RAC_NAME'] as String? ?? 'Nouvelle Course',
      userId: json['USE_ID'] as int? ?? 0,
      raidId: json['RAI_ID'] as int? ?? 0,
      startDate: json['RAC_TIME_START'] != null
          ? DateTime.parse(json['RAC_TIME_START'] as String)
          : DateTime.now(),
      endDate: json['RAC_TIME_END'] != null
          ? DateTime.parse(json['RAC_TIME_END'] as String)
          : DateTime.now(),
      type: json['RAC_TYPE'] as String? ?? '',
      difficulty: json['RAC_DIFFICULTY'] as String? ?? '',
      sex: (json['RAC_GENDER'] ?? json['RAC_GENDER']) as String? ?? 'Mixte',
      minParticipants: json['RAC_MIN_PARTICIPANTS'] as int? ?? 0,
      maxParticipants: json['RAC_MAX_PARTICIPANTS'] as int? ?? 0,
      minTeams: json['RAC_MIN_TEAMS'] as int? ?? 0,
      maxTeams: json['RAC_MAX_TEAMS'] as int? ?? 0,
      minTeamMembers: json['RAC_MIN_TEAM_MEMBERS'] as int? ?? 2,
      teamMembers: json['RAC_MAX_TEAM_MEMBERS'] as int? ?? 0,
      ageMin: json['RAC_AGE_MIN'] as int,
      ageMiddle: json['RAC_AGE_MIDDLE'] as int,
      ageMax: json['RAC_AGE_MAX'] as int,
      chipMandatory: json['RAC_CHIP_MANDATORY'] as int? ?? 0,
    );
  }

  /// Converts this Race to JSON (API/database).
  ///
  /// Formats DateTime as 'YYYY-MM-DD HH:MM:SS' for database compatibility [web:186].
  Map<String, dynamic> toJson() {
    return {
      'RAC_ID': id,
      'RAC_NAME': name,
      'USE_ID': userId,
      'RAI_ID': raidId,
      'RAC_TIME_START':
          "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')} ${startDate.hour.toString().padLeft(2, '0')}:${startDate.minute.toString().padLeft(2, '0')}:${startDate.second.toString().padLeft(2, '0')}",
      'RAC_TIME_END':
          "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')} ${endDate.hour.toString().padLeft(2, '0')}:${endDate.minute.toString().padLeft(2, '0')}:${endDate.second.toString().padLeft(2, '0')}",
      'RAC_TYPE': type,
      'RAC_DIFFICULTY': difficulty,
      'RAC_GENDER': sex,
      'RAC_MIN_PARTICIPANTS': minParticipants,
      'RAC_MAX_PARTICIPANTS': maxParticipants,
      'RAC_MIN_TEAMS': minTeams,
      'RAC_MAX_TEAMS': maxTeams,
      'RAC_MIN_TEAM_MEMBERS': minTeamMembers,
      'RAC_MAX_TEAM_MEMBERS': teamMembers,
      'RAC_AGE_MIN': ageMin,
      'RAC_AGE_MIDDLE': ageMiddle,
      'RAC_AGE_MAX': ageMax,
      'RAC_CHIP_MANDATORY': chipMandatory,
    };
  }

  /// Creates a copy with modified fields.
  ///
  /// Returns a new Race instance with specified fields updated while keeping
  /// others unchanged [web:185][web:188]. Essential for immutable state management.
  ///
  /// Example:
  /// ```dart
  /// final updated = race.copyWith(
  ///   name: 'Trail 15km',
  ///   maxParticipants: 100,
  /// );
  /// ```
  Race copyWith({
    int? id,
    String? name,
    int? userId,
    int? raidId,
    DateTime? startDate,
    DateTime? endDate,
    String? type,
    String? difficulty,
    String? sex,
    int? minParticipants,
    int? maxParticipants,
    int? minTeams,
    int? maxTeams,
    int? minTeamMembers,
    int? teamMembers,
    int? ageMin,
    int? ageMiddle,
    int? ageMax,
    int? chipMandatory,
  }) {
    return Race(
      id: id ?? this.id,
      name: name ?? this.name,
      userId: userId ?? this.userId,
      raidId: raidId ?? this.raidId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      sex: sex ?? this.sex,
      minParticipants: minParticipants ?? this.minParticipants,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      minTeams: minTeams ?? this.minTeams,
      maxTeams: maxTeams ?? this.maxTeams,
      minTeamMembers: minTeamMembers ?? this.minTeamMembers,
      teamMembers: teamMembers ?? this.teamMembers,
      ageMin: ageMin ?? this.ageMin,
      ageMiddle: ageMiddle ?? this.ageMiddle,
      ageMax: ageMax ?? this.ageMax,
      chipMandatory: chipMandatory ?? this.chipMandatory,
    );
  }
}
