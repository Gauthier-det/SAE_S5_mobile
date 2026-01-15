// lib/features/raids/domain/models/raid.dart
import '../../address/domain/address.dart';
import '../../club/domain/club.dart';
import '../../user/domain/user.dart';

/// Represents an orienteering raid event
/// Corresponds to SAN_RAIDS table
class Raid {
  final int id;
  final int clubId;
  final int addressId;
  final int userId; // Manager ID
  final String name;
  final String? email;
  final String? phoneNumber;
  final String? website;
  final String? image;
  final DateTime timeStart;
  final DateTime timeEnd;
  final DateTime registrationStart;
  final DateTime registrationEnd;
  final int nbRaces;

  // Related objects (loaded via JOIN)
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

  /// Creates Raid from database JSON
  // lib/features/raids/domain/models/raid.dart

  /// Creates Raid from database JSON
  // lib/features/raids/domain/raid.dart

  /// Creates Raid from API JSON (with relations and RAI_NB_RACES)
  factory Raid.fromJson(Map<String, dynamic> json) {
    // Détecte si c'est un format API (avec relations imbriquées) ou DB locale
    final bool isFromApi =
        json.containsKey('club') || json.containsKey('address');

    if (isFromApi) {
      // Format API avec relations imbriquées
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
        nbRaces: json['RAI_NB_RACES'] ?? 0, // API utilise RAI_NB_RACES
        address: address,
        club: club,
        manager: manager,
      );
    } else {
      // Format DB locale
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
        nbRaces: json['RAI_NB_RACES'], // DB locale utilise RAI_NB_RACES
      );
    }
  }

  /// Converts Raid to JSON for database storage
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
      'RAI_NB_RACES': nbRaces, // Ajout du champ requis pour la DB locale
    };
  }

  /// Converts Raid to JSON for API requests
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
      'RAI_NB_RACES': nbRaces, // API utilise RAI_NB_RACES
    };
  }

  /// Checks if raid is currently happening
  bool get isInProgress {
    final now = DateTime.now();
    return now.isAfter(timeStart) && now.isBefore(timeEnd);
  }

  /// Checks if raid is upcoming
  bool get isUpcoming => DateTime.now().isBefore(timeStart);

  /// Checks if raid is finished
  bool get isFinished => DateTime.now().isAfter(timeEnd);

  /// Checks if registrations are open
  bool get isRegistrationOpen {
    final now = DateTime.now();
    return now.isAfter(registrationStart) && now.isBefore(registrationEnd);
  }
}
