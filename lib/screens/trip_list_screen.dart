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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().loadTrips();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

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
            : ListView.separated(
                itemCount: appState.trips.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final trip = appState.trips[index];
                  return _TripCard(trip: trip);
                },
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
