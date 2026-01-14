// lib/features/address/data/repositories/address_repository_impl.dart
import '../../domain/address_repository.dart';
import '../../domain/address.dart';
import '../datasources/address_local_sources.dart';
import '../datasources/address_api_sources.dart';

class AddressRepositoryImpl implements AddressRepository {
  final AddressLocalSources localSources;
  final AddressApiSources apiSources;

  AddressRepositoryImpl({required this.localSources, required this.apiSources});

  @override
  Future<List<Address>> getAllAddresses() async {
    try {
      final addresses = await apiSources.getAllAddresses();
      // Note: Pas de mise en cache car insertAddress n'existe pas encore
      return addresses;
    } catch (e) {
      print('API non disponible, utilisation du cache local: $e');
      return await localSources.getAllAddresses();
    }
  }

  @override
  Future<Address?> getAddressById(int id) async {
    try {
      final address = await apiSources.getAddressById(id);
      // Note: Pas de mise en cache car insertAddress n'existe pas encore
      return address;
    } catch (e) {
      print('API non disponible, utilisation du cache local: $e');
      return await localSources.getAddressById(id);
    }
  }

  @override
  Future<int> createAddress(Address address) async {
    try {
      final createdAddress = await apiSources.createAddress(address);
      // Sauvegarder en local via createAddress existante
      return await localSources.createAddress(createdAddress);
    } catch (e) {
      print('API non disponible, sauvegarde locale uniquement: $e');
      return await localSources.createAddress(address);
    }
  }
}
