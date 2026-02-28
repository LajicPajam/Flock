import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/city.dart';
import '../models/trip.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import 'messages_screen.dart';
import 'ui_shell.dart';

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
                                Text('Driver: ${trip.driverName}'),
                                Text('Phone: ${trip.driverPhoneNumber}'),
                              ],
                            ),
                          ),
                        ],
                      ),
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
                        const SizedBox(height: 12),
                        if (trip.viewerRequest == null) ...[
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
                        ] else
                          Text(trip.viewerRequest!.message),
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
                                        if (request.status == 'pending')
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
