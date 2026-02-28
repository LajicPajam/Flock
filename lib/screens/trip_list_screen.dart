import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../models/city.dart';
import '../models/trip.dart' show Trip;
import '../services/location_service.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/tier_badge.dart';
import 'create_trip_screen.dart';
import 'map_picker_screen.dart';
import 'my_activity_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'leaderboard_screen.dart';
import 'trip_detail_screen.dart';
import 'ui_shell.dart';
import 'welcome_tour_screen.dart';

class TripListScreen extends StatefulWidget {
  const TripListScreen({super.key});

  @override
  State<TripListScreen> createState() => _TripListScreenState();
}

class _TripListScreenState extends State<TripListScreen> {
  static const _routeCorridorKm = 80.0;

  LocationSelection? _originFilter;
  LocationSelection? _destinationFilter;
  DateTime? _departureDateFilter;
  LocationSelection? _nearbyLocation;
  List<Trip> _nearbyTrips = const [];
  String? _nearbyTripsError;
  bool _loadingNearbyTrips = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final appState = context.read<AppState>();
      await appState.loadTrips();
      if (!mounted) {
        return;
      }
      await _loadNearbyTripsPreview();
      await appState.loadActivity();
      await appState.loadNotifications();
      if (!mounted) {
        return;
      }
      if (appState.consumePendingWelcomeTour()) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const WelcomeTourScreen(),
            fullscreenDialog: true,
          ),
        );
      }
    });
  }

  List<Trip> _filteredTrips(List<Trip> trips) {
    return trips.where((trip) {
      if (trip.isHistory) {
        return false;
      }
      final matchesRoute = _matchesRequestedRoute(trip);
      final matchesDepartureDate =
          _departureDateFilter == null ||
          _isSameDay(trip.departureTime.toLocal(), _departureDateFilter!);
      return matchesRoute && matchesDepartureDate;
    }).toList();
  }

  bool _isSameDay(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }

  bool _matchesRequestedRoute(Trip trip) {
    if (_originFilter == null && _destinationFilter == null) {
      return true;
    }

    if (trip.originLatitude == null ||
        trip.originLongitude == null ||
        trip.destinationLatitude == null ||
        trip.destinationLongitude == null) {
      final matchesOrigin =
          _originFilter == null || trip.originCity == _originFilter!.apiValue;
      final matchesDestination =
          _destinationFilter == null ||
          trip.destinationCity == _destinationFilter!.apiValue;
      return matchesOrigin && matchesDestination;
    }

    final startLat = trip.originLatitude!;
    final startLng = trip.originLongitude!;
    final endLat = trip.destinationLatitude!;
    final endLng = trip.destinationLongitude!;

    double? originFraction;
    if (_originFilter != null) {
      final originDistance = CollegeCity.distanceKmToSegment(
        pointLatitude: _originFilter!.latitude,
        pointLongitude: _originFilter!.longitude,
        segmentStartLatitude: startLat,
        segmentStartLongitude: startLng,
        segmentEndLatitude: endLat,
        segmentEndLongitude: endLng,
      );
      if (originDistance > _routeCorridorKm) {
        return false;
      }
      originFraction = CollegeCity.segmentFractionForPoint(
        pointLatitude: _originFilter!.latitude,
        pointLongitude: _originFilter!.longitude,
        segmentStartLatitude: startLat,
        segmentStartLongitude: startLng,
        segmentEndLatitude: endLat,
        segmentEndLongitude: endLng,
      );
    }

    double? destinationFraction;
    if (_destinationFilter != null) {
      final destinationDistance = CollegeCity.distanceKmToSegment(
        pointLatitude: _destinationFilter!.latitude,
        pointLongitude: _destinationFilter!.longitude,
        segmentStartLatitude: startLat,
        segmentStartLongitude: startLng,
        segmentEndLatitude: endLat,
        segmentEndLongitude: endLng,
      );
      if (destinationDistance > _routeCorridorKm) {
        return false;
      }
      destinationFraction = CollegeCity.segmentFractionForPoint(
        pointLatitude: _destinationFilter!.latitude,
        pointLongitude: _destinationFilter!.longitude,
        segmentStartLatitude: startLat,
        segmentStartLongitude: startLng,
        segmentEndLatitude: endLat,
        segmentEndLongitude: endLng,
      );
    }

    if (originFraction != null &&
        destinationFraction != null &&
        originFraction > destinationFraction) {
      return false;
    }

    return true;
  }

  String _dateLabel(DateTime value) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[value.month - 1]} ${value.day}, ${value.year}';
  }

  Future<void> _pickDepartureDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: _departureDateFilter ?? DateTime.now(),
    );

    if (selectedDate == null || !mounted) {
      return;
    }

    setState(() {
      _departureDateFilter = selectedDate;
    });
  }

  Future<void> _pickOriginOnMap() async {
    final selection = await Navigator.of(context).push<LocationSelection>(
      MaterialPageRoute(
        builder: (_) => MapPickerScreen(
          title: 'Pick Starting Area',
          initialSelection:
              _originFilter ?? LocationSelection.fromCity(CollegeCity.denverCo),
        ),
      ),
    );

    if (selection == null || !mounted) {
      return;
    }

    setState(() {
      _originFilter = selection;
    });
  }

  Future<void> _pickDestinationOnMap() async {
    final selection = await Navigator.of(context).push<LocationSelection>(
      MaterialPageRoute(
        builder: (_) => MapPickerScreen(
          title: 'Pick Destination Area',
          initialSelection:
              _destinationFilter ??
              LocationSelection.fromCity(CollegeCity.chicagoIl),
        ),
      ),
    );

    if (selection == null || !mounted) {
      return;
    }

    setState(() {
      _destinationFilter = selection;
    });
  }

  Future<void> _loadNearbyTripsPreview() async {
    if (_loadingNearbyTrips) {
      return;
    }

    final appState = context.read<AppState>();

    setState(() {
      _loadingNearbyTrips = true;
      _nearbyTripsError = null;
    });

    try {
      final resolved = await LocationService().resolveCurrentCity();
      final allTrips = appState.trips;
      final nearbyTrips = allTrips.where((trip) {
        if (trip.isHistory) {
          return false;
        }
        return _tripPassesNearLocation(trip, resolved.selection);
      }).toList();

      if (!mounted) {
        return;
      }

      setState(() {
        _nearbyLocation = resolved.selection;
        _nearbyTrips = nearbyTrips;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _nearbyTripsError = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _loadingNearbyTrips = false;
        });
      }
    }
  }

  bool _tripPassesNearLocation(Trip trip, LocationSelection location) {
    final start = _tripRouteStart(trip);
    final end = _tripRouteEnd(trip);

    return CollegeCity.distanceKmToSegment(
          pointLatitude: location.latitude,
          pointLongitude: location.longitude,
          segmentStartLatitude: start.latitude,
          segmentStartLongitude: start.longitude,
          segmentEndLatitude: end.latitude,
          segmentEndLongitude: end.longitude,
        ) <=
        _routeCorridorKm;
  }

  LocationSelection _tripRouteStart(Trip trip) {
    if (trip.originLatitude != null && trip.originLongitude != null) {
      return LocationSelection(
        city: CollegeCity.fromApiValue(trip.originCity),
        label: trip.originDisplayLabel,
        latitude: trip.originLatitude!,
        longitude: trip.originLongitude!,
      );
    }
    final city = CollegeCity.fromApiValue(trip.originCity);
    return LocationSelection.fromCity(city);
  }

  LocationSelection _tripRouteEnd(Trip trip) {
    if (trip.destinationLatitude != null && trip.destinationLongitude != null) {
      return LocationSelection(
        city: CollegeCity.fromApiValue(trip.destinationCity),
        label: trip.destinationDisplayLabel,
        latitude: trip.destinationLatitude!,
        longitude: trip.destinationLongitude!,
      );
    }
    final city = CollegeCity.fromApiValue(trip.destinationCity);
    return LocationSelection.fromCity(city);
  }

  Future<void> _handleMenuSelection(_TripMenuAction action) async {
    switch (action) {
      case _TripMenuAction.activity:
        await Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const MyActivityScreen()),
        );
        return;
      case _TripMenuAction.notifications:
        await Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const NotificationsScreen()),
        );
        return;
      case _TripMenuAction.profile:
        final appState = context.read<AppState>();
        await Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const ProfileScreen()));
        if (!mounted) {
          return;
        }
        await appState.refreshCurrentUser();
        return;
      case _TripMenuAction.settings:
        await Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const SettingsScreen()));
        return;
      case _TripMenuAction.leaderboard:
        await Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const LeaderboardScreen()),
        );
        return;
      case _TripMenuAction.logout:
        context.read<AppState>().logout();
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final filteredTrips = _filteredTrips(appState.trips);

    return UiShell(
      useWideLayout: true,
      title: 'Available Trips',
      actions: [
        PopupMenuButton<_TripMenuAction>(
          tooltip: 'Menu',
          icon: const Icon(Icons.menu),
          onSelected: _handleMenuSelection,
          itemBuilder: (context) => [
            PopupMenuItem<_TripMenuAction>(
              value: _TripMenuAction.activity,
              child: _MenuRow(
                icon: Icons.view_list,
                label: 'My Activity',
                count: appState.myRequests.length,
              ),
            ),
            PopupMenuItem<_TripMenuAction>(
              value: _TripMenuAction.notifications,
              child: _MenuRow(
                icon: Icons.notifications_outlined,
                label: 'Notifications',
                count: appState.notifications.totalCount,
              ),
            ),
            const PopupMenuItem<_TripMenuAction>(
              value: _TripMenuAction.profile,
              child: _MenuRow(icon: Icons.person, label: 'Profile'),
            ),
            const PopupMenuItem<_TripMenuAction>(
              value: _TripMenuAction.settings,
              child: _MenuRow(icon: Icons.settings, label: 'Settings'),
            ),
            const PopupMenuItem<_TripMenuAction>(
              value: _TripMenuAction.leaderboard,
              child: _MenuRow(icon: Icons.emoji_events, label: 'Leaderboard'),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem<_TripMenuAction>(
              value: _TripMenuAction.logout,
              child: _MenuRow(icon: Icons.logout, label: 'Log Out'),
            ),
          ],
        ),
      ],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final appState = context.read<AppState>();
          await Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const CreateTripScreen()),
          );
          if (!mounted) {
            return;
          }
          await appState.loadTrips();
          await _loadNearbyTripsPreview();
        },
        icon: const Icon(Icons.add),
        label: const Text('Create Trip'),
      ),
      child: RefreshIndicator(
        onRefresh: () async {
          final appState = context.read<AppState>();
          await appState.loadTrips();
          await _loadNearbyTripsPreview();
          await appState.loadActivity();
          await appState.loadNotifications();
        },
        child: appState.trips.isEmpty
            ? ListView(
                children: [
                  const _AvailableTripsHero(),
                  const SizedBox(height: 24),
                  const Center(
                    child: Text('No trips yet. Create the first one.'),
                  ),
                  const SizedBox(height: 80),
                ],
              )
            : ListView(
                children: [
                  const _AvailableTripsHero(),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Trips Near You',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          _NearbyTripsPreviewCard(
                            currentLocation: _nearbyLocation,
                            trips: _nearbyTrips,
                            isLoading: _loadingNearbyTrips,
                            errorText: _nearbyTripsError,
                            onRetry: _loadNearbyTripsPreview,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _FindATripBar(
                    originLabel: _originFilter?.label ?? 'Anywhere',
                    destinationLabel: _destinationFilter?.label ?? 'Anywhere',
                    departureLabel: _departureDateFilter == null
                        ? 'Any date'
                        : _dateLabel(_departureDateFilter!),
                    onPickOrigin: _pickOriginOnMap,
                    onPickDestination: _pickDestinationOnMap,
                    onPickDepartureDate: _pickDepartureDate,
                    onClearFilters: () {
                      setState(() {
                        _originFilter = null;
                        _destinationFilter = null;
                        _departureDateFilter = null;
                      });
                    },
                  ),
                  const SizedBox(height: 18),
                  if (filteredTrips.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Center(
                        child: Text('No trips match your selected route.'),
                      ),
                    )
                  else
                    ...List.generate(filteredTrips.length, (index) {
                      final trip = filteredTrips[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _TripCard(trip: trip),
                      );
                    }),
                ],
              ),
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  const _TripCard({required this.trip});

  final Trip trip;

  String _formatDeparture(DateTime value) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final local = value.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';

    return '${weekdays[local.weekday - 1]}, ${months[local.month - 1]} ${local.day} • $hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.subtleBorder),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(18),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.originDisplayLabel,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    trip.destinationDisplayLabel,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textInk.withValues(alpha: 0.72),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.secondaryGreen,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.primaryGreen,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _TripDriverAvatar(
                    name: trip.driverName,
                    photoUrl: trip.driverProfilePhotoUrl,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      trip.driverName,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TierBadge(carbonSavedGrams: trip.driverCarbonSavedGrams),
                  if (trip.status != 'open') _StatusChip(status: trip.status),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                trip.driverReviewCount == 0
                    ? 'Fresh driver profile'
                    : 'Rated ${trip.driverAverageRating.toStringAsFixed(1)} • ${trip.driverReviewCount} reviews',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textInk.withValues(alpha: 0.66),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                runSpacing: 8,
                spacing: 8,
                children: [
                  _InfoPill(
                    icon: Icons.schedule_outlined,
                    label: _formatDeparture(trip.departureTime),
                  ),
                  _InfoPill(
                    icon: Icons.event_seat_outlined,
                    label:
                        '${trip.seatsAvailable} seat${trip.seatsAvailable == 1 ? '' : 's'}',
                  ),
                ],
              ),
              if (trip.meetingSpot.isNotEmpty) ...[
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.place_outlined,
                        size: 16,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        trip.meetingSpot,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textInk.withValues(alpha: 0.74),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  _StatusChip(status: trip.status),
                  const Spacer(),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ],
          ),
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => TripDetailScreen(tripId: trip.id),
            ),
          );
        },
      ),
    );
  }
}

