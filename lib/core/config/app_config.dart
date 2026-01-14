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
    defaultValue: 'https://g13-devc3.unicaen.fr/api',
  );
}
