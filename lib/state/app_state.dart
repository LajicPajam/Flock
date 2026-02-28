import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_user.dart';
import '../models/app_carbon_overview.dart';
import '../models/carbon_stats.dart';
import '../models/notification_summary.dart';
import '../models/request_summary.dart';
import '../models/trip.dart';
import '../services/api.dart';

class AppState extends ChangeNotifier {
  AppState({ApiService? apiService}) : _api = apiService ?? ApiService() {
    _restoreSession();
  }

  static const _tokenKey = 'session_token';
  static const _userKey = 'session_user';

  final ApiService _api;

  String? _token;
  AuthUser? _currentUser;
  List<Trip> _trips = [];
  List<Trip> _myTrips = [];
  List<RequestSummary> _myRequests = [];
  NotificationSummary _notifications = NotificationSummary(
    notifications: const [],
    unreadCount: 0,
  );
  bool _isLoading = false;
  bool _isReady = false;
  bool _shouldShowWelcomeTour = false;
  String? _errorMessage;
  CarbonStats? _carbonStats;
  AppCarbonOverview? _appCarbonOverview;

  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;
  bool get isReady => _isReady;
  String? get errorMessage => _errorMessage;
  AuthUser? get currentUser => _currentUser;
  String? get token => _token;
  List<Trip> get trips => _trips;
  CarbonStats? get carbonStats => _carbonStats;
  AppCarbonOverview? get appCarbonOverview => _appCarbonOverview;
  List<Trip> get myTrips => _myTrips;
  List<RequestSummary> get myRequests => _myRequests;
  NotificationSummary get notifications => _notifications;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
    required String profilePhotoUrl,
    String? major,
    String? academicYear,
    String? vibe,
    String? favoritePlaylist,
    bool isDriver = false,
    String? carMake,
    String? carModel,
    String? carColor,
    String? carPlateState,
    String? carPlateNumber,
    String? carDescription,
  }) async {
    return _runBusy(() async {
      final result = await _api.register(
        name: name,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
        profilePhotoUrl: profilePhotoUrl,
        major: major,
        academicYear: academicYear,
        vibe: vibe,
        favoritePlaylist: favoritePlaylist,
        isDriver: isDriver,
        carMake: carMake,
        carModel: carModel,
        carColor: carColor,
        carPlateState: carPlateState,
        carPlateNumber: carPlateNumber,
        carDescription: carDescription,
      );
      _token = result.token;
      _currentUser = result.user;
      _shouldShowWelcomeTour = true;
      await _persistSession();
      await _refreshSignedInState();
    });
  }

  Future<String> uploadProfilePhoto({
    required Uint8List bytes,
    required String fileName,
  }) {
    return _api.uploadProfilePhoto(bytes: bytes, fileName: fileName);
  }

  Future<void> saveDriverProfile({
    required String carMake,
    required String carModel,
    required String carColor,
    required String carPlateState,
    required String carPlateNumber,
    required String carDescription,
  }) async {
    final user = await _api.saveDriverProfile(
      token: _requireToken(),
      carMake: carMake,
      carModel: carModel,
      carColor: carColor,
      carPlateState: carPlateState,
      carPlateNumber: carPlateNumber,
      carDescription: carDescription,
    );
    _currentUser = user;
    await _persistSession();
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    return _runBusy(() async {
      final result = await _api.login(email: email, password: password);
      _token = result.token;
      _currentUser = result.user;
      await _persistSession();
      await _refreshSignedInState();
    });
  }

  Future<void> loadTrips() async {
    final trips = await _api.fetchTrips(token: _token);
    _trips = trips;
    notifyListeners();
  }

  Future<Trip> loadTripDetail(int tripId) {
    return _api.fetchTripDetail(tripId, token: _token);
  }

  Future<void> createTrip({
    required String originCity,
    required String destinationCity,
    required String originLabel,
    required String destinationLabel,
    required double originLatitude,
    required double originLongitude,
    required double destinationLatitude,
    required double destinationLongitude,
    required DateTime departureTime,
    required int seatsAvailable,
    required String meetingSpot,
    required String notes,
  }) async {
    await _api.createTrip(
      token: _requireToken(),
      originCity: originCity,
      destinationCity: destinationCity,
      originLabel: originLabel,
      destinationLabel: destinationLabel,
      originLatitude: originLatitude,
      originLongitude: originLongitude,
      destinationLatitude: destinationLatitude,
      destinationLongitude: destinationLongitude,
      departureTime: departureTime,
      seatsAvailable: seatsAvailable,
      meetingSpot: meetingSpot,
      notes: notes,
    );
    await _refreshSignedInState();
  }

  Future<void> updateTrip({
    required int tripId,
    required String originCity,
    required String destinationCity,
    required String originLabel,
    required String destinationLabel,
    required double originLatitude,
    required double originLongitude,
    required double destinationLatitude,
    required double destinationLongitude,
    required DateTime departureTime,
    required int seatsAvailable,
    required String meetingSpot,
    required String notes,
  }) async {
    await _api.updateTrip(
      token: _requireToken(),
      tripId: tripId,
      originCity: originCity,
      destinationCity: destinationCity,
      originLabel: originLabel,
      destinationLabel: destinationLabel,
      originLatitude: originLatitude,
      originLongitude: originLongitude,
      destinationLatitude: destinationLatitude,
      destinationLongitude: destinationLongitude,
      departureTime: departureTime,
      seatsAvailable: seatsAvailable,
      meetingSpot: meetingSpot,
      notes: notes,
    );
    await _refreshSignedInState();
  }

  Future<void> cancelTrip(int tripId) async {
    await _api.cancelTrip(token: _requireToken(), tripId: tripId);
    await _refreshSignedInState();
  }

  Future<void> completeTrip(int tripId) async {
    await _api.completeTrip(token: _requireToken(), tripId: tripId);
    await _refreshSignedInState();
  }

  Future<void> requestSeat({
    required int tripId,
    required String message,
  }) async {
    await _api.requestSeat(
      token: _requireToken(),
      tripId: tripId,
      message: message,
    );
    await loadActivity();
    await loadNotifications();
  }

  Future<void> acceptRequest(int requestId) async {
    await _api.acceptRequest(token: _requireToken(), requestId: requestId);
    await _refreshSignedInState();
  }

  Future<void> rejectRequest(int requestId) async {
    await _api.rejectRequest(token: _requireToken(), requestId: requestId);
    await _refreshSignedInState();
  }

  Future<void> withdrawRequest(int requestId) async {
    await _api.withdrawRequest(token: _requireToken(), requestId: requestId);
    await _refreshSignedInState();
  }

  Future<void> loadActivity() async {
    final token = _requireToken();
    final results = await Future.wait<dynamic>([
      _api.fetchMyTrips(token: token),
      _api.fetchMyRequests(token: token),
    ]);
    _myTrips = results[0] as List<Trip>;
    _myRequests = results[1] as List<RequestSummary>;
    notifyListeners();
  }

  Future<void> loadNotifications() async {
    _notifications = await _api.fetchNotifications(token: _requireToken());
    notifyListeners();
  }

  Future<void> markNotificationRead(int notificationId) async {
    await _api.markNotificationRead(
      token: _requireToken(),
      notificationId: notificationId,
    );
    await loadNotifications();
  }

  Future<void> markAllNotificationsRead() async {
    await _api.markAllNotificationsRead(token: _requireToken());
    await loadNotifications();
  }

  Future<MessagesResult> loadMessages({
    required int tripId,
    int? participantId,
  }) {
    return _api.fetchMessages(
      token: _requireToken(),
      tripId: tripId,
      participantId: participantId,
    );
  }

  Future<void> sendMessage({
    required int tripId,
    required String messageText,
    int? receiverId,
  }) {
    return _api.sendMessage(
      token: _requireToken(),
      tripId: tripId,
      messageText: messageText,
      receiverId: receiverId,
    );
  }

  Future<void> refreshCurrentUser() async {
    final user = await _api.fetchCurrentUser(token: _requireToken());
    _currentUser = user;
    await _persistSession();
    notifyListeners();
  }

  Future<CarbonStats> loadCarbonStats() async {
    final stats = await _api.fetchCarbonStats(token: _requireToken());
    _carbonStats = stats;
    notifyListeners();
    return stats;
  }

  Future<AppCarbonOverview> loadAppCarbonOverview() async {
    final overview = await _api.fetchAppCarbonOverview(token: _requireToken());
    _appCarbonOverview = overview;
    notifyListeners();
    return overview;
  }

  Future<void> updateProfile({
    required String name,
    required String phoneNumber,
    required String profilePhotoUrl,
    String? major,
    String? academicYear,
    String? vibe,
    String? favoritePlaylist,
    String? carMake,
    String? carModel,
    String? carColor,
    String? carPlateState,
    String? carPlateNumber,
    String? carDescription,
  }) async {
    final user = await _api.updateCurrentUser(
      token: _requireToken(),
      name: name,
      phoneNumber: phoneNumber,
      profilePhotoUrl: profilePhotoUrl,
      major: major,
      academicYear: academicYear,
      vibe: vibe,
      favoritePlaylist: favoritePlaylist,
      carMake: carMake,
      carModel: carModel,
      carColor: carColor,
      carPlateState: carPlateState,
      carPlateNumber: carPlateNumber,
      carDescription: carDescription,
    );
    _currentUser = user;
    await _persistSession();
    notifyListeners();
  }

  Future<StudentVerificationResult> startStudentVerification({
    required String studentEmail,
  }) async {
    final result = await _api.startStudentVerification(
      token: _requireToken(),
      studentEmail: studentEmail,
    );
    _currentUser = result.user;
    await _persistSession();
    notifyListeners();
    return result;
  }

  Future<StudentVerificationResult> confirmStudentVerification({
    required String code,
  }) async {
    final result = await _api.confirmStudentVerification(
      token: _requireToken(),
      code: code,
    );
    _currentUser = result.user;
    await _persistSession();
    notifyListeners();
    return result;
  }

  Future<void> createReview({
    required int tripId,
    required int revieweeId,
    required int rating,
    required String comment,
  }) {
    return _api.createReview(
      token: _requireToken(),
      tripId: tripId,
      revieweeId: revieweeId,
      rating: rating,
      comment: comment,
    );
  }

  Future<UserReviewsResult> loadUserReviews(int userId) {
    return _api.fetchUserReviews(userId);
  }

  void logout() {
    _token = null;
    _currentUser = null;
    _trips = [];
    _myTrips = [];
    _myRequests = [];
    _notifications = NotificationSummary(
      notifications: const [],
      unreadCount: 0,
    );
    _shouldShowWelcomeTour = false;
    _errorMessage = null;
    _carbonStats = null;
    _appCarbonOverview = null;
    _clearPersistedSession();
    _carbonStats = null;
    _clearPersistedSession();
    notifyListeners();
  }

  bool consumePendingWelcomeTour() {
    if (!_shouldShowWelcomeTour) {
      return false;
    }

    _shouldShowWelcomeTour = false;
    return true;
  }

  String _requireToken() {
    final token = _token;
    if (token == null) {
      throw Exception('Authentication required.');
    }
    return token;
  }

  Future<bool> _runBusy(Future<void> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await action();
      return true;
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _restoreSession() async {
    try {
      SharedPreferences? prefs;

      try {
        prefs = await SharedPreferences.getInstance();
      } catch (_) {
        _isReady = true;
        notifyListeners();
        return;
      }

      final savedToken = prefs.getString(_tokenKey);
      final savedUser = prefs.getString(_userKey);

      if (savedToken != null && savedUser != null) {
        _token = savedToken;
        _currentUser = AuthUser.fromJson(
          jsonDecode(savedUser) as Map<String, dynamic>,
        );
        notifyListeners();

        try {
          await _refreshSignedInState();
        } catch (_) {
          // Keep the stored session so the user stays signed in even if
          // the backend is momentarily unavailable during app startup.
        }
      }
    } finally {
      _isReady = true;
      notifyListeners();
    }
  }

  Future<void> _refreshSignedInState() async {
    if (_token == null) {
      return;
    }

    final token = _requireToken();
    final results = await Future.wait<dynamic>([
      _api.fetchTrips(token: token),
      _api.fetchCurrentUser(token: token),
      _api.fetchMyTrips(token: token),
      _api.fetchMyRequests(token: token),
      _api.fetchNotifications(token: token),
    ]);

    _trips = results[0] as List<Trip>;
    _currentUser = results[1] as AuthUser;
    _myTrips = results[2] as List<Trip>;
    _myRequests = results[3] as List<RequestSummary>;
    _notifications = results[4] as NotificationSummary;
    await _persistSession();
    notifyListeners();
  }

  Future<void> _persistSession() async {
    final token = _token;
    final user = _currentUser;
    SharedPreferences? prefs;

    try {
      prefs = await SharedPreferences.getInstance();
    } catch (_) {
      return;
    }

    if (token == null || user == null) {
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
      return;
    }

    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  void _clearPersistedSession() {
    SharedPreferences.getInstance()
        .then((prefs) async {
          await prefs.remove(_tokenKey);
          await prefs.remove(_userKey);
        })
        .catchError((_) {
          return null;
        });
  }
}
