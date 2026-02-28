import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/city.dart';
import '../models/ride_request.dart';
import '../models/trip.dart' show Trip, formatDepartureTime;
import '../state/app_state.dart';
import 'create_trip_screen.dart';
import 'leave_review_screen.dart';
import '../theme/app_colors.dart';
import '../utils/phone_formatter.dart';
import '../widgets/tier_badge.dart';
import 'messages_screen.dart';
import 'ui_shell.dart';
import 'user_reviews_screen.dart';

class TripDetailScreen extends StatefulWidget {
  const TripDetailScreen({super.key, required this.tripId});

  final int tripId;

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  final _requestController = TextEditingController();
  late Future<Trip> _tripFuture;
  late final Timer _clockTimer;
  DateTime _now = DateTime.now();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _tripFuture = context.read<AppState>().loadTripDetail(widget.tripId);
    _clockTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    _requestController.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    setState(() {
      _tripFuture = context.read<AppState>().loadTripDetail(widget.tripId);
    });
  }

  Future<void> _requestSeat() async {
    if (_requestController.text.trim().length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a short note before requesting.')),
      );
      return;
    }

    setState(() {
      _submitting = true;
    });

    try {
      await context.read<AppState>().requestSeat(
        tripId: widget.tripId,
        message: _requestController.text.trim(),
      );
      _requestController.clear();
      await _reload();
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
          _submitting = false;
        });
      }
    }
  }

  Future<void> _updateRequest(int requestId, bool accept) async {
    try {
      if (accept) {
        await context.read<AppState>().acceptRequest(requestId);
      } else {
        await context.read<AppState>().rejectRequest(requestId);
      }
      await _reload();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  Future<void> _withdrawRequest(int requestId) async {
    try {
      await context.read<AppState>().withdrawRequest(requestId);
      await _reload();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  Future<void> _cancelTrip(int tripId) async {
    try {
      await context.read<AppState>().cancelTrip(tripId);
      await _reload();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  Future<void> _completeTrip(int tripId) async {
    try {
      await context.read<AppState>().completeTrip(tripId);
      await _reload();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  Future<void> _openReview({
    required int revieweeId,
    required String revieweeName,
  }) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => LeaveReviewScreen(
          tripId: widget.tripId,
          revieweeId: revieweeId,
          revieweeName: revieweeName,
        ),
      ),
    );

    if (result == true && mounted) {
      await _reload();
    }
  }

  Future<void> _editTrip(Trip trip) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => CreateTripScreen(existingTrip: trip)),
    );

    if (!mounted) {
      return;
    }

    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return UiShell(
      title: 'Trip Details',
      child: FutureBuilder<Trip>(
        future: _tripFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return ListView(
              children: [
                Text(snapshot.error.toString().replaceFirst('Exception: ', '')),
                const SizedBox(height: 12),
                OutlinedButton(onPressed: _reload, child: const Text('Retry')),
              ],
            );
          }

          final trip = snapshot.data!;
          final isDriver = appState.currentUser?.id == trip.driverId;
          final requestAccepted = trip.viewerRequest?.isAccepted ?? false;
          final canOpenMessages = isDriver || requestAccepted;
          final canRequestSeat =
              !isDriver &&
              trip.viewerRequest == null &&
              !trip.isCancelled &&
              !trip.isFull;
          final tripInPast = trip.departureTime.toLocal().isBefore(
            DateTime.now(),
          );
          final canViewCarInfo =
              trip.driverCarMake.isNotEmpty ||
              trip.driverCarModel.isNotEmpty ||
              trip.driverCarPlateNumber.isNotEmpty;

          final origin = CollegeCity.fromApiValue(trip.originCity);
          final destination = CollegeCity.fromApiValue(trip.destinationCity);
          final estimatedArrival = _estimateArrival(trip);

          return ListView(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              origin.label,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
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
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              destination.label,
                              textAlign: TextAlign.right,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Departure: ${formatDepartureTime(trip.departureTime)}'),
                      Text(
                        'Estimated arrival: ${formatDepartureTime(estimatedArrival)}',
                      Text(
                        'Departure: ${formatDepartureTime(trip.departureTime)}',
                      ),
                      Text('Seats available: ${trip.seatsAvailable}'),
                      Text('Status: ${trip.status.toUpperCase()}'),
                      Text(_etaLabel(estimatedArrival, trip.status)),
                      if (!isDriver && trip.driverReviewCount > 0)
                        Text(
                          'Driver rating: ${trip.driverAverageRating.toStringAsFixed(1)} (${trip.driverReviewCount} reviews)',
                        ),
                      if (isDriver) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            OutlinedButton.icon(
                              onPressed: trip.isCancelled
                                  ? null
                                  : () => _editTrip(trip),
                              icon: const Icon(Icons.edit),
                              label: const Text('Edit This Trip'),
                            ),
                            FilledButton.tonalIcon(
                              onPressed: trip.isCancelled
                                  ? null
                                  : () => _cancelTrip(trip.id),
                              icon: const Icon(Icons.cancel_outlined),
                              label: const Text('Cancel Trip'),
                            ),
                            FilledButton.tonalIcon(
                              onPressed:
                                  trip.isCancelled ||
                                      trip.isCompleted ||
                                      !tripInPast
                                  ? null
                                  : () => _completeTrip(trip.id),
                              icon: const Icon(Icons.check_circle_outline),
                              label: const Text('Mark Completed'),
                            ),
                          ],
                        ),
                      ],
                      if (trip.meetingSpot.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text('Meeting spot: ${trip.meetingSpot}'),
                      ],
                      if (trip.notes.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text('Notes: ${trip.notes}'),
                      ],
                      const SizedBox(height: 12),
                      _TripTimelineCard(
                        origin: origin,
                        destination: destination,
                        departureTime: trip.departureTime.toLocal(),
                        arrivalTime: estimatedArrival.toLocal(),
                      ),
                      const Divider(height: 24),
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: trip.driverProfilePhotoUrl.isEmpty
                                ? null
                                : NetworkImage(trip.driverProfilePhotoUrl),
                            child: trip.driverProfilePhotoUrl.isEmpty
                                ? const Icon(Icons.person)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 8,
                                  children: [
                                    Text('Driver: ${trip.driverName}'),
                                    TierBadge(
                                      carbonSavedGrams:
                                          trip.driverCarbonSavedGrams,
                                    ),
                                  ],
                                ),
                                Text(
                                  'Phone: ${formatPhoneNumber(trip.driverPhoneNumber)}',
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => UserReviewsScreen(
                                    userId: trip.driverId,
                                    title: '${trip.driverName} Reviews',
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.star_outline),
                            tooltip: 'View Reviews',
                          ),
                        ],
                      ),
                      if (canViewCarInfo) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Car: ${trip.driverCarColor} ${trip.driverCarMake} ${trip.driverCarModel}'
                              .trim(),
                        ),
                        Text(
                          'Plate: ${trip.driverCarPlateState} ${trip.driverCarPlateNumber}'
                              .trim(),
                        ),
                        if (trip.driverCarDescription.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text('Vehicle notes: ${trip.driverCarDescription}'),
                        ],
                      ] else if (!isDriver) ...[
                        const SizedBox(height: 12),
                        const Text(
                          'Vehicle details unlock after your ride request is accepted.',
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (!isDriver) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trip.viewerRequest == null
                              ? 'Request a Seat'
                              : 'Request Status: ${trip.viewerRequest!.status}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (trip.viewerRequest == null && trip.isCancelled) ...[
                          const SizedBox(height: 12),
                          const Text('This trip has been cancelled.'),
                        ] else if (trip.viewerRequest == null &&
                            trip.isFull) ...[
                          const SizedBox(height: 12),
                          const Text('This trip is currently full.'),
                        ],
                        const SizedBox(height: 12),
                        if (canRequestSeat) ...[
                          TextField(
                            controller: _requestController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Short note to the driver',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: _submitting ? null : _requestSeat,
                              child: Text(
                                _submitting ? 'Sending...' : 'Request Seat',
                              ),
                            ),
                          ),
                        ],
                        if (!canRequestSeat && trip.viewerRequest != null) ...[
                          Text(trip.viewerRequest!.message),
                          if (trip.viewerRequest!.status != 'rejected' &&
                              !tripInPast) ...[
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: () =>
                                  _withdrawRequest(trip.viewerRequest!.id),
                              child: const Text('Withdraw Request'),
                            ),
                          ],
                        ],
                        if (requestAccepted && tripInPast) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.tonal(
                              onPressed: () => _openReview(
                                revieweeId: trip.driverId,
                                revieweeName: trip.driverName,
                              ),
                              child: const Text('Leave Driver Review'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (isDriver) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ride Requests',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        if (trip.rideRequests.isEmpty)
                          const Text('No requests yet.')
                        else
                          ...trip.rideRequests.map(
                            (request) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.subtleBorder,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _PassengerHoverName(request: request),
                                    Text(request.message),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      children: [
                                        Chip(label: Text(request.status)),
                                        IconButton(
                                          onPressed: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute<void>(
                                                builder: (_) => UserReviewsScreen(
                                                  userId: request.riderId,
                                                  title:
                                                      '${request.riderName ?? 'Rider'} Reviews',
                                                ),
                                              ),
                                            );
                                          },
                                          icon: const Icon(Icons.star_outline),
                                          tooltip: 'View Reviews',
                                        ),
                                        if (request.status == 'pending' &&
                                            !trip.isCancelled &&
                                            !trip.isFull)
                                          FilledButton.tonal(
                                            onPressed: () => _updateRequest(
                                              request.id,
                                              true,
                                            ),
                                            child: const Text('Accept'),
                                          ),
                                        if (request.status == 'pending')
                                          OutlinedButton(
                                            onPressed: () => _updateRequest(
                                              request.id,
                                              false,
                                            ),
                                            child: const Text('Reject'),
                                          ),
                                        if (request.status == 'accepted' &&
                                            tripInPast)
                                          FilledButton.tonal(
                                            onPressed: () => _openReview(
                                              revieweeId: request.riderId,
                                              revieweeName:
                                                  request.riderName ?? 'Rider',
                                            ),
                                            child: const Text('Leave Review'),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (canOpenMessages)
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => MessagesScreen(
                          tripId: trip.id,
                          tripDriverId: trip.driverId,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.message),
                  label: const Text('Open Messages'),
                ),
            ],
          );
        },
      ),
    );
  }

  DateTime _estimateArrival(Trip trip) {
    final hours = _estimateRouteHours(trip.originCity, trip.destinationCity);
    return trip.departureTime.toLocal().add(Duration(minutes: (hours * 60).round()));
  }

  String _etaLabel(DateTime estimatedArrival, String status) {
    if (status == 'cancelled') {
      return 'ETA unavailable: trip cancelled';
    }
    if (status == 'completed') {
      return 'Arrived (trip completed)';
    }

    final diff = estimatedArrival.difference(_now);
    if (diff.inMinutes >= 0) {
      final hours = diff.inHours;
      final minutes = diff.inMinutes % 60;
      return 'ETA update: arrives in ${hours}h ${minutes}m';
    }

    final passed = _now.difference(estimatedArrival);
    if (passed.inMinutes < 15) {
      return 'ETA update: arriving now';
    }
    return 'ETA update: arrived ${passed.inHours}h ${passed.inMinutes % 60}m ago';
  }
}

