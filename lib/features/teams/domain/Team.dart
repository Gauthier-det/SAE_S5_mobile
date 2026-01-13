// lib/features/raids/domain/models/team.dart
import './../../../features/user/domain/user.dart';

/// Represents a team of runners
/// Corresponds to SAN_TEAMS table
class Team {
  final int id;
  final int userId; // Captain/Creator ID
  final String name;
  final String? image;

  // Related objects (loaded via JOIN)
  final User? captain;
  final List<User>? members;

  Team({
    required this.id,
    required this.userId,
    required this.name,
    this.image,
    this.captain,
    this.members,
  });

  /// Creates Team from database JSON
  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['TEA_ID'],
      userId: json['USE_ID'],
      name: json['TEA_NAME'],
      image: json['TEA_IMAGE'],
    );
  }

  /// Converts Team to JSON for database storage
  Map<String, dynamic> toJson() {
    return {
      'TEA_ID': id,
      'USE_ID': userId,
      'TEA_NAME': name,
      'TEA_IMAGE': image,
    };
  }

  /// Returns number of members
  int get memberCount => members?.length ?? 0;
}
