// lib/features/teams/domain/team.dart
class Team {
  final int id;
  final int managerId;
  final String name;
  final String? image;
  final bool? isValid; // Pour TER_IS_VALID

  Team({
    required this.id,
    required this.managerId,
    required this.name,
    this.image,
    this.isValid,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['TEA_ID'] as int,
      managerId: json['USE_ID'] as int,
      name: json['TEA_NAME'] as String,
      image: json['TEA_IMAGE'] as String?,
      isValid: json['TER_IS_VALID'] != null 
          ? (json['TER_IS_VALID'] as int) == 1 
          : null,
    );
  }
}
