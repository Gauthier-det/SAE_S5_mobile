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
  });

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
    );
  }
}
