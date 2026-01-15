import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();

  /// Vérifie si l'appareil est connecté à Internet
  Future<bool> isConnected() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult.contains(ConnectivityResult.mobile) ||
           connectivityResult.contains(ConnectivityResult.wifi) ||
           connectivityResult.contains(ConnectivityResult.ethernet);
  }

  /// Stream pour écouter les changements de connectivité
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map((results) {
      return results.contains(ConnectivityResult.mobile) ||
             results.contains(ConnectivityResult.wifi) ||
             results.contains(ConnectivityResult.ethernet);
    });
  }
}
