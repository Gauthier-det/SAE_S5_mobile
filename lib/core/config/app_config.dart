/// Application configuration constants
class AppConfig {
  AppConfig._();

  /// Application name
  static const String appName = 'OrientAction';

  /// Application version
  static const String appVersion = '1.0.0';

  /// API Base URL - localhost:8000 pour le développement Laravel
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api',
  );
}
