// lib/features/address/data/repositories/address_repository_impl.dart
import '../../domain/address_repository.dart';
import '../../domain/address.dart';
import '../datasources/address_api_sources.dart';
import '../datasources/address_local_sources.dart';
import '../../../auth/data/datasources/auth_local_sources.dart';

class AddressRepositoryImpl implements AddressRepository {
  final AddressLocalSources localSources;
  final AddressApiSources? apiSources; // Optional for now
  final AuthLocalSources? authLocalSources;

  AddressRepositoryImpl({
    required this.localSources,
    this.apiSources,
    this.authLocalSources,
  });

  Future<void> _setAuthToken() async {
    if (apiSources != null && authLocalSources != null) {
      final token = authLocalSources!.getToken(); // Changed from getAuthToken()
      if (token != null) {
        apiSources!.setAuthToken(token);
      }
    }
  }

  @override
  Future<List<Address>> getAllAddresses() async {
    try {
      if (apiSources != null) {
        await _setAuthToken();
        final addresses = await apiSources!.getAllAddresses();
        // Sync local? For now just return API
        return addresses;
      }
    } catch (e) {
      // Fallback
    }
    return await localSources.getAllAddresses();
  }

  @override
  Future<Address?> getAddressById(int id) async {
    try {
      if (apiSources != null) {
        await _setAuthToken();
        return await apiSources!.getAddressById(id);
      }
    } catch (e) {
      // Fallback
    }
    return await localSources.getAddressById(id);
  }

  @override
  Future<int> createAddress(Address address) async {
    if (apiSources != null) {
      await _setAuthToken();
      final id = await apiSources!.createAddress(address);
      // We could also save locally here if we wanted to cache it
      return id;
    }
    return await localSources.createAddress(address);
  }
}
