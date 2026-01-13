// lib/features/address/domain/address.dart

class Address {
  final int? id;
  final int postalCode;
  final String city;
  final String streetName;
  final String streetNumber;

  Address({
    this.id,
    required this.postalCode,
    required this.city,
    required this.streetName,
    required this.streetNumber,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['ADD_ID'] as int?,
      postalCode: json['ADD_POSTAL_CODE'] as int,
      city: json['ADD_CITY'] as String,
      streetName: json['ADD_STREET_NAME'] as String,
      streetNumber: json['ADD_STREET_NUMBER'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'ADD_ID': id,
      'ADD_POSTAL_CODE': postalCode,
      'ADD_CITY': city,
      'ADD_STREET_NAME': streetName,
      'ADD_STREET_NUMBER': streetNumber,
    };
  }

  String get fullAddress => '$streetNumber $streetName, $postalCode $city';
  String get cityName => city;
}
