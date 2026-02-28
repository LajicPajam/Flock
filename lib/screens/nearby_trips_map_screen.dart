import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/city.dart';
import '../models/trip.dart';
import '../theme/app_colors.dart';
import 'trip_detail_screen.dart';
import 'ui_shell.dart';

class NearbyTripsMapScreen extends StatelessWidget {
  const NearbyTripsMapScreen({
    super.key,
    required this.currentLocation,
    required this.trips,
  });

  final LocationSelection currentLocation;
  final List<Trip> trips;

  @override
  Widget build(BuildContext context) {
    final routePoints = <LatLng>[LatLng(
      currentLocation.latitude,
      currentLocation.longitude,
    )];
    final routeSegments = trips
        .map((trip) {
          final start = _tripPoint(
            trip.originLatitude,
            trip.originLongitude,
            trip.originCity,
          );
          final end = _tripPoint(
            trip.destinationLatitude,
            trip.destinationLongitude,
            trip.destinationCity,
          );
          routePoints..add(start)..add(end);
          return (trip: trip, start: start, end: end);
        })
        .toList();

    final center = _centerFor(routePoints);
    final zoom = _zoomFor(routePoints);

    return UiShell(
      title: 'Trips In Your Area',
      child: ListView(
        children: [
          Text(
            trips.isEmpty
                ? 'No active routes are currently passing near ${currentLocation.label}.'
                : '${trips.length} active route${trips.length == 1 ? '' : 's'} pass near ${currentLocation.label}.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textInk.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: SizedBox(
              height: 420,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: center,
                  initialZoom: zoom,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.lajicpajam.flock',
                  ),
                  PolylineLayer(
                    polylines: [
                      for (var i = 0; i < routeSegments.length; i++)
                        Polyline(
                          points: [routeSegments[i].start, routeSegments[i].end],
                          strokeWidth: 4,
                          color: _routeColor(i),
                        ),
                    ],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(
                          currentLocation.latitude,
                          currentLocation.longitude,
                        ),
                        width: 46,
                        height: 46,
                        child: const _AreaMarker(
                          icon: Icons.my_location_rounded,
                          color: AppColors.textInk,
                        ),
                      ),
                      for (var i = 0; i < routeSegments.length; i++) ...[
                        Marker(
                          point: routeSegments[i].start,
                          width: 34,
                          height: 34,
                          child: _AreaMarker(
                            icon: Icons.play_arrow_rounded,
                            color: _routeColor(i),
                          ),
                        ),
                        Marker(
                          point: routeSegments[i].end,
                          width: 34,
                          height: 34,
                          child: _AreaMarker(
                            icon: Icons.flag_rounded,
                            color: _routeColor(i),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution('OpenStreetMap contributors'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (trips.isEmpty)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.secondaryGreen,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.subtleBorder),
              ),
              child: const Text(
                'Try again later or move the map filters to explore more routes.',
              ),
            )
          else
            ...List.generate(routeSegments.length, (index) {
              final route = routeSegments[index];
              final trip = route.trip;
              final routeDistanceKm = CollegeCity.distanceKmToSegment(
                pointLatitude: currentLocation.latitude,
                pointLongitude: currentLocation.longitude,
                segmentStartLatitude: route.start.latitude,
                segmentStartLongitude: route.start.longitude,
                segmentEndLatitude: route.end.latitude,
                segmentEndLongitude: route.end.longitude,
              );

              return Padding(
                padding: EdgeInsets.only(bottom: index == routeSegments.length - 1 ? 0 : 12),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: const BorderSide(color: AppColors.subtleBorder),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      '${trip.originDisplayLabel} to ${trip.destinationDisplayLabel}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Driver: ${trip.driverName}'),
                          Text(
                            '${routeDistanceKm.toStringAsFixed(1)} km from your current location',
                          ),
                        ],
                      ),
                    ),
                    trailing: Icon(
                      Icons.alt_route_rounded,
                      color: _routeColor(index),
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => TripDetailScreen(tripId: trip.id),
                        ),
                      );
                    },
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  static LatLng _tripPoint(
    double? latitude,
    double? longitude,
    String cityValue,
  ) {
    if (latitude != null && longitude != null) {
      return LatLng(latitude, longitude);
    }

    final city = CollegeCity.fromApiValue(cityValue);
    return LatLng(city.latitude, city.longitude);
  }

  static LatLng _centerFor(List<LatLng> points) {
    var minLat = points.first.latitude;
    var maxLat = points.first.latitude;
    var minLng = points.first.longitude;
    var maxLng = points.first.longitude;

    for (final point in points.skip(1)) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    return LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2);
  }

  static double _zoomFor(List<LatLng> points) {
    if (points.length < 2) {
      return 9;
    }

    var minLat = points.first.latitude;
    var maxLat = points.first.latitude;
    var minLng = points.first.longitude;
    var maxLng = points.first.longitude;

    for (final point in points.skip(1)) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    final diagonalKm = CollegeCity.distanceKmBetween(
      minLat,
      minLng,
      maxLat,
      maxLng,
    );

    if (diagonalKm < 25) return 10.5;
    if (diagonalKm < 60) return 9.2;
    if (diagonalKm < 120) return 8.4;
    if (diagonalKm < 250) return 7.4;
    if (diagonalKm < 500) return 6.4;
    if (diagonalKm < 1000) return 5.4;
    if (diagonalKm < 1800) return 4.7;
    return 4.0;
  }

  static Color _routeColor(int index) {
    const palette = [
      AppColors.primaryGreen,
      Color(0xFF4B8F6A),
      Color(0xFF6AA084),
      Color(0xFF1F513B),
      Color(0xFF7AB59B),
    ];
    return palette[index % palette.length];
  }
}

class _AreaMarker extends StatelessWidget {
  const _AreaMarker({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }
}
