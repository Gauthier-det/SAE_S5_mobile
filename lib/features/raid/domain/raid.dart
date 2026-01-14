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
  });

  /// Creates Raid from database JSON
  // lib/features/raids/domain/models/raid.dart

  /// Creates Raid from database JSON
  // lib/features/raids/domain/raid.dart

  factory Raid.fromJson(Map<String, dynamic> json) {
    // Parse address if present in JOIN
    Address? address;
    if (json.containsKey('ADD_POSTAL_CODE')) {
      address = Address.fromJson(json);
    }

    // Parse manager using ALIASED column names
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
        'USE_PASSWORD': '', // Not needed for display
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
        print('❌ Error parsing manager: $e');
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
    );
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