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
  final String ageMiddle; // RAC_AGE_MIDDLE
  final String ageMax; // RAC_AGE_MAX

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
}
