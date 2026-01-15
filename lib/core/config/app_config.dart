/// Application configuration constants
class AppConfig {
  AppConfig._();

  /// Application name
  static const String appName = 'OrientAction';

  /// Application version
  static const String appVersion = '1.0.0';

  /// API Base URL
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.1.194:8000/api',
  );
}
