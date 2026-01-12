/// Application configuration constants
class AppConfig {
  AppConfig._();

  /// Application name
  static const String appName = 'Sanglier Explorer';

  /// Application version
  static const String appVersion = '1.0.0';

  /// API Base URL
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.sanglier-explorer.fr',
  );
}
