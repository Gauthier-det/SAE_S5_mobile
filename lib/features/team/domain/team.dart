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

  /// Convertit l'instance Team en Map pour JSON (envoi API)
  Map<String, dynamic> toJson() {
    return {
      'TEA_ID': id,
      'USE_ID': managerId,
      'TEA_NAME': name,
      // N'inclure TEA_IMAGE que si non-null (collection-if)
      if (image != null) 'TEA_IMAGE': image,
      // N'inclure TER_IS_VALID que si non-null
      if (isValid != null) 'TER_IS_VALID': isValid! ? 1 : 0,
    };
  }

  /// Version alternative sans TER_IS_VALID (pour création de team seule)
  Map<String, dynamic> toApiJson() {
    return {
      'TEA_ID': id,
      'USE_ID': managerId,
      'TEA_NAME': name,
      if (image != null) 'TEA_IMAGE': image,
    };
  }
}
