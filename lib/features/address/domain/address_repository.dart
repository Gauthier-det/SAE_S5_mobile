// lib/features/address/domain/address_repository.dart
import 'address.dart';

abstract class AddressRepository {
  Future<List<Address>> getAllAddresses();
  Future<Address?> getAddressById(int id);
  Future<int> createAddress(Address address);
}
