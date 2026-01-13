// lib/features/raids/domain/models/club.dart
import '../../address/domain/address.dart';
import '../../user/domain/user.dart';

/// Represents an orienteering club
/// Corresponds to SAN_CLUBS table
class Club {
  final int id;
  final int userId; // Manager ID
  final int addressId;
  final String name;

  // Related objects (loaded via JOIN)
  final Address? address;
  final User? manager;

  Club({
    required this.id,
    required this.userId,
    required this.addressId,
    required this.name,
    this.address,
    this.manager,
  });

  /// Creates Club from database JSON
  factory Club.fromJson(Map<String, dynamic> json) {
    // Parse address if present in JOIN
    Address? address;
    if (json.containsKey('ADD_POSTAL_CODE')) {
      address = Address.fromJson(json);
    }

    return Club(
      id: json['CLU_ID'],
      userId: json['USE_ID'],
      addressId: json['ADD_ID'],
      name: json['CLU_NAME'],
      address: address,
    );
  }

  /// Converts Club to JSON for database storage
  Map<String, dynamic> toJson() {
    return {
      'CLU_ID': id,
      'USE_ID': userId,
      'ADD_ID': addressId,
      'CLU_NAME': name,
    };
  }
}
