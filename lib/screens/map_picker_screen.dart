import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/city.dart';
import '../services/location_service.dart';
import '../theme/app_colors.dart';
import 'ui_shell.dart';

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({
    super.key,
    required this.title,
    required this.initialSelection,
  });

  final String title;
  final LocationSelection initialSelection;

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  final _locationService = LocationService();
  final _mapController = MapController();

  late LatLng _selectedPoint;
  late LocationSelection _previewSelection;
  bool _locating = false;
  bool _confirming = false;
  bool _resolvingLabel = false;
  int _selectionToken = 0;

  @override
  void initState() {
    super.initState();
    _selectedPoint = LatLng(
      widget.initialSelection.latitude,
      widget.initialSelection.longitude,
    );
    _previewSelection = widget.initialSelection;
  }

  void _selectPresetCity(CollegeCity city) {
    final point = LatLng(city.latitude, city.longitude);
    _selectPoint(point);
    _mapController.move(point, 10);
  }

  void _selectPoint(LatLng point) {
    _applySelection(point);
  }

  void _applySelection(LatLng point) {
    final matchedCity = CollegeCity.nearestTo(point.latitude, point.longitude);
    final token = ++_selectionToken;

    setState(() {
      _selectedPoint = point;
      _resolvingLabel = true;
      _previewSelection = LocationSelection(
        city: matchedCity,
        label: 'Finding nearby place...',
        latitude: point.latitude,
        longitude: point.longitude,
      );
    });

    _resolvePreviewLabel(point, token);
  }

  Future<void> _resolvePreviewLabel(LatLng point, int token) async {
    final selection = await _locationService.describeSelection(
      latitude: point.latitude,
      longitude: point.longitude,
    );

    if (!mounted || token != _selectionToken) {
      return;
    }

    setState(() {
      _previewSelection = selection;
      _resolvingLabel = false;
    });
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      _locating = true;
    });

    try {
      final position = await _locationService.resolveCurrentPosition();
      if (!mounted) {
        return;
      }
      _selectPoint(LatLng(position.latitude, position.longitude));
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _locating = false;
        });
      }
    }
  }

  Future<void> _confirmSelection() async {
    setState(() {
      _confirming = true;
    });

    try {
      final selection = await _locationService.describeSelection(
        latitude: _selectedPoint.latitude,
        longitude: _selectedPoint.longitude,
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(selection);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _confirming = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final distanceKm = CollegeCity.distanceKmBetween(
      _selectedPoint.latitude,
      _selectedPoint.longitude,
      _previewSelection.city.latitude,
      _previewSelection.city.longitude,
    );

    return UiShell(
      title: widget.title,
      child: ListView(
        children: [
          Text(
            'Tap anywhere on the map, or use a quick city jump below.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textInk.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: CollegeCity.supportedCities.map((city) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    label: Text(city.label),
                    onPressed: () => _selectPresetCity(city),
                    backgroundColor: AppColors.secondaryGreen,
                    side: const BorderSide(color: AppColors.primaryGreen),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: SizedBox(
              height: 420,
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _selectedPoint,
                  initialZoom: 4.2,
                  onTap: (tapPosition, point) => _selectPoint(point),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.lajicpajam.flock',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _selectedPoint,
                        width: 48,
                        height: 48,
                        child: const Icon(
                          Icons.location_on,
                          size: 40,
                          color: AppColors.primaryGreen,
                        ),
                      ),
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.secondaryGreen,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.subtleBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _previewSelection.label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _resolvingLabel
                      ? 'Looking up the local area for this pin...'
                      : distanceKm < 1
                      ? 'This pin is inside ${_previewSelection.city.label}.'
                      : 'Nearest major city is ${_previewSelection.city.label}, about ${distanceKm.toStringAsFixed(1)} km away.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textInk.withValues(alpha: 0.72),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _locating ? null : _useCurrentLocation,
                  icon: const Icon(Icons.my_location),
                  label: Text(_locating ? 'Locating...' : 'Use My Location'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _confirming ? null : _confirmSelection,
                  icon: const Icon(Icons.check),
                  label: Text(_confirming ? 'Saving...' : 'Use This Spot'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
