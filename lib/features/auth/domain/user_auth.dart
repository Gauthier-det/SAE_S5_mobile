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
  final String? ppsNumber;
  final String? chipNumber;
  final DateTime createdAt;
  final List<int> roles;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.birthDate,
    this.phoneNumber,
    this.licenceNumber,
    this.club,
    this.ppsNumber,
    this.chipNumber,
    this.profileImageUrl,
    required this.createdAt,
    this.roles = const [],
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
    String? ppsNumber,
    String? chipNumber,
    String? profileImageUrl,
    DateTime? createdAt,
    List<int>? roles,
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
      ppsNumber: ppsNumber ?? this.ppsNumber,
      chipNumber: chipNumber ?? this.chipNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      roles: roles ?? this.roles,
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
      'ppsNumber': ppsNumber,
      'chipNumber': chipNumber,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.toIso8601String(),
      'roles': roles,
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
      ppsNumber: json['ppsNumber'] as String?,
      chipNumber: json['chipNumber'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      roles: (json['roles'] as List<dynamic>?)?.cast<int>() ?? [],
    );
  }
}
