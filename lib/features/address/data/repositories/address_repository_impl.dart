// lib/features/address/data/repositories/address_repository_impl.dart
import '../../domain/address_repository.dart';
import '../../domain/address.dart';
import '../datasources/address_local_sources.dart';

class AddressRepositoryImpl implements AddressRepository {
  final AddressLocalSources localSources;

  AddressRepositoryImpl({required this.localSources});

  @override
  Future<List<Address>> getAllAddresses() async {
    return await localSources.getAllAddresses();
  }

  @override
  Future<Address?> getAddressById(int id) async {
    return await localSources.getAddressById(id);
  }

  @override
  Future<int> createAddress(Address address) async {
    return await localSources.createAddress(address);
  }
}
