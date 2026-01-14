// lib/features/categories/domain/category.dart

class Category {
  final int id;
  final String label;  // ← Changé de "name" à "label"
  final double? price;

  Category({
    required this.id,
    required this.label,  // ← Changé
    this.price,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['CAT_ID'] as int,
      label: json['CAT_LABEL'] as String,  // ← Changé de CAT_NAME à CAT_LABEL
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'CAT_ID': id,
      'CAT_LABEL': label,  // ← Changé
      if (price != null) 'price': price,
    };
  }

  String get name => label;
}
