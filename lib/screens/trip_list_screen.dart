import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/city.dart';
import '../models/trip.dart';
import '../state/app_state.dart';
import '../widgets/tier_badge.dart';
import 'create_trip_screen.dart';
import 'profile_screen.dart';
import 'trip_detail_screen.dart';
import 'ui_shell.dart';

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
      context.read<AppState>().loadTrips();
    });
  }

  List<Trip> _filteredTrips(List<Trip> trips) {
    return trips.where((trip) {
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

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final filteredTrips = _filteredTrips(appState.trips);

    return UiShell(
      title: 'Available Trips',
      actions: [
        IconButton(
          onPressed: () async {
            final appState = context.read<AppState>();
            await Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const ProfileScreen()),
            );
            if (!mounted) {
              return;
            }
            await appState.refreshCurrentUser();
          },
          icon: const Icon(Icons.person),
          tooltip: 'Profile',
        ),
        IconButton(
          onPressed: appState.logout,
          icon: const Icon(Icons.logout),
          tooltip: 'Log out',
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
        onRefresh: () => context.read<AppState>().loadTrips(),
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
                  if (filteredTrips.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 32),
                      child: Center(
                        child: Text('No trips match your selected route.'),
                      ),
                    )
                  else
                    ...List.generate(filteredTrips.length, (index) {
                      final trip = filteredTrips[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
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

  @override
  Widget build(BuildContext context) {
    final origin = CollegeCity.fromApiValue(trip.originCity);
    final destination = CollegeCity.fromApiValue(trip.destinationCity);

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text('${origin.label} -> ${destination.label}'),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                children: [
                  Text('Driver: ${trip.driverName}'),
                  TierBadge(carbonSavedGrams: trip.driverCarbonSavedGrams),
                ],
              ),
              Text('Leaves: ${trip.departureTime.toLocal()}'),
              Text('Seats: ${trip.seatsAvailable}'),
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
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
