// lib/features/raids/domain/models/user.dart
import '../../../features/address/domain/address.dart';
import '../../../features/club/domain/club.dart';
import 'role.dart';

/// Represents a user in the system
/// Corresponds to SAN_USERS table
class User {
  final int id;
  final int addressId;
  final int? clubId;
  final String email;
  final String? password;
  final String name;
  final String lastName;
  final DateTime? birthdate;
  final int? phoneNumber;
  final int? licenceNumber;
  final String? ppsForm;
  final DateTime? membershipDate;

  // Related objects (loaded via JOIN)
  final Address? address;
  final Club? club;
  final List<Role>? roles;

  User({
    required this.id,
    required this.addressId,
    this.clubId,
    required this.email,
    this.password,
    required this.name,
    required this.lastName,
    this.birthdate,
    this.phoneNumber,
    this.licenceNumber,
    this.ppsForm,
    this.membershipDate,
    this.address,
    this.club,
    this.roles,
  });

  /// Creates User from database JSON
  factory User.fromJson(Map<String, dynamic> json) {
    // Parse address if present in JOIN
    Address? address;
    if (json.containsKey('ADD_POSTAL_CODE')) {
      address = Address.fromJson(json);
    }

    // Parse birthdate
    DateTime? birthdate;
    if (json['USE_BIRTHDATE'] != null) {
      birthdate = DateTime.parse(json['USE_BIRTHDATE']);
    }

    // Parse membership date
    DateTime? membershipDate;
    if (json['USE_MEMBERSHIP_DATE'] != null) {
      membershipDate = DateTime.parse(json['USE_MEMBERSHIP_DATE']);
    }

    return User(
      id: json['USE_ID'],
      addressId: json['ADD_ID'],
      clubId: json['CLU_ID'],
      email: json['USE_MAIL'],
      password: json['USE_PASSWORD'],
      name: json['USE_NAME'],
      lastName: json['USE_LAST_NAME'],
      birthdate: birthdate,
      phoneNumber: json['USE_PHONE_NUMBER'],
      licenceNumber: json['USE_LICENCE_NUMBER'],
      membershipDate: membershipDate,
      address: address,
    );
  }

  /// Converts User to JSON for database storage
  Map<String, dynamic> toJson() {
    return {
      'USE_ID': id,
      'ADD_ID': addressId,
      'CLU_ID': clubId,
      'USE_MAIL': email,
      'USE_PASSWORD': password,
      'USE_NAME': name,
      'USE_LAST_NAME': lastName,
      'USE_BIRTHDATE': birthdate?.toIso8601String(),
      'USE_PHONE_NUMBER': phoneNumber,
      'USE_LICENCE_NUMBER': licenceNumber,
      'USE_MEMBERSHIP_DATE': membershipDate?.toIso8601String(),
    };
  }

  /// Returns full name formatted as "Prénom NOM"
  String get fullName => '$name ${lastName.toUpperCase()}';

  /// Returns initials (e.g., "JD" for John Doe)
  String get initials => '${name[0]}${lastName[0]}'.toUpperCase();

  /// Checks if user has a specific role
  bool hasRole(int roleId) {
    return roles?.any((role) => role.id == roleId) ?? false;
  }

  /// Checks if user is a runner
  bool get isRunner => hasRole(Role.runner);

  /// Checks if user is a site manager
  bool get isSiteManager => hasRole(Role.siteManager);

  /// Checks if user is a club manager
  bool get isClubManager => hasRole(Role.clubManager);

  /// Checks if user is a raid manager
  bool get isRaidManager => hasRole(Role.raidManager);

  /// Checks if user is a race manager
  bool get isRaceManager => hasRole(Role.raceManager);
}