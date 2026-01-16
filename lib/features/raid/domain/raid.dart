// lib/features/raids/domain/models/raid.dart
import '../../address/domain/address.dart';
import '../../club/domain/club.dart';
import '../../user/domain/user.dart';

/// Orienteering raid event entity.
///
/// Represents a multi-race event managed by a club. Handles dual JSON formats:
/// API responses (nested relations) and local DB (flat structure with JOINs)
/// [web:176][web:186][web:189].
///
/// **Status Properties:**
/// - [isInProgress]: Event currently running
/// - [isUpcoming]: Event not yet started
/// - [isFinished]: Event completed
/// - [isRegistrationOpen]: Registration period active
///
/// Example:
/// ```dart
/// final raid = Raid(
///   id: 1,
///   name: 'Trail des Pyrénées 2026',
///   timeStart: DateTime(2026, 6, 15),
///   timeEnd: DateTime(2026, 6, 17),
///   nbRaces: 3,
///   // ... other fields
/// );
/// 
/// if (raid.isRegistrationOpen) {
///   print('Registrations are open!');
/// }
/// ```
class Raid {
  final int id; // RAI_ID
  final int clubId; // CLU_ID
  final int addressId; // ADD_ID
  final int userId; // USE_ID (Manager)
  final String name; // RAI_NAME
  final String? email; // RAI_MAIL
  final String? phoneNumber; // RAI_PHONE_NUMBER
  final String? website; // RAI_WEB_SITE
  final String? image; // RAI_IMAGE
  final DateTime timeStart; // RAI_TIME_START
  final DateTime timeEnd; // RAI_TIME_END
  final DateTime registrationStart; // RAI_REGISTRATION_START
  final DateTime registrationEnd; // RAI_REGISTRATION_END
  final int nbRaces; // RAI_NB_RACES

  // Related entities (loaded via JOIN or nested API response)
  final Address? address;
  final Club? club;
  final User? manager;

  Raid({
    required this.id,
    required this.clubId,
    required this.addressId,
    required this.userId,
    required this.name,
    this.email,
    this.phoneNumber,
    this.website,
    this.image,
    required this.timeStart,
    required this.timeEnd,
    required this.registrationStart,
    required this.registrationEnd,
    this.address,
    this.club,
    this.manager,
    required this.nbRaces,
  });

