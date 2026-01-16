// lib/features/categories/domain/category.dart

/// Age category domain entity.
///
/// Represents an age/participant category for race registration in the orienteering
/// event system. Categories define participant classifications (e.g., Minor, Adult,
/// Licensed) with optional pricing information [web:173][web:176][web:179].
///
/// ## Domain Layer Responsibility
///
/// As a domain entity, this class belongs to the domain layer and contains pure
/// business logic without dependencies on external frameworks or data sources
/// [web:176][web:179][web:182]. It represents the core business concept of a
/// "category" independent of how data is stored or transmitted.
///
/// ## Entity vs Model
///
/// In Clean Architecture, entities (domain layer) are distinguished from models
/// (data layer) [web:174][web:176]:
/// - **Entity (this class)**: Business logic representation used by use cases
/// - **Model**: Data transfer objects (DTOs) for API/database communication
/// - **Conversion**: Repositories handle conversion between models and entities [web:176]
///
/// ## Immutability
///
/// This entity is immutable (all fields are final), following Flutter best practices
/// for domain entities [web:177][web:180]. Immutability provides:
/// - Thread safety
/// - Predictable state management
/// - Easier testing and debugging
///
/// ## Category Types
///
/// The system defines three fixed categories matching the backend seeder:
/// - **ID 1**: "Mineur" (Minor, under 18 years old)
/// - **ID 2**: "Majeur non licencié" (Adult without orienteering license)
/// - **ID 3**: "Licencié" (Licensed orienteering athlete)
///
/// ## Price Field
///
/// The [price] field is optional and context-dependent:
/// - When fetching from repository: `null` (use [getRaceCategoryPrices] for pricing)
/// - When displaying race-specific pricing: Contains price in cents (e.g., 2500 = €25.00)
/// - When creating races: Not used (prices passed separately as map)
///
/// Example usage:
/// ```dart
/// // Fixed category definition
/// final category = Category(
///   id: 1,
///   label: 'Mineur',
/// );
///
/// // Category with race-specific price
/// final categoryWithPrice = Category(
///   id: 2,
///   label: 'Majeur non licencié',
///   price: 25.00, // €25.00
/// );
///
/// // Display category
/// print('${category.name}: ${category.id}');
/// ```
class Category {
  /// Unique category identifier.
  ///
  /// Corresponds to the CAT_ID field in the database. Fixed values:
  /// - 1: Mineur (Minor)
  /// - 2: Majeur non licencié (Adult without license)
  /// - 3: Licencié (Licensed athlete)
  final int id;

  /// Category label/name.
  ///
  /// Human-readable category name displayed in the UI. Corresponds to the
  /// CAT_LABEL field in the database (previously CAT_NAME in older schemas).
  ///
  /// Examples: "Mineur", "Majeur non licencié", "Licencié"
  final String label;

  /// Optional price for this category in euros.
  ///
  /// Context-dependent field:
  /// - **From repository**: Usually `null` (pricing fetched separately)
  /// - **Race-specific display**: Contains the price for a specific race
  /// - **Registration flow**: Used to display applicable pricing
  ///
  /// When present, represents the price in decimal euros (e.g., 25.00).
  /// Backend stores prices in cents; conversion happens in repository layer.
  final double? price;

  /// Creates a [Category] instance.
  ///
  /// The [id] and [label] are required as they identify the category.
  /// The [price] is optional and context-dependent.
  ///
  /// **Parameters:**
  /// - [id]: Unique category identifier (1-3)
  /// - [label]: Human-readable category name
  /// - [price]: Optional price in euros (e.g., 25.00 for €25)
  Category({
    required this.id,
    required this.label,
    this.price,
  });

  /// Creates a [Category] from JSON data.
  ///
  /// Factory constructor for JSON deserialization, typically used when parsing
  /// API responses or database query results [web:178][web:181]. Follows Flutter
  /// best practices for JSON serialization with `fromJson` pattern [web:178][web:181].
  ///
  /// **Expected JSON Structure:**
  /// ```json
  /// {
  ///   "CAT_ID": 1,
  ///   "CAT_LABEL": "Mineur",
  ///   "price": 20.00  // Optional, in euros
  /// }
  /// ```
  ///
  /// **Parameters:**
  /// - [json]: Map containing category data with keys matching database columns
  ///
  /// **Returns:** A new [Category] instance populated with JSON data
  ///
  /// **Null Safety:**
  /// The [price] field is nullable and safely handles missing data [web:178][web:181].
  ///
  /// **Example:**
  /// ```dart
  /// final json = {
  ///   'CAT_ID': 1,
  ///   'CAT_LABEL': 'Mineur',
  ///   'price': 20.00,
  /// };
  /// final category = Category.fromJson(json);
  /// print('${category.name}: €${category.price?.toStringAsFixed(2) ?? 'N/A'}');
  /// // Output: Mineur: €20.00
  /// ```
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['CAT_ID'] as int,
      label: json['CAT_LABEL'] as String,
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
    );
  }

  /// Converts this [Category] to JSON format.
  ///
  /// Serialization method for converting the entity to a JSON-compatible map,
  /// typically used when sending data to APIs or storing in database [web:178][web:181].
  /// Follows Flutter best practices for JSON serialization with `toJson` pattern [web:178].
  ///
  /// **Output Structure:**
  /// ```json
  /// {
  ///   "CAT_ID": 1,
  ///   "CAT_LABEL": "Mineur",
  ///   "price": 20.00  // Only included if not null
  /// }
  /// ```
  ///
  /// **Returns:** A map with database column names as keys
  ///
  /// **Conditional Serialization:**
  /// The [price] field is only included in the output if it's not null [web:181],
  /// keeping the JSON clean and avoiding unnecessary null values.
  ///
  /// **Example:**
  /// ```dart
  /// final category = Category(id: 1, label: 'Mineur', price: 20.00);
  /// final json = category.toJson();
  /// print(json);
  /// // Output: {CAT_ID: 1, CAT_LABEL: Mineur, price: 20.0}
  ///
  /// final categoryNoPrice = Category(id: 2, label: 'Majeur non licencié');
  /// print(categoryNoPrice.toJson());
  /// // Output: {CAT_ID: 2, CAT_LABEL: Majeur non licencié}
  /// ```
  Map<String, dynamic> toJson() {
    return {
      'CAT_ID': id,
      'CAT_LABEL': label,
      if (price != null) 'price': price,
    };
  }

  /// Alias getter for [label].
  ///
  /// Provides backwards compatibility and improved readability by offering
  /// a [name] accessor that delegates to [label]. This is useful when
  /// migrating from older code that expected a `name` field.
  ///
  /// **Returns:** The category label/name
  ///
  /// **Example:**
  /// ```dart
  /// final category = Category(id: 1, label: 'Mineur');
  /// print(category.name);   // Output: Mineur
  /// print(category.label);  // Output: Mineur (same value)
  /// ```
  String get name => label;
}