double _estimateRouteHours(String originApiValue, String destinationApiValue) {
  const routeHours = <String, double>{
    'provo_ut|logan_ut': 1.5,
    'provo_ut|salt_lake_city_ut': 1.0,
    'provo_ut|rexburg_id': 4.5,
    'provo_ut|tempe_az': 10.0,
    'logan_ut|salt_lake_city_ut': 1.5,
    'logan_ut|rexburg_id': 4.0,
    'logan_ut|tempe_az': 11.0,
    'salt_lake_city_ut|rexburg_id': 3.5,
    'salt_lake_city_ut|tempe_az': 10.0,
    'rexburg_id|tempe_az': 14.0,
  };

  final direct = '$originApiValue|$destinationApiValue';
  final reverse = '$destinationApiValue|$originApiValue';
  return routeHours[direct] ?? routeHours[reverse] ?? 6.0;
}

String _shortCityLabel(CollegeCity city) {
  return city.label.split(',').first.trim();
}

String _timelineTime(DateTime dt) {
  final local = dt.toLocal();
  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  final period = local.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $period';
}

class _TripTimelineCard extends StatelessWidget {
  const _TripTimelineCard({
    required this.origin,
    required this.destination,
    required this.departureTime,
    required this.arrivalTime,
  });

  final CollegeCity origin;
  final CollegeCity destination;
  final DateTime departureTime;
  final DateTime arrivalTime;

