/// User entity representing an authenticated user
class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? profileImageUrl;
  final String? birthDate;
  final String? phoneNumber;
  final String? licenceNumber;
  final String? club;
  final int? clubId;
  final String? ppsNumber;
  final String? chipNumber;
  final DateTime createdAt;
  final List<int> roles;
  
  // Address fields
  final String? streetNumber;
  final String? streetName;
  final String? postalCode;
  final String? city;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.birthDate,
    this.phoneNumber,
    this.licenceNumber,
    this.club,
    this.clubId,
    this.ppsNumber,
    this.chipNumber,
    this.profileImageUrl,
    required this.createdAt,
    this.roles = const [],
    this.streetNumber,
    this.streetName,
    this.postalCode,
    this.city,
  });

  /// Role constants
  static const int roleRunner = 1;
  static const int roleSiteManager = 2;
  static const int roleClubManager = 3;
  static const int roleRaidManager = 4;
  static const int roleRaceManager = 5;

  /// Check if user is a site manager (admin)
  bool get isSiteManager => roles.contains(roleSiteManager);

  /// Full name of the user
  String get fullName => '$firstName $lastName';
  
  /// Full address formatted
  String? get fullAddress {
    if (streetNumber == null && streetName == null && postalCode == null && city == null) {
      return null;
    }
    final parts = <String>[];
    if (streetNumber != null && streetNumber!.isNotEmpty) parts.add(streetNumber!);
    if (streetName != null && streetName!.isNotEmpty) parts.add(streetName!);
    final street = parts.join(' ');
    final cityParts = <String>[];
    if (postalCode != null && postalCode!.isNotEmpty) cityParts.add(postalCode!);
    if (city != null && city!.isNotEmpty) cityParts.add(city!);
    final cityLine = cityParts.join(' ');
    if (street.isNotEmpty && cityLine.isNotEmpty) return '$street, $cityLine';
    if (street.isNotEmpty) return street;
    if (cityLine.isNotEmpty) return cityLine;
    return null;
  }

  /// Copy with method for immutability
  User copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? birthDate,
    String? phoneNumber,
    String? licenceNumber,
    String? club,
    int? clubId,
    String? ppsNumber,
    String? chipNumber,
    String? profileImageUrl,
    DateTime? createdAt,
    List<int>? roles,
    String? streetNumber,
    String? streetName,
    String? postalCode,
    String? city,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      birthDate: birthDate ?? this.birthDate,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      licenceNumber: licenceNumber ?? this.licenceNumber,
      club: club ?? this.club,
      clubId: clubId ?? this.clubId,
      ppsNumber: ppsNumber ?? this.ppsNumber,
      chipNumber: chipNumber ?? this.chipNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      roles: roles ?? this.roles,
      streetNumber: streetNumber ?? this.streetNumber,
      streetName: streetName ?? this.streetName,
      postalCode: postalCode ?? this.postalCode,
      city: city ?? this.city,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'birthDate': birthDate,
      'phoneNumber': phoneNumber,
      'licenceNumber': licenceNumber,
      'club': club,
      'clubId': clubId,
      'ppsNumber': ppsNumber,
      'chipNumber': chipNumber,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.toIso8601String(),
      'roles': roles,
      'streetNumber': streetNumber,
      'streetName': streetName,
      'postalCode': postalCode,
      'city': city,
    };
  }

  /// Create from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      birthDate: json['birthDate'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      licenceNumber: json['licenceNumber'] as String?,
      club: json['club'] as String?,
      clubId: json['clubId'] as int?,
      ppsNumber: json['ppsNumber'] as String?,
      chipNumber: json['chipNumber'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      roles: (json['roles'] as List<dynamic>?)?.cast<int>() ?? [],
      streetNumber: json['streetNumber'] as String?,
      streetName: json['streetName'] as String?,
      postalCode: json['postalCode'] as String?,
      city: json['city'] as String?,
    );
  }
}
