import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/city.dart';
import '../state/app_state.dart';
import 'ui_shell.dart';

class CreateTripScreen extends StatefulWidget {
  const CreateTripScreen({super.key});

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _seatsController = TextEditingController(text: '3');
  CollegeCity _origin = CollegeCity.provoUt;
  CollegeCity _destination = CollegeCity.loganUt;
  DateTime _departure = DateTime.now().add(const Duration(days: 1));
  bool _saving = false;

  @override
  void dispose() {
    _notesController.dispose();
    _seatsController.dispose();
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
        const SnackBar(content: Text('Origin and destination must be different.')),
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      await context.read<AppState>().createTrip(
            originCity: _origin.apiValue,
            destinationCity: _destination.apiValue,
            departureTime: _departure,
            seatsAvailable: int.parse(_seatsController.text),
            notes: _notesController.text.trim(),
          );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return UiShell(
      title: 'Create Trip',
      child: ListView(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<CollegeCity>(
                      initialValue: _origin,
                      decoration: const InputDecoration(
                        labelText: 'Origin',
                        border: OutlineInputBorder(),
                      ),
                      items: CollegeCity.values
                          .map(
                            (city) => DropdownMenuItem(
                              value: city,
                              child: Text(city.label),
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
                      decoration: const InputDecoration(
                        labelText: 'Destination',
                        border: OutlineInputBorder(),
                      ),
                      items: CollegeCity.values
                          .map(
                            (city) => DropdownMenuItem(
                              value: city,
                              child: Text(city.label),
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
                    OutlinedButton.icon(
                      onPressed: _pickDeparture,
                      icon: const Icon(Icons.schedule),
                      label: Text('Departure: ${_departure.toLocal()}'),
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
                        child: Text(_saving ? 'Saving...' : 'Post Trip'),
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
