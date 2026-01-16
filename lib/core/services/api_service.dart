// lib/core/services/api_service.dart
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

/// Service pour gérer la disponibilité de l'API et les appels réseau
class ApiService {
  final http.Client client;
  final String baseUrl;

  // Cache de disponibilité API (évite de tester à chaque appel)
  bool? _lastApiStatus;
  DateTime? _lastCheckTime;
  static const Duration _cacheDuration = Duration(minutes: 5);

  ApiService({http.Client? client, String? baseUrl})
    : client = client ?? http.Client(),
      baseUrl = baseUrl ?? AppConfig.apiBaseUrl;

  /// Vérifie si l'API est disponible
  Future<bool> isApiAvailable() async {
    // Utiliser le cache si récent
    if (_lastCheckTime != null &&
        _lastApiStatus != null &&
        DateTime.now().difference(_lastCheckTime!) < _cacheDuration) {
      return _lastApiStatus!;
    }

    try {
      final response = await client
          .get(
            Uri.parse('$baseUrl/health'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 3));

      _lastApiStatus = response.statusCode == 200;
      _lastCheckTime = DateTime.now();
      return _lastApiStatus!;
    } catch (e) {
      _lastApiStatus = false;
      _lastCheckTime = DateTime.now();
      return false;
    }
  }

  /// Réinitialise le cache de disponibilité
  void resetApiStatusCache() {
    _lastApiStatus = null;
    _lastCheckTime = null;
  }

  /// Effectue un appel API avec gestion d'erreur
  Future<T> executeWithFallback<T>({
    required Future<T> Function() apiCall,
    required Future<T> Function() fallbackCall,
    String? logMessage,
  }) async {
    try {
      if (logMessage != null) {
      }

      // Vérifier si l'API est disponible avant d'essayer
      final isAvailable = await isApiAvailable();

      if (!isAvailable) {
        return await fallbackCall();
      }

      return await apiCall();
    } catch (e) {
      return await fallbackCall();
    }
  }
}
