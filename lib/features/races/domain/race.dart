/// Type de course
enum RaceType {
  competitive('Compétitif'),
  leisure('Rando/Loisirs');

  final String label;
  const RaceType(this.label);
}

/// Modèle de course d'orientation
class Race {
  final int id; // RAC_ID
  final int userId; // USE_ID
  final int raidId; // RAI_ID
  final DateTime startDate; // RAC_TIME_START
  final DateTime endDate; // RAC_TIME_END
  final String type; // RAC_TYPE
  final int duration; // RAC_DURATION (en minutes)
  final String difficulty; // RAC_DIFFICULTY
  final int minParticipants; // RAC_MIN_PARTICIPANTS
  final int maxParticipants; // RAC_MAX_PARTICIPANTS
  final int minTeams; // RAC_MIN_TEAMS
  final int maxTeams; // RAC_MAX_TEAMS
  final int teamMembers; // RAC_TEAM_MEMBERS
  final double? mealPrice; // RAC_MEAL_PRICE
  final String? results; // RAC_RESULTS
  final int ageMin; // RAC_AGE_MIN
  final int ageMiddle; // RAC_AGE_MIDDLE
  final int ageMax; // RAC_AGE_MAX

  Race({
    required this.id,
    required this.userId,
    required this.raidId,
    required this.startDate,
    required this.endDate,
    required this.type,
    required this.duration,
    required this.difficulty,
    required this.minParticipants,
    required this.maxParticipants,
    required this.minTeams,
    required this.maxTeams,
    required this.teamMembers,
    this.mealPrice,
    this.results,
    required this.ageMin,
    required this.ageMiddle,
    required this.ageMax,
  });

  /// Retourne la durée formatée en HH:mm
  String get formattedDuration {
    final hours = duration ~/ 60;
    final minutes = duration % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

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
      duration: json['RAC_DURATION'] as int? ?? 0,
      difficulty: json['RAC_DIFFICULTY'] as String? ?? '',
      minParticipants: json['RAC_MIN_PARTICIPANTS'] as int? ?? 0,
      maxParticipants: json['RAC_MAX_PARTICIPANTS'] as int? ?? 0,
      minTeams: json['RAC_MIN_TEAMS'] as int? ?? 0,
      maxTeams: json['RAC_MAX_TEAMS'] as int? ?? 0,
      teamMembers: json['RAC_TEAM_MEMBERS'] as int? ?? 0,
      mealPrice: json['RAC_MEAL_PRICE'] != null
          ? (json['RAC_MEAL_PRICE'] as num).toDouble()
          : null,
      results: json['RAC_RESULTS'] as String?,
      ageMin: json['RAC_AGE_MIN'] as int? ?? 0,
      ageMiddle: json['RAC_AGE_MIDDLE'] as int? ?? 0,
      ageMax: json['RAC_AGE_MAX'] as int? ?? 0,
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
      'RAC_DURATION': duration,
      'RAC_DIFFICULTY': difficulty,
      'RAC_MIN_PARTICIPANTS': minParticipants,
      'RAC_MAX_PARTICIPANTS': maxParticipants,
      'RAC_MIN_TEAMS': minTeams,
      'RAC_MAX_TEAMS': maxTeams,
      'RAC_TEAM_MEMBERS': teamMembers,
      'RAC_MEAL_PRICE': mealPrice,
      'RAC_RESULTS': results,
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
    int? duration,
    String? difficulty,
    int? minParticipants,
    int? maxParticipants,
    int? minTeams,
    int? maxTeams,
    int? teamMembers,
    double? mealPrice,
    String? results,
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
      duration: duration ?? this.duration,
      difficulty: difficulty ?? this.difficulty,
      minParticipants: minParticipants ?? this.minParticipants,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      minTeams: minTeams ?? this.minTeams,
      maxTeams: maxTeams ?? this.maxTeams,
      teamMembers: teamMembers ?? this.teamMembers,
      mealPrice: mealPrice ?? this.mealPrice,
      results: results ?? this.results,
      ageMin: ageMin ?? this.ageMin,
      ageMiddle: ageMiddle ?? this.ageMiddle,
      ageMax: ageMax ?? this.ageMax,
    );
  }
}
