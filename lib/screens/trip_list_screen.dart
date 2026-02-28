import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/city.dart';
import '../models/trip.dart' show Trip;
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/tier_badge.dart';
import 'create_trip_screen.dart';
import 'my_activity_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'trip_detail_screen.dart';
import 'ui_shell.dart';
import 'welcome_tour_screen.dart';

class TripListScreen extends StatefulWidget {
  const TripListScreen({super.key});

  @override
  State<TripListScreen> createState() => _TripListScreenState();
}

class _TripListScreenState extends State<TripListScreen> {
  CollegeCity? _originFilter;
  CollegeCity? _destinationFilter;
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
      final matchesOrigin =
          _originFilter == null || trip.originCity == _originFilter!.apiValue;
      final matchesDestination =
          _destinationFilter == null ||
          trip.destinationCity == _destinationFilter!.apiValue;
      final matchesDepartureDate =
          _departureDateFilter == null ||
          _isSameDay(trip.departureTime.toLocal(), _departureDateFilter!);
      return matchesOrigin && matchesDestination && matchesDepartureDate;
    }).toList();
  }

  bool _isSameDay(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
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
                          DropdownButtonFormField<CollegeCity?>(
                            initialValue: _originFilter,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Starting City',
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              const DropdownMenuItem<CollegeCity?>(
                                value: null,
                                child: Text('Any origin'),
                              ),
                              ...CollegeCity.values.map(
                                (city) => DropdownMenuItem<CollegeCity?>(
                                  value: city,
                                  child: Text(
                                    city.label,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _originFilter = value;
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<CollegeCity?>(
                            initialValue: _destinationFilter,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Destination City',
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              const DropdownMenuItem<CollegeCity?>(
                                value: null,
                                child: Text('Any destination'),
                              ),
                              ...CollegeCity.values.map(
                                (city) => DropdownMenuItem<CollegeCity?>(
                                  value: city,
                                  child: Text(
                                    city.label,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _destinationFilter = value;
                              });
                            },
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
    final origin = CollegeCity.fromApiValue(trip.originCity);
    final destination = CollegeCity.fromApiValue(trip.destinationCity);

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
                    origin.label,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    destination.label,
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
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.secondaryGreen,
                    child: Text(
                      trip.driverName.trim().isEmpty
                          ? '?'
                          : trip.driverName.trim()[0].toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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

enum _TripMenuAction { activity, notifications, profile, settings, logout }

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
