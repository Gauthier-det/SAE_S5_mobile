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

  Map<String, dynamic> toApiJson() {
    return {
      'name': name, // Laravel attend 'name', pas 'TEA_NAME'
      if (image != null && image!.isNotEmpty) 'image': image,
      // Ne pas envoyer USE_ID ici, l'API le prend du token
    };
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
}
