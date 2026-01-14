// lib/features/race/domain/race.dart

/// Modèle de course d'orientation
class Race {
  final int id; // RAC_ID
  final int userId; // USE_ID
  final int raidId; // RAI_ID
  final DateTime startDate; // RAC_TIME_START
  final DateTime endDate; // RAC_TIME_END
  final String type; // RAC_TYPE
  final String difficulty; // RAC_DIFFICULTY
  final String sex; // RAC_SEX ← AJOUTE CE CHAMP
  final int minParticipants; // RAC_MIN_PARTICIPANTS
  final int maxParticipants; // RAC_MAX_PARTICIPANTS
  final int minTeams; // RAC_MIN_TEAMS
  final int maxTeams; // RAC_MAX_TEAMS
  final int teamMembers; // RAC_TEAM_MEMBERS
  final int? ageMin; // RAC_AGE_MIN (nullable)
  final int? ageMiddle; // RAC_AGE_MIDDLE (nullable)
  final int? ageMax; // RAC_AGE_MAX (nullable)

  Race({
    required this.id,
    required this.userId,
    required this.raidId,
    required this.startDate,
    required this.endDate,
    required this.type,
    required this.difficulty,
    required this.sex, // ← AJOUTE CE PARAMÈTRE
    required this.minParticipants,
    required this.maxParticipants,
    required this.minTeams,
    required this.maxTeams,
    required this.teamMembers,
    this.ageMin,
    this.ageMiddle,
    this.ageMax,
  });

  /// Retourne le label de difficulté
  String get difficultyLabel => difficulty;

  /// Conversion depuis JSON (API/Base de données)
  factory Race.fromJson(Map<String, dynamic> json) {
    return Race(
      id: json['RAC_ID'] as int? ?? 0,
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
      sex: json['RAC_SEX'] as String? ?? 'Mixte', // ← AJOUTE CE CHAMP
      minParticipants: json['RAC_MIN_PARTICIPANTS'] as int? ?? 0,
      maxParticipants: json['RAC_MAX_PARTICIPANTS'] as int? ?? 0,
      minTeams: json['RAC_MIN_TEAMS'] as int? ?? 0,
      maxTeams: json['RAC_MAX_TEAMS'] as int? ?? 0,
      teamMembers: json['RAC_TEAM_MEMBERS'] as int? ?? 0,
      ageMin: json['RAC_AGE_MIN'] as int?,
      ageMiddle: json['RAC_AGE_MIDDLE'] as int?,
      ageMax: json['RAC_AGE_MAX'] as int?,
    );
  }

  /// Conversion vers JSON (API/Base de données)
  Map<String, dynamic> toJson() {
    return {
      'RAC_ID': id,
      'USE_ID': userId,
      'RAI_ID': raidId,
      'RAC_TIME_START': startDate.toIso8601String(),
      'RAC_TIME_END': endDate.toIso8601String(),
      'RAC_TYPE': type,
      'RAC_DIFFICULTY': difficulty,
      'RAC_SEX': sex, // ← AJOUTE CE CHAMP
      'RAC_MIN_PARTICIPANTS': minParticipants,
      'RAC_MAX_PARTICIPANTS': maxParticipants,
      'RAC_MIN_TEAMS': minTeams,
      'RAC_MAX_TEAMS': maxTeams,
      'RAC_TEAM_MEMBERS': teamMembers,
      'RAC_AGE_MIN': ageMin,
      'RAC_AGE_MIDDLE': ageMiddle,
      'RAC_AGE_MAX': ageMax,
    };
  }

  /// Copie avec modifications
  Race copyWith({
    int? id,
    int? userId,
    int? raidId,
    DateTime? startDate,
    DateTime? endDate,
    String? type,
    String? difficulty,
    String? sex, // ← AJOUTE CE PARAMÈTRE
    int? minParticipants,
    int? maxParticipants,
    int? minTeams,
    int? maxTeams,
    int? teamMembers,
    int? ageMin,
    int? ageMiddle,
    int? ageMax,
  }) {
    return Race(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      raidId: raidId ?? this.raidId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      sex: sex ?? this.sex, // ← AJOUTE CE CHAMP
      minParticipants: minParticipants ?? this.minParticipants,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      minTeams: minTeams ?? this.minTeams,
      maxTeams: maxTeams ?? this.maxTeams,
      teamMembers: teamMembers ?? this.teamMembers,
      ageMin: ageMin ?? this.ageMin,
      ageMiddle: ageMiddle ?? this.ageMiddle,
      ageMax: ageMax ?? this.ageMax,
    );
  }
}
