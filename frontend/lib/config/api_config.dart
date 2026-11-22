import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  static const String _configuredBaseUrl =
      String.fromEnvironment('API_BASE_URL');

  // Android emulators reach the host computer through 10.0.2.2. Other local
  // targets (web, Windows, macOS, iOS simulator) can use localhost.
  // Physical phones: scripts/run-phone.ps1 forwards the backend over adb and
  // supplies API_BASE_URL. For Wi-Fi without adb, supply the computer's LAN URL.
  static String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) return _configuredBaseUrl;
    return !kIsWeb && defaultTargetPlatform == TargetPlatform.android
        ? 'http://10.0.2.2:5000/api'
        : 'http://localhost:5000/api';
  }
}