enum _TripMenuAction {
  activity,
  notifications,
  profile,
  settings,
  leaderboard,
  logout,
}
class _TripDriverAvatar extends StatelessWidget {
  const _TripDriverAvatar({required this.name, required this.photoUrl});

  final String name;
  final String photoUrl;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        color: AppColors.secondaryGreen,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: photoUrl.isEmpty
          ? Center(
              child: Text(
                initial,
                style: const TextStyle(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          : Image.network(
              photoUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.canvasBackground,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.subtleBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primaryGreen),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textInk.withValues(alpha: 0.78),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _FindATripBar extends StatelessWidget {
  const _FindATripBar({
    required this.originLabel,
    required this.destinationLabel,
    required this.departureLabel,
    required this.onPickOrigin,
    required this.onPickDestination,
    required this.onPickDepartureDate,
    required this.onClearFilters,
  });

  final String originLabel;
  final String destinationLabel;
  final String departureLabel;
  final VoidCallback onPickOrigin;
  final VoidCallback onPickDestination;
  final VoidCallback onPickDepartureDate;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useRow = constraints.maxWidth >= 560;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.subtleBorder),
          ),
          child: useRow
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: _FilterMapButton(
                        label: 'Starting Area',
                        value: originLabel,
                        icon: Icons.trip_origin,
                        onPressed: onPickOrigin,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _FilterMapButton(
                        label: 'Destination Area',
                        value: destinationLabel,
                        icon: Icons.location_on_outlined,
                        onPressed: onPickDestination,
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: onPickDepartureDate,
                      icon: const Icon(Icons.event, size: 20),
                      label: Text(
                        departureLabel,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: onClearFilters,
                      child: const Text('Clear'),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _FilterMapButton(
                      label: 'Starting Area',
                      value: originLabel,
                      icon: Icons.trip_origin,
                      onPressed: onPickOrigin,
                    ),
                    const SizedBox(height: 12),
                    _FilterMapButton(
                      label: 'Destination Area',
                      value: destinationLabel,
                      icon: Icons.location_on_outlined,
                      onPressed: onPickDestination,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onPickDepartureDate,
                            icon: const Icon(Icons.event),
                            label: Text(
                              departureLabel,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: onClearFilters,
                          child: const Text('Clear Filters'),
                        ),
                      ],
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _FilterMapButton extends StatelessWidget {
  const _FilterMapButton({
    required this.label,
    required this.value,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onPressed,
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.subtleBorder),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryGreen),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.textInk.withValues(alpha: 0.66),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.map_outlined, color: AppColors.primaryGreen),
          ],
        ),
      ),
    );
  }
}

