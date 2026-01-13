// lib/features/raids/domain/Raid.dart
class Raid {
  final int id;
  final int clubId;
  final int addressId;
  final int userId;
  final String name;
  final String? email;
  final String? phoneNumber;
  final String? website;
  final String? image;
  final DateTime timeStart;
  final DateTime timeEnd;
  final DateTime registrationStart;
  final DateTime registrationEnd;

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
  });

  factory Raid.fromJson(Map<String, dynamic> json) {
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
    );
  }

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
}
