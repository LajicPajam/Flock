import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/city.dart';
import '../models/request_summary.dart';
import '../models/trip.dart';
import '../state/app_state.dart';
import 'trip_detail_screen.dart';
import 'ui_shell.dart';

class MyActivityScreen extends StatefulWidget {
  const MyActivityScreen({super.key});

  @override
  State<MyActivityScreen> createState() => _MyActivityScreenState();
}

class _MyActivityScreenState extends State<MyActivityScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().loadActivity();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final upcomingTrips = appState.myTrips
        .where((trip) => !trip.isHistory)
        .toList();
    final tripHistory = appState.myTrips
        .where((trip) => trip.isHistory)
        .toList();
    final upcomingRequests = appState.myRequests
        .where((request) => !request.isHistory)
        .toList();
    final requestHistory = appState.myRequests
        .where((request) => request.isHistory)
        .toList();

    return DefaultTabController(
      length: 2,
      child: UiShell(
        title: 'My Activity',
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'My Trips'),
                Tab(text: 'My Requests'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  RefreshIndicator(
                    onRefresh: appState.loadActivity,
                    child: appState.myTrips.isEmpty
                        ? ListView(
                            children: const [
                              SizedBox(height: 80),
                              Center(
                                child: Text(
                                  'You have not posted any trips yet.',
                                ),
                              ),
                            ],
                          )
                        : ListView(
                            children: [
                              _SectionHeader(title: 'Upcoming'),
                              if (upcomingTrips.isEmpty)
                                const _EmptySection(
                                  message:
                                      'No upcoming trips you are driving right now.',
                                ),
                              ...upcomingTrips.map(
                                (trip) => _TripCard(trip: trip),
                              ),
                              _SectionHeader(title: 'History'),
                              if (tripHistory.isEmpty)
                                const _EmptySection(
                                  message:
                                      'Completed, cancelled, and past trips show up here.',
                                ),
                              ...tripHistory.map(
                                (trip) => _TripCard(trip: trip),
                              ),
                            ],
                          ),
                  ),
                  RefreshIndicator(
                    onRefresh: appState.loadActivity,
                    child: appState.myRequests.isEmpty
                        ? ListView(
                            children: const [
                              SizedBox(height: 80),
                              Center(
                                child: Text(
                                  'You have not requested any rides yet.',
                                ),
                              ),
                            ],
                          )
                        : ListView(
                            children: [
                              _SectionHeader(title: 'Upcoming'),
                              if (upcomingRequests.isEmpty)
                                const _EmptySection(
                                  message:
                                      'No active ride requests at the moment.',
                                ),
                              ...upcomingRequests.map(
                                (request) => _RequestCard(request: request),
                              ),
                              _SectionHeader(title: 'History'),
                              if (requestHistory.isEmpty)
                                const _EmptySection(
                                  message:
                                      'Past, cancelled, and completed requests show up here.',
                                ),
                              ...requestHistory.map(
                                (request) => _RequestCard(request: request),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _EmptySection extends StatelessWidget {
  const _EmptySection({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(message),
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
        title: Text('${origin.label} -> ${destination.label}'),
        subtitle: Text(
          '${trip.departureTime.toLocal()}\n${trip.status.toUpperCase()} | ${trip.seatsAvailable} seats left${trip.meetingSpot.isEmpty ? '' : '\nMeet: ${trip.meetingSpot}'}',
        ),
        isThreeLine: true,
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

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request});

  final RequestSummary request;

  @override
  Widget build(BuildContext context) {
    final origin = CollegeCity.fromApiValue(request.originCity);
    final destination = CollegeCity.fromApiValue(request.destinationCity);

    return Card(
      child: ListTile(
        title: Text('${origin.label} -> ${destination.label}'),
        subtitle: Text(
          'Driver: ${request.driverName ?? 'Driver'}\n${request.status.toUpperCase()} | ${request.tripStatus.toUpperCase()}${(request.meetingSpot ?? '').isEmpty ? '' : '\nMeet: ${request.meetingSpot}'}',
        ),
        isThreeLine: true,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => TripDetailScreen(tripId: request.tripId),
            ),
          );
        },
      ),
    );
  }
}
