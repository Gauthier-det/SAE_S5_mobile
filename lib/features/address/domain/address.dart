// lib/features/raids/domain/address.dart
class Address {
  final int id;
  final int postalCode;
  final String city;
  final String streetName;
  final String streetNumber;

  Address({
    required this.id,
    required this.postalCode,
    required this.city,
    required this.streetName,
    required this.streetNumber,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['ADD_ID'],
      postalCode: json['ADD_POSTAL_CODE'],
      city: json['ADD_CITY'],
      streetName: json['ADD_STREET_NAME'],
      streetNumber: json['ADD_STREET_NUMBER'],
    );
  }

  /// Returns full address formatted as string
  /// Example: "12 Rue des Marins, 50100 Cherbourg-en-Cotentin"
  String get fullAddress => 
      '$streetNumber $streetName, $postalCode $city';
  
  /// Returns city name only
  String get cityName => city;
}
