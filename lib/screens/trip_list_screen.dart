import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/city.dart';
import '../models/trip.dart' show Trip;
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = context.read<AppState>();
      appState.loadTrips();
      appState.loadActivity();
      appState.loadNotifications();
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
        },
        icon: const Icon(Icons.add),
        label: const Text('Create Trip'),
      ),
      child: RefreshIndicator(
        onRefresh: () async {
          final appState = context.read<AppState>();
          await appState.loadTrips();
          await appState.loadActivity();
          await appState.loadNotifications();
        },
        child: appState.trips.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: 80),
                  Center(child: Text('No trips yet. Create the first one.')),
                ],
              )
            : ListView(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Find a Trip',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          _FilterMapButton(
                            label: 'Starting Area',
                            value: _originFilter?.label ?? 'Anywhere',
                            icon: Icons.trip_origin,
                            onPressed: _pickOriginOnMap,
                          ),
                          const SizedBox(height: 12),
                          _FilterMapButton(
                            label: 'Destination Area',
                            value: _destinationFilter?.label ?? 'Anywhere',
                            icon: Icons.location_on_outlined,
                            onPressed: _pickDestinationOnMap,
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _pickDepartureDate,
                              icon: const Icon(Icons.event),
                              label: Text(
                                _departureDateFilter == null
                                    ? 'Any departure date'
                                    : 'Leaving: ${_dateLabel(_departureDateFilter!)}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  _originFilter = null;
                                  _destinationFilter = null;
                                  _departureDateFilter = null;
                                });
                              },
                              child: const Text('Clear Filters'),
                            ),
                          ),
                        ],
                      ),
                    ),
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

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.icon, required this.label, this.count = 0});

  final IconData icon;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20),
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
