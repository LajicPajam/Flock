import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/request_summary.dart';
import '../models/trip.dart' show Trip, formatDepartureTime;
import '../state/app_state.dart';
import '../theme/app_colors.dart';
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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(18),
        title: _RouteHeader(
          origin: trip.originDisplayLabel,
          destination: trip.destinationDisplayLabel,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formatDepartureTime(trip.departureTime),
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _StatusPill(label: trip.status.toUpperCase()),
                  const SizedBox(width: 8),
                  _MutedPill(
                    icon: Icons.event_seat_outlined,
                    label:
                        '${trip.seatsAvailable} seat${trip.seatsAvailable == 1 ? '' : 's'}',
                  ),
                ],
              ),
              if (trip.meetingSpot.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  'Meet: ${trip.meetingSpot}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textInk.withValues(alpha: 0.72),
                  ),
                ),
              ],
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

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request});

  final RequestSummary request;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(18),
        title: _RouteHeader(
          origin: request.originDisplayLabel,
          destination: request.destinationDisplayLabel,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                request.driverName ?? 'Driver',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _StatusPill(label: request.status.toUpperCase()),
                  _MutedPill(
                    icon: Icons.flag_outlined,
                    label: request.tripStatus.toUpperCase(),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                formatDepartureTime(request.departureTime),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textInk.withValues(alpha: 0.72),
                  fontWeight: FontWeight.w600,
                ),
              ),
              if ((request.meetingSpot ?? '').isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  'Meet: ${request.meetingSpot}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textInk.withValues(alpha: 0.72),
                  ),
                ),
              ],
            ],
          ),
        ),
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

class _RouteHeader extends StatelessWidget {
  const _RouteHeader({required this.origin, required this.destination});

  final String origin;
  final String destination;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            origin,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.secondaryGreen,
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Icon(
            Icons.arrow_forward_rounded,
            color: AppColors.primaryGreen,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            destination,
            textAlign: TextAlign.right,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.secondaryGreen,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primaryGreen,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _MutedPill extends StatelessWidget {
  const _MutedPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.canvasBackground,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.subtleBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primaryGreen),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textInk.withValues(alpha: 0.78),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