class _NearbyTripsPreviewCard extends StatelessWidget {
  const _NearbyTripsPreviewCard({
    required this.currentLocation,
    required this.trips,
    required this.isLoading,
    required this.errorText,
    required this.onRetry,
  });

  final LocationSelection? currentLocation;
  final List<Trip> trips;
  final bool isLoading;
  final String? errorText;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    if (currentLocation == null && isLoading) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          color: AppColors.canvasBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.subtleBorder),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (currentLocation == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.canvasBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.subtleBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              errorText ?? 'Turn on location to see routes passing near you.',
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: isLoading ? null : onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry Location'),
            ),
          ],
        ),
      );
    }

    final allPoints = <LatLng>[
      LatLng(currentLocation!.latitude, currentLocation!.longitude),
    ];
    final segments = trips
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
          allPoints..add(start)..add(end);
          return (trip: trip, start: start, end: end);
        })
        .toList();

    final center = _centerFor(allPoints);
    final zoom = _zoomFor(allPoints);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          trips.isEmpty
              ? 'No active routes are currently passing near ${currentLocation!.label}.'
              : '${trips.length} active route${trips.length == 1 ? '' : 's'} pass near ${currentLocation!.label}.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textInk.withValues(alpha: 0.72),
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 220,
            child: Stack(
              children: [
                FlutterMap(
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
                    if (segments.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          for (var i = 0; i < segments.length; i++)
                            Polyline(
                              points: [segments[i].start, segments[i].end],
                              strokeWidth: 4,
                              color: _nearbyRouteColor(i),
                            ),
                        ],
                      ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(
                            currentLocation!.latitude,
                            currentLocation!.longitude,
                          ),
                          width: 42,
                          height: 42,
                          child: const _MiniAreaMarker(
                            icon: Icons.my_location_rounded,
                            color: AppColors.textInk,
                          ),
                        ),
                        for (var i = 0; i < segments.length; i++) ...[
                          Marker(
                            point: segments[i].start,
                            width: 30,
                            height: 30,
                            child: _MiniAreaMarker(
                              icon: Icons.play_arrow_rounded,
                              color: _nearbyRouteColor(i),
                            ),
                          ),
                          Marker(
                            point: segments[i].end,
                            width: 30,
                            height: 30,
                            child: _MiniAreaMarker(
                              icon: Icons.flag_rounded,
                              color: _nearbyRouteColor(i),
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
                if (isLoading)
                  const Positioned(
                    right: 12,
                    top: 12,
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.2),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
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
      return 9.5;
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

    if (diagonalKm < 25) return 10.2;
    if (diagonalKm < 60) return 9.1;
    if (diagonalKm < 120) return 8.3;
    if (diagonalKm < 250) return 7.3;
    if (diagonalKm < 500) return 6.3;
    if (diagonalKm < 1000) return 5.4;
    return 4.8;
  }

  static Color _nearbyRouteColor(int index) {
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

class _MiniAreaMarker extends StatelessWidget {
  const _MiniAreaMarker({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
      child: Icon(icon, size: 16, color: color),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.icon, required this.label, this.count = 0});

  final IconData icon;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryGreen),
        const SizedBox(width: 12),
        Expanded(child: Text(label)),
        if (count > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primaryAccent,
              borderRadius: BorderRadius.circular(999),
            ),
            constraints: const BoxConstraints(minWidth: 20),
            child: Text(
              count > 99 ? '99+' : '$count',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    switch (status) {
      case 'completed':
        bg = const Color(0xFFD8F3DC);
        fg = const Color(0xFF2D6A4F);
      case 'cancelled':
        bg = const Color(0xFFF8D7DA);
        fg = const Color(0xFF7A1C1C);
      case 'full':
        bg = const Color(0xFFFFE8B5);
        fg = AppColors.textInk;
      default:
        bg = AppColors.secondaryGreen;
        fg = AppColors.textInk;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _AvailableTripsHero extends StatelessWidget {
  const _AvailableTripsHero();

  @override
  Widget build(BuildContext context) {
    const tagline =
        'Carpool to thousands of destinations at low prices';
    const heroHeight = 200.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final useRow = constraints.maxWidth >= 500;
        return SizedBox(
          height: heroHeight,
          child: useRow
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 24, 24, 24),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            tagline,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryGreen,
                                  height: 1.2,
                                ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            'assets/carpool_hero.png',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 24, 0, 12),
                      child: Text(
                        tagline,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGreen,
                              height: 1.2,
                            ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            'assets/carpool_hero.png',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
