import 'dart:async';
import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../models/city.dart';

class ResolvedLocation {
  const ResolvedLocation({required this.selection, required this.distanceKm});

  final LocationSelection selection;
  final double distanceKm;
}

class LocationService {
  Future<ResolvedLocation> resolveCurrentCity() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are turned off on this device.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception('Location permission was denied.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permission is permanently denied. Enable it in Settings.',
      );
    }

    final position = await resolveCurrentPosition();

    final nearestCity = CollegeCity.nearestTo(
      position.latitude,
      position.longitude,
    );
    final selection = await describeSelection(
      latitude: position.latitude,
      longitude: position.longitude,
    );
    final distanceKm = CollegeCity.distanceKmBetween(
      position.latitude,
      position.longitude,
      nearestCity.latitude,
      nearestCity.longitude,
    );

    return ResolvedLocation(selection: selection, distanceKm: distanceKm);
  }

  Future<Position> resolveCurrentPosition() async {
    final lastKnownPosition = await Geolocator.getLastKnownPosition();
    if (lastKnownPosition != null) {
      return lastKnownPosition;
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      ).timeout(const Duration(seconds: 8));
    } on TimeoutException {
      throw Exception(
        'Location lookup timed out. On a simulator, set a simulated location and try again.',
      );
    } catch (_) {
      throw Exception(
        'Could not determine your location right now. On a simulator, set a simulated location and try again.',
      );
    }
  }

  Future<LocationSelection> describeSelection({
    required double latitude,
    required double longitude,
  }) async {
    final nearestCity = CollegeCity.nearestTo(latitude, longitude);
    final label = await _reverseGeocodeLabel(
      latitude: latitude,
      longitude: longitude,
      fallbackLabel: 'Near ${nearestCity.label}',
    );

    return LocationSelection(
      city: nearestCity,
      label: label,
      latitude: latitude,
      longitude: longitude,
    );
  }

  Future<String> _reverseGeocodeLabel({
    required double latitude,
    required double longitude,
    required String fallbackLabel,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              'https://nominatim.openstreetmap.org/reverse?format=jsonv2'
              '&lat=$latitude&lon=$longitude&zoom=12&addressdetails=1',
            ),
            headers: {
              'User-Agent': 'FlockApp/1.0 (local prototype)',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 6));

      if (response.statusCode != 200) {
        return fallbackLabel;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final address = data['address'] as Map<String, dynamic>? ?? const {};
      final placeName =
          address['city'] ??
          address['town'] ??
          address['village'] ??
          address['hamlet'] ??
          address['municipality'] ??
          address['county'];
      final state = address['state'];

      if (placeName is String && placeName.isNotEmpty) {
        if (state is String && state.isNotEmpty) {
          return '$placeName, $state';
        }
        return placeName;
      }

      final displayName = data['display_name'];
      if (displayName is String && displayName.isNotEmpty) {
        final parts = displayName.split(',');
        if (parts.length >= 2) {
          return '${parts[0].trim()}, ${parts[1].trim()}';
        }
        return displayName;
      }
    } catch (_) {
      return fallbackLabel;
    }

    return fallbackLabel;
  }
}
