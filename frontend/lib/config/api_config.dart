class ApiConfig {
  ApiConfig._();

  /// Set when building/running the app. Example:
  /// flutter run --dart-define=API_BASE_URL=http://192.168.1.20:5000/api
  /// Default local address for the connected development phone.
  /// Update it if your computer receives a different Wi-Fi IPv4 address.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.0.139:5000/api',
  );
}
