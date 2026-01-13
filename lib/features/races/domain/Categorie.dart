// lib/features/raids/domain/models/category.dart

/// Represents a participant category
/// Corresponds to SAN_CATEGORIES table
/// Categories: Mineur, Majeur non licencié, Licensié
class Category {
  final int id;
  final String label;

  Category({
    required this.id,
    required this.label,
  });

  /// Creates Category from database JSON
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['CAT_ID'],
      label: json['CAT_LABEL'],
    );
  }

  /// Converts Category to JSON for database storage
  Map<String, dynamic> toJson() {
    return {
      'CAT_ID': id,
      'CAT_LABEL': label,
    };
  }
}
