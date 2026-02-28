import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/auth_user.dart';
import '../models/carbon_stats.dart';
import '../models/trip.dart';
import '../services/api.dart';

class AppState extends ChangeNotifier {
  AppState({ApiService? apiService}) : _api = apiService ?? ApiService();

  final ApiService _api;

  String? _token;
  AuthUser? _currentUser;
  List<Trip> _trips = [];
  bool _isLoading = false;
  String? _errorMessage;
  CarbonStats? _carbonStats;

  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AuthUser? get currentUser => _currentUser;
  String? get token => _token;
  List<Trip> get trips => _trips;
  CarbonStats? get carbonStats => _carbonStats;

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
      await loadTrips();
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
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    return _runBusy(() async {
      final result = await _api.login(email: email, password: password);
      _token = result.token;
      _currentUser = result.user;
      await loadTrips();
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
    required DateTime departureTime,
    required int seatsAvailable,
    required String notes,
  }) async {
    await _api.createTrip(
      token: _requireToken(),
      originCity: originCity,
      destinationCity: destinationCity,
      departureTime: departureTime,
      seatsAvailable: seatsAvailable,
      notes: notes,
    );
    await loadTrips();
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
  }

  Future<void> acceptRequest(int requestId) async {
    await _api.acceptRequest(token: _requireToken(), requestId: requestId);
  }

  Future<void> rejectRequest(int requestId) async {
    await _api.rejectRequest(token: _requireToken(), requestId: requestId);
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
    notifyListeners();
  }

  Future<CarbonStats> loadCarbonStats() async {
    final stats = await _api.fetchCarbonStats(token: _requireToken());
    _carbonStats = stats;
    notifyListeners();
    return stats;
  }

  Future<void> updateProfile({
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
    final user = await _api.updateCurrentUser(
      token: _requireToken(),
      name: name,
      phoneNumber: phoneNumber,
      profilePhotoUrl: profilePhotoUrl,
      carMake: carMake,
      carModel: carModel,
      carColor: carColor,
      carPlateState: carPlateState,
      carPlateNumber: carPlateNumber,
      carDescription: carDescription,
    );
    _currentUser = user;
    notifyListeners();
  }

  void logout() {
    _token = null;
    _currentUser = null;
    _trips = [];
    _errorMessage = null;
    _carbonStats = null;
    notifyListeners();
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
}
