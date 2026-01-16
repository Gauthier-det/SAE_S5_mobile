import 'package:http/http.dart' as http;
import '../config/app_config.dart';

/// Service for managing API availability and network calls.
class ApiService {
  final http.Client client;
  final String baseUrl;

  bool? _lastApiStatus;
  DateTime? _lastCheckTime;
  static const Duration _cacheDuration = Duration(minutes: 5);

  /// Creates an instance of ApiService with optional HTTP client and base URL.
  ApiService({http.Client? client, String? baseUrl})
    : client = client ?? http.Client(),
      baseUrl = baseUrl ?? AppConfig.apiBaseUrl;

  /// Checks if the API is available by calling the health endpoint.
  /// Uses cached results for 5 minutes to avoid excessive checks.
  Future<bool> isApiAvailable() async {
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

  /// Resets the API availability cache.
  void resetApiStatusCache() {
    _lastApiStatus = null;
    _lastCheckTime = null;
  }

  /// Executes an API call with automatic fallback to a local cache call.
  /// If the API is unavailable or an error occurs, [fallbackCall] is executed.
  Future<T> executeWithFallback<T>({
    required Future<T> Function() apiCall,
    required Future<T> Function() fallbackCall,
    String? logMessage,
  }) async {
    try {
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
