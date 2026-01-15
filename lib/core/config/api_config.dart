// lib/core/config/api_config.dart
class ApiConfig {
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  
  // Pour un vrai device Android (pas émulateur) :
  // static const String baseUrl = 'http://192.168.x.x:8000/api';
  
  // Pour iOS Simulator :
  // static const String baseUrl = 'http://localhost:8000/api';
  
  // Pour production :
  // static const String baseUrl = 'https://ton-domaine.com/api';
  
  // ✅ Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // ✅ Headers par défaut
  static Map<String, String> get defaultHeaders => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };
  
  // ✅ Headers avec authentification
  static Map<String, String> authHeaders(String token) => {
    ...defaultHeaders,
    'Authorization': 'Bearer $token',
  };
}