  @override
  Widget build(BuildContext context) {
    final total = arrivalTime.difference(departureTime).inMinutes;
    final firstStopTime = departureTime.add(
      Duration(minutes: (total * 0.38).round()),
    );
    final secondStopTime = departureTime.add(
      Duration(minutes: (total * 0.72).round()),
    );

    final stops = <_TimelineStop>[
      _TimelineStop(
        icon: Icons.place_outlined,
        label: _shortCityLabel(origin),
        subtitle: 'Departure',
        time: departureTime,
      ),
      _TimelineStop(
        icon: Icons.local_cafe_outlined,
        label: 'Coffee Stop',
        subtitle: 'Quick recharge',
        time: firstStopTime,
      ),
      _TimelineStop(
        icon: Icons.restaurant_outlined,
        label: 'Meal Stop',
        subtitle: 'Stretch and refuel',
        time: secondStopTime,
      ),
      _TimelineStop(
        icon: Icons.terrain_outlined,
        label: _shortCityLabel(destination),
        subtitle: 'Arrival',
        time: arrivalTime,
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.subtleBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trip Timeline',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ...stops.asMap().entries.map((entry) {
            final index = entry.key;
            final stop = entry.value;
            return _TimelineRow(
              stop: stop,
              isLast: index == stops.length - 1,
            );
          }),
          const SizedBox(height: 6),
          Text(
            'Estimated arrival updates every minute.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _TimelineStop {
  const _TimelineStop({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.time,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final DateTime time;
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.stop, required this.isLast});

  final _TimelineStop stop;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Icon(stop.icon, size: 18),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 24,
                    margin: const EdgeInsets.only(top: 4),
                    color: AppColors.subtleBorder,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${stop.label} - ${_timelineTime(stop.time)}\n${stop.subtitle}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _PassengerHoverName extends StatelessWidget {
  const _PassengerHoverName({required this.request});

  final RideRequest request;

  String _valueOrFallback(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? 'Not provided' : trimmed;
  }

  @override
  Widget build(BuildContext context) {
    final riderName = request.riderName ?? 'Rider';
    final ratingValue = request.riderAverageRating ?? 0;
    final rating =
        ratingValue > 0 ? ratingValue.toStringAsFixed(1) : 'No ratings yet';
    final cardText = [
      'Major: ${_valueOrFallback(request.riderMajor)}',
      'Year: ${_valueOrFallback(request.riderAcademicYear)}',
      'Vibe: ${_valueOrFallback(request.riderVibe)}',
      'Rating: $rating',
      'Favorite playlist: ${_valueOrFallback(request.riderFavoritePlaylist)}',
    ].join('\n');

    return Tooltip(
      message: cardText,
      waitDuration: const Duration(milliseconds: 180),
      showDuration: const Duration(seconds: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      textStyle: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        height: 1.35,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            riderName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 6),
          Icon(
            Icons.info_outline,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
