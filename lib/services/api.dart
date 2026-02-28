import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/auth_user.dart';
import '../models/chat_message.dart';
import '../models/trip.dart';

class ApiResult {
  ApiResult({
    required this.token,
    required this.user,
  });

  final String token;
  final AuthUser user;
}

class MessagesResult {
  MessagesResult({
    required this.messages,
    required this.acceptedRiders,
    required this.participantId,
  });

  final List<ChatMessage> messages;
  final List<Map<String, dynamic>> acceptedRiders;
  final int? participantId;
}

class ApiService {
  ApiService({String? baseUrl}) : _baseUrl = baseUrl ?? _defaultBaseUrl();

  final String _baseUrl;

  static String _defaultBaseUrl() {
    if (kIsWeb) {
      return 'http://localhost:3000';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:3000';
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
      case TargetPlatform.fuchsia:
        return 'http://localhost:3000';
    }
  }

  Map<String, String> _headers([String? token]) {
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<ApiResult> register({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
    required String profilePhotoUrl,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/register'),
      headers: _headers(),
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'phoneNumber': phoneNumber,
        'profilePhotoUrl': profilePhotoUrl,
      }),
    );

    return _parseAuthResult(response);
  }

  Future<ApiResult> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: _headers(),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    return _parseAuthResult(response);
  }

  Future<List<Trip>> fetchTrips({String? token}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/trips'),
      headers: _headers(token),
    );

    final data = _decode(response) as List<dynamic>;
    return data
        .map((item) => Trip.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Trip> fetchTripDetail(int tripId, {String? token}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/trips/$tripId'),
      headers: _headers(token),
    );

    final data = _decode(response) as Map<String, dynamic>;
    return Trip.fromJson(data);
  }

  Future<void> createTrip({
    required String token,
    required String originCity,
    required String destinationCity,
    required DateTime departureTime,
    required int seatsAvailable,
    required String notes,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/trips'),
      headers: _headers(token),
      body: jsonEncode({
        'originCity': originCity,
        'destinationCity': destinationCity,
        'departureTime': departureTime.toUtc().toIso8601String(),
        'seatsAvailable': seatsAvailable,
        'notes': notes,
      }),
    );

    _decode(response);
  }

  Future<void> requestSeat({
    required String token,
    required int tripId,
    required String message,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/trips/$tripId/request'),
      headers: _headers(token),
      body: jsonEncode({'message': message}),
    );

    _decode(response);
  }

  Future<void> acceptRequest({
    required String token,
    required int requestId,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/requests/$requestId/accept'),
      headers: _headers(token),
    );

    _decode(response);
  }

  Future<void> rejectRequest({
    required String token,
    required int requestId,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/requests/$requestId/reject'),
      headers: _headers(token),
    );

    _decode(response);
  }

  Future<MessagesResult> fetchMessages({
    required String token,
    required int tripId,
    int? participantId,
  }) async {
    final uri = Uri.parse('$_baseUrl/trips/$tripId/messages').replace(
      queryParameters: participantId == null
          ? null
          : {'participantId': participantId.toString()},
    );

    final response = await http.get(uri, headers: _headers(token));
    final data = _decode(response) as Map<String, dynamic>;
    final rawMessages = data['messages'] as List<dynamic>? ?? const [];
    final rawAcceptedRiders = data['accepted_riders'] as List<dynamic>? ?? const [];

    return MessagesResult(
      messages: rawMessages
          .map((item) => ChatMessage.fromJson(item as Map<String, dynamic>))
          .toList(),
      acceptedRiders: rawAcceptedRiders
          .map((item) => item as Map<String, dynamic>)
          .toList(),
      participantId: data['participant_id'] as int?,
    );
  }

  Future<void> sendMessage({
    required String token,
    required int tripId,
    required String messageText,
    int? receiverId,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/trips/$tripId/messages'),
      headers: _headers(token),
      body: jsonEncode({
        'messageText': messageText,
        'receiverId': receiverId,
      }),
    );

    _decode(response);
  }

  ApiResult _parseAuthResult(http.Response response) {
    final data = _decode(response) as Map<String, dynamic>;
    return ApiResult(
      token: data['token'] as String,
      user: AuthUser.fromJson(data['user'] as Map<String, dynamic>),
    );
  }

  dynamic _decode(http.Response response) {
    final body = response.body.isEmpty ? '{}' : response.body;
    final decoded = jsonDecode(body);

    if (response.statusCode >= 400) {
      final message = decoded is Map<String, dynamic>
          ? decoded['error'] as String? ?? 'Request failed.'
          : 'Request failed.';
      throw Exception(message);
    }

    return decoded;
  }
}
