import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/city.dart';
import '../models/trip.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import 'map_picker_screen.dart';
import 'ui_shell.dart';

class CreateTripScreen extends StatefulWidget {
  const CreateTripScreen({super.key, this.existingTrip});

  final Trip? existingTrip;

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _driverFormKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _meetingSpotController = TextEditingController();
  final _seatsController = TextEditingController(text: '3');
  final _carMakeController = TextEditingController();
  final _carModelController = TextEditingController();
  final _carColorController = TextEditingController();
  final _carPlateStateController = TextEditingController();
  final _carPlateNumberController = TextEditingController();
  final _carDescriptionController = TextEditingController();
  LocationSelection _origin = LocationSelection.fromCity(CollegeCity.provoUt);
  LocationSelection _destination = LocationSelection.fromCity(
    CollegeCity.loganUt,
  );
  DateTime _departure = DateTime.now().add(const Duration(days: 1));
  bool _saving = false;
  bool _savingDriverProfile = false;

  bool get _isEditing => widget.existingTrip != null;

  String get _departureLabel {
    final month = _monthName(_departure.month);
    final hour = _departure.hour % 12 == 0 ? 12 : _departure.hour % 12;
    final minute = _departure.minute.toString().padLeft(2, '0');
    final period = _departure.hour >= 12 ? 'PM' : 'AM';
    return '$month ${_departure.day}, ${_departure.year} at $hour:$minute $period';
  }

  String _monthName(int month) {
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
    return months[month - 1];
  }

  @override
  void initState() {
    super.initState();
    final existingTrip = widget.existingTrip;
    if (existingTrip != null) {
      final originCity = CollegeCity.fromApiValue(existingTrip.originCity);
      final destinationCity = CollegeCity.fromApiValue(
        existingTrip.destinationCity,
      );
      _origin = LocationSelection(
        city: originCity,
        label: existingTrip.originDisplayLabel,
        latitude: existingTrip.originLatitude ?? originCity.latitude,
        longitude: existingTrip.originLongitude ?? originCity.longitude,
      );
      _destination = LocationSelection(
        city: destinationCity,
        label: existingTrip.destinationDisplayLabel,
        latitude: existingTrip.destinationLatitude ?? destinationCity.latitude,
        longitude:
            existingTrip.destinationLongitude ?? destinationCity.longitude,
      );
      _departure = existingTrip.departureTime.toLocal();
      _seatsController.text = existingTrip.seatsAvailable.toString();
      _meetingSpotController.text = existingTrip.meetingSpot;
      _notesController.text = existingTrip.notes;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _meetingSpotController.dispose();
    _seatsController.dispose();
    _carMakeController.dispose();
    _carModelController.dispose();
    _carColorController.dispose();
    _carPlateStateController.dispose();
    _carPlateNumberController.dispose();
    _carDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDeparture() async {
    final pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: _departure,
    );

    if (pickedDate == null || !mounted) {
      return;
    }

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_departure),
    );

    if (pickedTime == null) {
      return;
    }

