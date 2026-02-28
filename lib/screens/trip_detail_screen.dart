import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/city.dart';
import '../models/trip.dart';
import '../state/app_state.dart';
import 'create_trip_screen.dart';
import 'leave_review_screen.dart';
import '../theme/app_colors.dart';
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
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _tripFuture = context.read<AppState>().loadTripDetail(widget.tripId);
  }

  @override
  void dispose() {
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

          return ListView(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${origin.label} -> ${destination.label}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text('Departure: ${trip.departureTime.toLocal()}'),
                      Text('Seats available: ${trip.seatsAvailable}'),
                      Text('Status: ${trip.status.toUpperCase()}'),
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
                                Text('Phone: ${trip.driverPhoneNumber}'),
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
                                    Text(
                                      request.riderName ?? 'Rider',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
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
}
