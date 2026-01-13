/// Club entity representing a sports club
class Club {
  final String id;
  final String name;
  final String responsibleName;
  final DateTime createdAt;

  Club({
    required this.id,
    required this.name,
    required this.responsibleName,
    required this.createdAt,
  });

  /// Copy with method for immutability
  Club copyWith({
    String? id,
    String? name,
    String? responsibleName,
    DateTime? createdAt,
  }) {
    return Club(
      id: id ?? this.id,
      name: name ?? this.name,
      responsibleName: responsibleName ?? this.responsibleName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'responsibleName': responsibleName,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory Club.fromJson(Map<String, dynamic> json) {
    return Club(
      id: json['id'] as String,
      name: json['name'] as String,
      responsibleName: json['responsibleName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
