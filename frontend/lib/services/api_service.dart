import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class ApiService {
  static const String baseUrl = ApiConfig.baseUrl;

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

    final response = await _post(
      '$baseUrl/auth/sync',
      headers,
      {'name': name},
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
    static Future<Map<String, dynamic>> getCurrentUser() async {
    final headers = await _getHeaders();
    final response = await _get('$baseUrl/auth/me', headers);
    return _readResponse(response, successCodes: const [200]);
  }

  static Future<Map<String, dynamic>> updateProfile({
    String? name,
    bool? notificationsEnabled,
    String? checkInTime,
    String? theme,
  }) async {
    final headers = await _getHeaders();
    final body = <String, dynamic>{
      if (name != null) 'name': name,
      if (notificationsEnabled != null)
        'notificationsEnabled': notificationsEnabled,
      if (checkInTime != null) 'checkInTime': checkInTime,
      if (theme != null) 'theme': theme,
    };
    final response = await _put('$baseUrl/auth/me', headers, body);
    return _readResponse(response, successCodes: const [200]);
  }
 
  static Future<Map<String, dynamic>> createMoodEntry({
    required int mood,
    required int stress,
    required int energy,
    required int sleep,
    required int socialConnection,
    String? note,
  }) async {
    final headers = await _getHeaders();
    final response = await _post('$baseUrl/moods', headers, {
        'mood': mood,
        'stress': stress,
        'energy': energy,
        'sleep': sleep,
        'socialConnection': socialConnection,
        if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
    });

    final responseBody = response.body.isNotEmpty
        ? Map<String, dynamic>.from(jsonDecode(response.body) as Map)
        : <String, dynamic>{};

    if (response.statusCode == 201) {
      return responseBody;
    }

    throw Exception(responseBody['message'] ?? 'Failed to save mood check-in.');
  }

  static Future<Map<String, dynamic>> getWeeklyMoodSummary() async {
    final headers = await _getHeaders();
    final response = await _get('$baseUrl/moods/weekly', headers);
    return _readResponse(response, successCodes: const [200]);
  }

  static Future<List<Map<String, dynamic>>> getJournalEntries() async {
    final headers = await _getHeaders();
    final response = await _get('$baseUrl/journals', headers);
    final body = _readResponse(response, successCodes: const [200]);
    final entries = body['journalEntries'] as List<dynamic>? ?? const [];
    return entries.map((entry) => Map<String, dynamic>.from(entry as Map)).toList();
  }

  static Future<Map<String, dynamic>> createJournalEntry(String text) async {
    final headers = await _getHeaders();
    final response = await _post('$baseUrl/journals', headers, {'text': text.trim()});
    return _readResponse(response, successCodes: const [201]);
  }

  static Future<Map<String, dynamic>> analyzeJournalEntry(String journalId) async {
    final headers = await _getHeaders();
    final response = await _post('$baseUrl/ai/journal-analysis', headers, {'journalId': journalId});
    return _readResponse(response, successCodes: const [200]);
  }

  static Future<Map<String, dynamic>> chatWithAi(String message) async {
    final headers = await _getHeaders();
    final response = await _post('$baseUrl/ai/chat', headers, {'message': message.trim()});
    return _readResponse(response, successCodes: const [200]);
  }

  static Future<Map<String, dynamic>> submitAssessment({
    required String type,
    required List<int> answers,
  }) async {
    final headers = await _getHeaders();
    final response = await _post('$baseUrl/assessments/submit', headers, {'type': type, 'answers': answers});
    return _readResponse(response, successCodes: const [201]);
  }

  static Future<List<Map<String, dynamic>>> getAssessmentHistory() async {
    final headers = await _getHeaders();
    final response = await _get('$baseUrl/assessments/history', headers);
    final body = _readResponse(response, successCodes: const [200]);
    final assessments = body['assessments'] as List<dynamic>? ?? const [];
    return assessments
        .map((assessment) => Map<String, dynamic>.from(assessment as Map))
        .toList();
  }

  static Future<List<Map<String, dynamic>>> getRecommendedTherapists() async {
    final headers = await _getHeaders();
    final response = await _get('$baseUrl/therapists/recommended', headers);
    final body = _readResponse(response, successCodes: const [200]);
    final recommendations = body['recommendations'] as List<dynamic>? ?? const [];
    return recommendations
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  static Future<Map<String, dynamic>> getWellnessReport({
    required bool monthly,
  }) async {
    final headers = await _getHeaders();
    final period = monthly ? 'monthly' : 'weekly';
    final response = await _get('$baseUrl/reports/$period', headers);
    return _readResponse(response, successCodes: const [200]);
  }

  static String readableError(Object error) {
    if (error is TimeoutException) {
      return 'The request took too long. Check your connection and try again.';
    }
    final message = error.toString().replaceFirst('Exception: ', '');
    if (message.contains('SocketException') || message.contains('Connection refused')) {
      return 'Unable to reach MindSphere. Check your internet connection and that the backend is running.';
    }
    return message;
  }

  static Future<http.Response> _get(
    String url,
    Map<String, String> headers,
  ) => http
      .get(Uri.parse(url), headers: headers)
      .timeout(const Duration(seconds: 20));

  static Future<http.Response> _post(
    String url,
    Map<String, String> headers,
    Map<String, dynamic> body,
  ) => http
      .post(Uri.parse(url), headers: headers, body: jsonEncode(body))
      .timeout(const Duration(seconds: 20));
  
  static Future<http.Response> _put(
    String url,
    Map<String, String> headers,
    Map<String, dynamic> body,
  ) => http
      .put(Uri.parse(url), headers: headers, body: jsonEncode(body))
      .timeout(const Duration(seconds: 20));

  static Map<String, dynamic> _readResponse(
    http.Response response, {
    required List<int> successCodes,
  }) {
    final body = response.body.isNotEmpty
        ? Map<String, dynamic>.from(jsonDecode(response.body) as Map)
        : <String, dynamic>{};

    if (successCodes.contains(response.statusCode)) return body;
    throw Exception(body['message'] ?? 'The request could not be completed.');
  }
}
