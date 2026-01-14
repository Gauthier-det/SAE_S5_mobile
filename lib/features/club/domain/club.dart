/// Club entity representing a sports club
class Club {
  final int id;
  final String name;
  final String responsibleName;
  final int? responsibleId;
  final int? addressId;
  final DateTime createdAt;

  Club({
    required this.id,
    required this.name,
    required this.responsibleName,
    this.responsibleId,
    this.addressId,
    required this.createdAt,
  });

  /// Copy with method for immutability
  Club copyWith({
    int? id,
    String? name,
    String? responsibleName,
    int? responsibleId,
    int? addressId,
    DateTime? createdAt,
  }) {
    return Club(
      id: id ?? this.id,
      name: name ?? this.name,
      responsibleName: responsibleName ?? this.responsibleName,
      responsibleId: responsibleId ?? this.responsibleId,
      addressId: addressId ?? this.addressId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'CLU_ID': id,
      'CLU_NAME': name,
      'USE_ID': responsibleId,
      'ADD_ID': addressId,
    };
  }

  /// Create from database JSON (SQLite)
  factory Club.fromJson(Map<String, dynamic> json) {
    // Extraire le nom du responsable s'il est disponible via JOIN
    String responsibleName = 'Non assigné';
    if (json.containsKey('USE_NAME') && json.containsKey('USE_LAST_NAME')) {
      responsibleName = '${json['USE_NAME']} ${json['USE_LAST_NAME']}';
    }

    return Club(
      id: json['CLU_ID'] as int,
      name: json['CLU_NAME'] as String,
      responsibleName: responsibleName,
      responsibleId: json['USE_ID'] as int?,
      addressId: json['ADD_ID'] as int?,
      createdAt: DateTime.now(), // Pas de date dans la BDD actuelle
    );
  }
}
