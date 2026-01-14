// lib/features/address/data/datasources/address_local_sources.dart
import '../../../../core/database/database_helper.dart';
import '../../domain/address.dart';

class AddressLocalSources {
  Future<List<Address>> getAllAddresses() async {
    final db = await DatabaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'SAN_ADDRESSES',
      orderBy: 'ADD_CITY, ADD_STREET_NAME',
    );
    return maps.map((map) => Address.fromJson(map)).toList();
  }

  Future<Address?> getAddressById(int id) async {
    final db = await DatabaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'SAN_ADDRESSES',
      where: 'ADD_ID = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Address.fromJson(maps.first);
  }

  Future<int> createAddress(Address address) async {
    final db = await DatabaseHelper.database;
    return await db.insert('SAN_ADDRESSES', address.toJson());
  }
}
