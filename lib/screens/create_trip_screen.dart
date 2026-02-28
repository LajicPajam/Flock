import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/city.dart';
import '../models/trip.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
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
  final _seatsController = TextEditingController(text: '3');
  final _carMakeController = TextEditingController();
  final _carModelController = TextEditingController();
  final _carColorController = TextEditingController();
  final _carPlateStateController = TextEditingController();
  final _carPlateNumberController = TextEditingController();
  final _carDescriptionController = TextEditingController();
  CollegeCity _origin = CollegeCity.provoUt;
  CollegeCity _destination = CollegeCity.loganUt;
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
      _origin = CollegeCity.fromApiValue(existingTrip.originCity);
      _destination = CollegeCity.fromApiValue(existingTrip.destinationCity);
      _departure = existingTrip.departureTime.toLocal();
      _seatsController.text = existingTrip.seatsAvailable.toString();
      _notesController.text = existingTrip.notes;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_origin == _destination) {
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
          departureTime: _departure,
          seatsAvailable: int.parse(_seatsController.text),
          notes: _notesController.text.trim(),
        );
      } else {
        await appState.createTrip(
          originCity: _origin.apiValue,
          destinationCity: _destination.apiValue,
          departureTime: _departure,
          seatsAvailable: int.parse(_seatsController.text),
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
                          DropdownButtonFormField<CollegeCity>(
                            initialValue: _origin,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Origin',
                              border: OutlineInputBorder(),
                            ),
                            selectedItemBuilder: (context) {
                              return CollegeCity.values
                                  .map(
                                    (city) => Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        city.label,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList();
                            },
                            items: CollegeCity.values
                                .map(
                                  (city) => DropdownMenuItem(
                                    value: city,
                                    child: Text(
                                      city.label,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _origin = value;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<CollegeCity>(
                            initialValue: _destination,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Destination',
                              border: OutlineInputBorder(),
                            ),
                            selectedItemBuilder: (context) {
                              return CollegeCity.values
                                  .map(
                                    (city) => Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        city.label,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList();
                            },
                            items: CollegeCity.values
                                .map(
                                  (city) => DropdownMenuItem(
                                    value: city,
                                    child: Text(
                                      city.label,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _destination = value;
                                });
                              }
                            },
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
                              if (parsed == null || parsed < 1) {
                                return 'Enter at least 1 seat.';
                              }
                              return null;
                            },
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