    setState(() {
      _departure = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  Future<void> _pickOriginOnMap() async {
    final selection = await Navigator.of(context).push<LocationSelection>(
      MaterialPageRoute(
        builder: (_) => MapPickerScreen(
          title: 'Pick Starting Point',
          initialSelection: _origin,
        ),
      ),
    );

    if (selection == null || !mounted) {
      return;
    }

    setState(() {
      _origin = selection;
    });
  }

  Future<void> _pickDestinationOnMap() async {
    final selection = await Navigator.of(context).push<LocationSelection>(
      MaterialPageRoute(
        builder: (_) => MapPickerScreen(
          title: 'Pick Destination',
          initialSelection: _destination,
        ),
      ),
    );

    if (selection == null || !mounted) {
      return;
    }

    setState(() {
      _destination = selection;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_origin.apiValue == _destination.apiValue &&
        CollegeCity.distanceKmBetween(
              _origin.latitude,
              _origin.longitude,
              _destination.latitude,
              _destination.longitude,
            ) <
            1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Origin and destination must be different.'),
        ),
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final appState = context.read<AppState>();
      if (_isEditing) {
        await appState.updateTrip(
          tripId: widget.existingTrip!.id,
          originCity: _origin.apiValue,
          destinationCity: _destination.apiValue,
          originLabel: _origin.label,
          destinationLabel: _destination.label,
          originLatitude: _origin.latitude,
          originLongitude: _origin.longitude,
          destinationLatitude: _destination.latitude,
          destinationLongitude: _destination.longitude,
          departureTime: _departure,
          seatsAvailable: int.parse(_seatsController.text),
          meetingSpot: _meetingSpotController.text.trim(),
          notes: _notesController.text.trim(),
        );
      } else {
        await appState.createTrip(
          originCity: _origin.apiValue,
          destinationCity: _destination.apiValue,
          originLabel: _origin.label,
          destinationLabel: _destination.label,
          originLatitude: _origin.latitude,
          originLongitude: _origin.longitude,
          destinationLatitude: _destination.latitude,
          destinationLongitude: _destination.longitude,
          departureTime: _departure,
          seatsAvailable: int.parse(_seatsController.text),
          meetingSpot: _meetingSpotController.text.trim(),
          notes: _notesController.text.trim(),
        );
      }
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
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
          _saving = false;
        });
      }
    }
  }

  Future<void> _saveDriverProfile() async {
    if (!_driverFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _savingDriverProfile = true;
    });

    try {
      await context.read<AppState>().saveDriverProfile(
        carMake: _carMakeController.text.trim(),
        carModel: _carModelController.text.trim(),
        carColor: _carColorController.text.trim(),
        carPlateState: _carPlateStateController.text.trim(),
        carPlateNumber: _carPlateNumberController.text.trim(),
        carDescription: _carDescriptionController.text.trim(),
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Driver profile saved. You can post trips now.'),
        ),
      );
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
          _savingDriverProfile = false;
        });
      }
    }
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) =>
          value == null || value.trim().isEmpty ? 'Enter $label.' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AppState>().currentUser;
    final isDriver = currentUser?.isDriver ?? false;

    return UiShell(
      title: _isEditing ? 'Edit Trip' : 'Create Trip',
      child: ListView(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: !isDriver && !_isEditing
                  ? Form(
                      key: _driverFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Become a Driver First',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Before posting a trip, add the vehicle details riders will use to identify you at pickup.',
                          ),
                          const SizedBox(height: 16),
                          _buildField(
                            controller: _carMakeController,
                            label: 'Car Make',
                          ),
                          const SizedBox(height: 12),
                          _buildField(
                            controller: _carModelController,
                            label: 'Car Model',
                          ),
                          const SizedBox(height: 12),
                          _buildField(
                            controller: _carColorController,
                            label: 'Car Color',
                          ),
                          const SizedBox(height: 12),
                          _buildField(
                            controller: _carPlateStateController,
                            label: 'Plate State',
                          ),
                          const SizedBox(height: 12),
                          _buildField(
                            controller: _carPlateNumberController,
                            label: 'Plate Number',
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _carDescriptionController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Vehicle Notes (optional)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: _savingDriverProfile
                                  ? null
                                  : _saveDriverProfile,
                              child: Text(
                                _savingDriverProfile
                                    ? 'Saving...'
                                    : 'Save Driver Profile',
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryGreen,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.subtleBorder),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${currentUser?.carColor ?? ''} ${currentUser?.carMake ?? ''} ${currentUser?.carModel ?? ''}'
                                      .trim(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${currentUser?.carPlateState ?? ''} ${currentUser?.carPlateNumber ?? ''}'
                                      .trim(),
                                ),
                                if ((currentUser?.carDescription ?? '')
                                    .isNotEmpty)
                                  Text(currentUser!.carDescription!),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          _MapFieldButton(
                            label: 'Origin',
                            value: _origin.label,
                            icon: Icons.trip_origin,
                            onPressed: _pickOriginOnMap,
                          ),
                          const SizedBox(height: 12),
                          _MapFieldButton(
                            label: 'Destination',
                            value: _destination.label,
                            icon: Icons.location_on_outlined,
                            onPressed: _pickDestinationOnMap,
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: _pickDeparture,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.schedule),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Departure: $_departureLabel',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _seatsController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Seats Available',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              final parsed = int.tryParse(value ?? '');
                              final minimumSeats = _isEditing ? 0 : 1;
                              if (parsed == null || parsed < minimumSeats) {
                                return _isEditing
                                    ? 'Enter 0 or more seats.'
                                    : 'Enter at least 1 seat.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _meetingSpotController,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              labelText: 'Meeting Spot (optional)',
                              hintText: 'Library parking lot, south entrance',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _notesController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Notes (optional)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: _saving ? null : _submit,
                              child: Text(
                                _saving
                                    ? 'Saving...'
                                    : _isEditing
                                    ? 'Save Changes'
                                    : 'Post Trip',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapFieldButton extends StatelessWidget {
  const _MapFieldButton({
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
