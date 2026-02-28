import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../models/auth_user.dart';
import '../models/app_carbon_overview.dart';
import '../models/carbon_stats.dart';
import '../models/chat_message.dart';
import '../models/notification_summary.dart';
import '../models/request_summary.dart';
import '../models/review.dart';
import '../models/trip.dart';

class ApiResult {
  ApiResult({required this.token, required this.user});

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

class UserReviewsResult {
  UserReviewsResult({
    required this.reviews,
    required this.reviewCount,
    required this.averageRating,
  });

  final List<Review> reviews;
  final int reviewCount;
  final double averageRating;
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
    bool isDriver = false,
    String? carMake,
    String? carModel,
    String? carColor,
    String? carPlateState,
    String? carPlateNumber,
    String? carDescription,
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
        'isDriver': isDriver,
        'carMake': carMake,
        'carModel': carModel,
        'carColor': carColor,
        'carPlateState': carPlateState,
        'carPlateNumber': carPlateNumber,
        'carDescription': carDescription,
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
      body: jsonEncode({'email': email, 'password': password}),
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
    required String meetingSpot,
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
        'meetingSpot': meetingSpot,
        'notes': notes,
      }),
    );

    _decode(response);
  }

  Future<void> updateTrip({
    required String token,
    required int tripId,
    required String originCity,
    required String destinationCity,
    required DateTime departureTime,
    required int seatsAvailable,
    required String meetingSpot,
    required String notes,
  }) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/trips/$tripId'),
      headers: _headers(token),
      body: jsonEncode({
        'originCity': originCity,
        'destinationCity': destinationCity,
        'departureTime': departureTime.toUtc().toIso8601String(),
        'seatsAvailable': seatsAvailable,
        'meetingSpot': meetingSpot,
        'notes': notes,
      }),
    );

    _decode(response);
  }

  Future<void> cancelTrip({required String token, required int tripId}) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/trips/$tripId/cancel'),
      headers: _headers(token),
    );

    _decode(response);
  }

  Future<void> completeTrip({
    required String token,
    required int tripId,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/trips/$tripId/complete'),
      headers: _headers(token),
    );

    _decode(response);
  }

  Future<String> uploadProfilePhoto({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final contentType = _imageContentType(fileName);
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/uploads/profile-photo'),
    );

    request.files.add(
      http.MultipartFile.fromBytes(
        'photo',
        bytes,
        filename: fileName,
        contentType: contentType,
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final data = _decode(response) as Map<String, dynamic>;
    return data['photoUrl'] as String;
  }

  MediaType _imageContentType(String fileName) {
    final lowerName = fileName.toLowerCase();

    if (lowerName.endsWith('.png')) {
      return MediaType('image', 'png');
    }
    if (lowerName.endsWith('.gif')) {
      return MediaType('image', 'gif');
    }
    if (lowerName.endsWith('.webp')) {
      return MediaType('image', 'webp');
    }
    if (lowerName.endsWith('.heic')) {
      return MediaType('image', 'heic');
    }
    if (lowerName.endsWith('.heif')) {
      return MediaType('image', 'heif');
    }

    return MediaType('image', 'jpeg');
  }

  Future<AuthUser> saveDriverProfile({
    required String token,
    required String carMake,
    required String carModel,
    required String carColor,
    required String carPlateState,
    required String carPlateNumber,
    required String carDescription,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/users/me/driver-profile'),
      headers: _headers(token),
      body: jsonEncode({
        'carMake': carMake,
        'carModel': carModel,
        'carColor': carColor,
        'carPlateState': carPlateState,
        'carPlateNumber': carPlateNumber,
        'carDescription': carDescription,
      }),
    );

    final data = _decode(response) as Map<String, dynamic>;
    return AuthUser.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<AuthUser> fetchCurrentUser({required String token}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/users/me'),
      headers: _headers(token),
    );

    final data = _decode(response) as Map<String, dynamic>;
    return AuthUser.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<AuthUser> updateCurrentUser({
    required String token,
    required String name,
    required String phoneNumber,
    required String profilePhotoUrl,
    String? carMake,
    String? carModel,
    String? carColor,
    String? carPlateState,
    String? carPlateNumber,
    String? carDescription,
  }) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/users/me'),
      headers: _headers(token),
      body: jsonEncode({
        'name': name,
        'phoneNumber': phoneNumber,
        'profilePhotoUrl': profilePhotoUrl,
        'carMake': carMake,
        'carModel': carModel,
        'carColor': carColor,
        'carPlateState': carPlateState,
        'carPlateNumber': carPlateNumber,
        'carDescription': carDescription,
      }),
    );

    final data = _decode(response) as Map<String, dynamic>;
    return AuthUser.fromJson(data['user'] as Map<String, dynamic>);
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

  Future<void> withdrawRequest({
    required String token,
    required int requestId,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/requests/$requestId/withdraw'),
      headers: _headers(token),
    );

    _decode(response);
  }

  Future<List<Trip>> fetchMyTrips({required String token}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/users/me/trips'),
      headers: _headers(token),
    );

    final data = _decode(response) as Map<String, dynamic>;
    final rawTrips = data['trips'] as List<dynamic>? ?? const [];
    return rawTrips
        .map((item) => Trip.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<RequestSummary>> fetchMyRequests({required String token}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/users/me/requests'),
      headers: _headers(token),
    );

    final data = _decode(response) as Map<String, dynamic>;
    final rawRequests = data['requests'] as List<dynamic>? ?? const [];
    return rawRequests
        .map((item) => RequestSummary.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<NotificationSummary> fetchNotifications({
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/users/me/notifications'),
      headers: _headers(token),
    );

    final data = _decode(response) as Map<String, dynamic>;
    return NotificationSummary.fromJson(data);
  }

  Future<void> markNotificationRead({
    required String token,
    required int notificationId,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/users/me/notifications/$notificationId/read'),
      headers: _headers(token),
    );

    _decode(response);
  }

  Future<void> markAllNotificationsRead({required String token}) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/users/me/notifications/read-all'),
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
    final rawAcceptedRiders =
        data['accepted_riders'] as List<dynamic>? ?? const [];

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
      body: jsonEncode({'messageText': messageText, 'receiverId': receiverId}),
    );

    _decode(response);
  }

  Future<CarbonStats> fetchCarbonStats({required String token}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/users/me/carbon-stats'),
      headers: _headers(token),
    );

    final data = _decode(response) as Map<String, dynamic>;
    return CarbonStats.fromJson(data);
  }

  Future<AppCarbonOverview> fetchAppCarbonOverview({
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/users/carbon-overview'),
      headers: _headers(token),
    );

    final data = _decode(response) as Map<String, dynamic>;
    return AppCarbonOverview.fromJson(data);
  }

  Future<void> createReview({
    required String token,
    required int tripId,
    required int revieweeId,
    required int rating,
    required String comment,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/trips/$tripId/reviews'),
      headers: _headers(token),
      body: jsonEncode({
        'revieweeId': revieweeId,
        'rating': rating,
        'comment': comment,
      }),
    );

    _decode(response);
  }

  Future<UserReviewsResult> fetchUserReviews(int userId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/users/$userId/reviews'),
    );
    final data = _decode(response) as Map<String, dynamic>;
    final rawReviews = data['reviews'] as List<dynamic>? ?? const [];
    final summary = data['summary'] as Map<String, dynamic>? ?? const {};

    return UserReviewsResult(
      reviews: rawReviews
          .map((item) => Review.fromJson(item as Map<String, dynamic>))
          .toList(),
      reviewCount: summary['review_count'] as int? ?? 0,
      averageRating:
          double.tryParse('${summary['average_rating'] ?? 0}') ?? 0.0,
    );
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
    dynamic decoded;

    try {
      decoded = jsonDecode(body);
    } on FormatException {
      throw Exception(
        response.statusCode >= 400
            ? 'The backend returned an unexpected response. Restart the backend so the latest routes are loaded.'
            : 'Received an unexpected non-JSON response from the backend.',
      );
    }

    if (response.statusCode >= 400) {
      final message = decoded is Map<String, dynamic>
          ? decoded['error'] as String? ?? 'Request failed.'
          : 'Request failed.';
      throw Exception(message);
    }

    return decoded;
  }
}
