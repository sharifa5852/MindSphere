import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // Your computer's current Wi-Fi LAN IP (from ipconfig).
  // If this ever stops working (e.g. router reassigns a new IP),
  // re-run ipconfig and update this value.
  static const String baseUrl = 'http://192.168.0.139:5000/api';

  static Future<Map<String, String>> _getHeaders() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('No authenticated Firebase user found.');
    }

    final idToken = await user.getIdToken();

    if (idToken == null || idToken.isEmpty) {
      throw Exception('Could not obtain Firebase ID token.');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $idToken',
    };
  }

  static Future<Map<String, dynamic>> syncUser({
    required String name,
  }) async {
    final headers = await _getHeaders();

    final response = await http.post(
      Uri.parse('$baseUrl/auth/sync'),
      headers: headers,
      body: jsonEncode({
        'name': name,
      }),
    );

    final responseBody = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : <String, dynamic>{};

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Map<String, dynamic>.from(responseBody);
    }

    throw Exception(
      responseBody['message'] ?? 'Failed to synchronize user with backend.',
    );
  }
}