  /// Creates Raid from JSON (API or local DB format).
  ///
  /// **API format:** Nested relations (`{club: {...}, address: {...}}`)
  /// **DB format:** Flat with JOIN prefixes (`MANAGER_NAME`, `ADD_POSTAL_CODE`)
  /// 
  /// Auto-detects format by checking for nested 'club' or 'address' keys [web:189].
  factory Raid.fromJson(Map<String, dynamic> json) {
    // Detect format: API (nested) vs local DB (flat)
    final bool isFromApi =
        json.containsKey('club') || json.containsKey('address');

    if (isFromApi) {
      // API format with nested relations
      Address? address;
      if (json['address'] != null) {
        try {
          address = Address.fromJson(json['address']);
        } catch (e) {
          address = null;
        }
      }

      Club? club;
      if (json['club'] != null) {
        try {
          club = Club.fromJson(json['club']);
        } catch (e) {
          club = null;
        }
      }

      User? manager;
      if (json['user'] != null) {
        try {
          manager = User.fromJson(json['user']);
        } catch (e) {
          manager = null;
        }
      }

      return Raid(
        id: json['RAI_ID'] ?? 0,
        clubId: json['CLU_ID'] ?? 0,
        addressId: json['ADD_ID'] ?? 0,
        userId: json['USE_ID'] ?? 0,
        name: json['RAI_NAME'] ?? '',
        email: json['RAI_MAIL'],
        phoneNumber: json['RAI_PHONE_NUMBER'],
        website: json['RAI_WEB_SITE'],
        image: json['RAI_IMAGE'],
        timeStart: DateTime.parse(json['RAI_TIME_START']),
        timeEnd: DateTime.parse(json['RAI_TIME_END']),
        registrationStart: DateTime.parse(json['RAI_REGISTRATION_START']),
        registrationEnd: DateTime.parse(json['RAI_REGISTRATION_END']),
        nbRaces: json['RAI_NB_RACES'] ?? 0,
        address: address,
        club: club,
        manager: manager,
      );
    } else {
      // Local DB format with JOIN prefixes
      Address? address;
      if (json.containsKey('ADD_POSTAL_CODE')) {
        address = Address.fromJson(json);
      }

      User? manager;
      if (json.containsKey('MANAGER_NAME') &&
          json['MANAGER_NAME'] != null &&
          json.containsKey('MANAGER_LAST_NAME') &&
          json['MANAGER_LAST_NAME'] != null) {
        final userMap = {
          'USE_ID': json['MANAGER_ID'],
          'ADD_ID': json['MANAGER_ADD_ID'] ?? 0,
          'CLU_ID': null,
          'USE_MAIL': json['MANAGER_MAIL'] ?? '',
          'USE_PASSWORD': '',
          'USE_NAME': json['MANAGER_NAME'],
          'USE_LAST_NAME': json['MANAGER_LAST_NAME'],
          'USE_BIRTHDATE': null,
          'USE_PHONE_NUMBER': null,
          'USE_LICENCE_NUMBER': null,
          'USE_MEMBERSHIP_DATE': null,
        };

        try {
          manager = User.fromJson(userMap);
        } catch (e) {
          manager = null;
        }
      }

      return Raid(
        id: json['RAI_ID'],
        clubId: json['CLU_ID'],
        addressId: json['ADD_ID'],
        userId: json['USE_ID'],
        name: json['RAI_NAME'],
        email: json['RAI_MAIL'],
        phoneNumber: json['RAI_PHONE_NUMBER'],
        website: json['RAI_WEB_SITE'],
        image: json['RAI_IMAGE'],
        timeStart: DateTime.parse(json['RAI_TIME_START']),
        timeEnd: DateTime.parse(json['RAI_TIME_END']),
        registrationStart: DateTime.parse(json['RAI_REGISTRATION_START']),
        registrationEnd: DateTime.parse(json['RAI_REGISTRATION_END']),
        address: address,
        manager: manager,
        nbRaces: json['RAI_NB_RACES'],
      );
    }
  }

  /// Converts to JSON for local database storage [web:186].
  Map<String, dynamic> toJson() {
    return {
      'RAI_ID': id,
      'CLU_ID': clubId,
      'ADD_ID': addressId,
      'USE_ID': userId,
      'RAI_NAME': name,
      'RAI_MAIL': email,
      'RAI_PHONE_NUMBER': phoneNumber,
      'RAI_WEB_SITE': website,
      'RAI_IMAGE': image,
      'RAI_TIME_START': timeStart.toIso8601String(),
      'RAI_TIME_END': timeEnd.toIso8601String(),
      'RAI_REGISTRATION_START': registrationStart.toIso8601String(),
      'RAI_REGISTRATION_END': registrationEnd.toIso8601String(),
      'RAI_NB_RACES': nbRaces,
    };
  }

  /// Converts to JSON for API requests (omits ID) [web:186].
  Map<String, dynamic> toApiJson() {
    return {
      'CLU_ID': clubId,
      'ADD_ID': addressId,
      'USE_ID': userId,
      'RAI_NAME': name,
      'RAI_MAIL': email,
      'RAI_PHONE_NUMBER': phoneNumber,
      'RAI_WEB_SITE': website,
      'RAI_IMAGE': image,
      'RAI_TIME_START': timeStart.toIso8601String(),
      'RAI_TIME_END': timeEnd.toIso8601String(),
      'RAI_REGISTRATION_START': registrationStart.toIso8601String(),
      'RAI_REGISTRATION_END': registrationEnd.toIso8601String(),
      'RAI_NB_RACES': nbRaces,
    };
  }

  /// Returns true if raid is currently happening.
  bool get isInProgress {
    final now = DateTime.now();
    return now.isAfter(timeStart) && now.isBefore(timeEnd);
  }

  /// Returns true if raid has not yet started.
  bool get isUpcoming => DateTime.now().isBefore(timeStart);

  /// Returns true if raid is finished.
  bool get isFinished => DateTime.now().isAfter(timeEnd);

  /// Returns true if registration period is currently open.
  bool get isRegistrationOpen {
    final now = DateTime.now();
    return now.isAfter(registrationStart) && now.isBefore(registrationEnd);
  }
}
