import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/auth_user.dart';
import '../models/carbon_stats.dart';
import '../state/app_state.dart';
import '../widgets/carbon_progress_bar.dart';
import 'user_reviews_screen.dart';
import 'ui_shell.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _carMakeController = TextEditingController();
  final _carModelController = TextEditingController();
  final _carColorController = TextEditingController();
  final _carPlateStateController = TextEditingController();
  final _carPlateNumberController = TextEditingController();
  final _carDescriptionController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  Uint8List? _photoBytes;
  String? _photoName;
  String? _profilePhotoUrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final appState = context.read<AppState>();
    final user = appState.currentUser;
    if (user != null) {
      _populate(user);
    }
    appState.loadCarbonStats();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _carMakeController.dispose();
    _carModelController.dispose();
    _carColorController.dispose();
    _carPlateStateController.dispose();
    _carPlateNumberController.dispose();
    _carDescriptionController.dispose();
    super.dispose();
  }

  void _populate(AuthUser user) {
    _nameController.text = user.name;
    _phoneController.text = user.phoneNumber;
    _carMakeController.text = user.carMake ?? '';
    _carModelController.text = user.carModel ?? '';
    _carColorController.text = user.carColor ?? '';
    _carPlateStateController.text = user.carPlateState ?? '';
    _carPlateNumberController.text = user.carPlateNumber ?? '';
    _carDescriptionController.text = user.carDescription ?? '';
    _profilePhotoUrl = user.profilePhotoUrl;
  }

  Future<void> _pickPhoto() async {
    final file = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 900,
    );

    if (file == null || !mounted) {
      return;
    }

    final bytes = await file.readAsBytes();
    setState(() {
      _photoBytes = bytes;
      _photoName = file.name;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final appState = context.read<AppState>();

    setState(() {
      _saving = true;
    });

    try {
      var photoUrl = _profilePhotoUrl;

      if (_photoBytes != null && _photoName != null) {
        photoUrl = await appState.uploadProfilePhoto(
          bytes: _photoBytes!,
          fileName: _photoName!,
        );
      }

      if (photoUrl == null || photoUrl.isEmpty) {
        throw Exception('Please choose a profile photo.');
      }

      final driverFields = [
        _carMakeController.text.trim(),
        _carModelController.text.trim(),
        _carColorController.text.trim(),
        _carPlateStateController.text.trim(),
        _carPlateNumberController.text.trim(),
      ];
      final hasAnyDriverField = driverFields.any((value) => value.isNotEmpty);
      final hasAllDriverFields = driverFields.every(
        (value) => value.isNotEmpty,
      );

      if (hasAnyDriverField && !hasAllDriverFields) {
        throw Exception(
          'Fill in all car fields to stay registered as a driver.',
        );
      }

      await appState.updateProfile(
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        profilePhotoUrl: photoUrl,
        carMake: hasAllDriverFields ? driverFields[0] : null,
        carModel: hasAllDriverFields ? driverFields[1] : null,
        carColor: hasAllDriverFields ? driverFields[2] : null,
        carPlateState: hasAllDriverFields ? driverFields[3] : null,
        carPlateNumber: hasAllDriverFields ? driverFields[4] : null,
        carDescription: hasAllDriverFields
            ? _carDescriptionController.text.trim()
            : null,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile updated.')));
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
    final user = context.watch<AppState>().currentUser;
    if (user == null) {
      return const UiShell(
        title: 'Profile',
        child: Center(child: Text('No profile loaded.')),
      );
    }

    final imageProvider = _photoBytes != null
        ? MemoryImage(_photoBytes!)
        : (_profilePhotoUrl != null && _profilePhotoUrl!.isNotEmpty
              ? NetworkImage(_profilePhotoUrl!)
              : null);

    final carbonStats = context.watch<AppState>().carbonStats;

    return UiShell(
      title: 'Your Profile',
      child: ListView(
        children: [
          if (carbonStats != null) ...[
            _CarbonTrackerCard(stats: carbonStats),
            const SizedBox(height: 12),
          ],
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundImage:
                              imageProvider as ImageProvider<Object>?,
                          child: imageProvider == null
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _saving ? null : _pickPhoto,
                            icon: const Icon(Icons.photo_library_outlined),
                            label: Text(
                              _photoName ?? 'Change Photo',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => UserReviewsScreen(
                                userId: user.id,
                                title: 'Your Reviews',
                              ),
                            ),
                          );
                        },
                        child: const Text('View My Reviews'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildField(controller: _nameController, label: 'Name'),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: user.email,
                      enabled: false,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildField(
                      controller: _phoneController,
                      label: 'Phone Number',
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Driver Details (optional)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Fill out all car fields if you want to post trips as a driver.',
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _carMakeController,
                      decoration: const InputDecoration(
                        labelText: 'Car Make',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _carModelController,
                      decoration: const InputDecoration(
                        labelText: 'Car Model',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _carColorController,
                      decoration: const InputDecoration(
                        labelText: 'Car Color',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _carPlateStateController,
                      decoration: const InputDecoration(
                        labelText: 'Plate State',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _carPlateNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Plate Number',
                        border: OutlineInputBorder(),
                      ),
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
                        onPressed: _saving ? null : _save,
                        child: Text(_saving ? 'Saving...' : 'Save Profile'),
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

class _CarbonTrackerCard extends StatelessWidget {
  const _CarbonTrackerCard({required this.stats});

  final CarbonStats stats;

  @override
  Widget build(BuildContext context) {
    final tl = stats.tierLevel;
    final nextTierName = tl.tier.index < CarbonTier.values.length - 1
        ? CarbonTier.values[tl.tier.index + 1].label
        : null;
    final gramsToNext = tl.tierEndGrams - stats.totalCo2SavedGrams;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Carbon Savings',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              '${stats.completedRides} ride${stats.completedRides == 1 ? '' : 's'} completed · '
              '${stats.totalDistanceKm} km carpooled',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            CarbonProgressBar(stats: stats),
            if (nextTierName != null && gramsToNext > 0) ...[
              const SizedBox(height: 12),
              Text(
                '${(gramsToNext / 1000).toStringAsFixed(1)} kg more to reach $nextTierName tier',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
