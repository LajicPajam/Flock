import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/auth_user.dart';
import '../models/carbon_stats.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../utils/phone_formatter.dart';
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
  final _studentEmailController = TextEditingController();
  final _verificationCodeController = TextEditingController();
  final _majorController = TextEditingController();
  final _academicYearController = TextEditingController();
  final _vibeController = TextEditingController();
  final _favoritePlaylistController = TextEditingController();
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
  bool _sendingStudentCode = false;
  bool _confirmingStudentCode = false;
  String? _devVerificationCode;

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
    _studentEmailController.dispose();
    _verificationCodeController.dispose();
    _majorController.dispose();
    _academicYearController.dispose();
    _vibeController.dispose();
    _favoritePlaylistController.dispose();
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
    _majorController.text = user.major ?? '';
    _academicYearController.text = user.academicYear ?? '';
    _vibeController.text = user.vibe ?? '';
    _favoritePlaylistController.text = user.favoritePlaylist ?? '';
    _phoneController.text = formatPhoneNumber(user.phoneNumber);
    _studentEmailController.text =
        user.pendingStudentEmail ??
        user.studentEmail ??
        (user.email.toLowerCase().endsWith('.edu') ? user.email : '');
    _carMakeController.text = user.carMake ?? '';
    _carModelController.text = user.carModel ?? '';
    _carColorController.text = user.carColor ?? '';
    _carPlateStateController.text = user.carPlateState ?? '';
    _carPlateNumberController.text = user.carPlateNumber ?? '';
    _carDescriptionController.text = user.carDescription ?? '';
    _profilePhotoUrl = user.profilePhotoUrl;
  }

  Future<void> _startStudentVerification() async {
    final studentEmail = _studentEmailController.text.trim().toLowerCase();
    if (studentEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a .edu school email first.')),
      );
      return;
    }

    setState(() {
      _sendingStudentCode = true;
    });

    try {
      final result = await context.read<AppState>().startStudentVerification(
        studentEmail: studentEmail,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _devVerificationCode = result.devVerificationCode;
        if (result.devVerificationCode != null) {
          _verificationCodeController.text = result.devVerificationCode!;
        }
      });

      final message = result.message ?? 'Verification code sent.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
          _sendingStudentCode = false;
        });
      }
    }
  }

  Future<void> _confirmStudentVerification() async {
    final code = _verificationCodeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the verification code first.')),
      );
      return;
    }

    setState(() {
      _confirmingStudentCode = true;
    });

    try {
      final result = await context.read<AppState>().confirmStudentVerification(
        code: code,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _devVerificationCode = null;
        _verificationCodeController.clear();
      });
      _populate(result.user);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message ?? 'Student email verified.'),
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
          _confirmingStudentCode = false;
        });
      }
    }
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
        phoneNumber: digitsOnlyPhone(_phoneController.text),
        profilePhotoUrl: photoUrl,
        major: _majorController.text.trim().isEmpty
            ? null
            : _majorController.text.trim(),
        academicYear: _academicYearController.text.trim().isEmpty
            ? null
            : _academicYearController.text.trim(),
        vibe: _vibeController.text.trim().isEmpty
            ? null
            : _vibeController.text.trim(),
        favoritePlaylist: _favoritePlaylistController.text.trim().isEmpty
            ? null
            : _favoritePlaylistController.text.trim(),
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
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
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
                    Text(
                      'Student Verification',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user.isStudentVerified
                          ? 'Verified student status helps drivers and riders trust who they are coordinating with.'
                          : 'Use any login email you want, then verify a .edu address to earn a student badge tied to your school.',
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: user.isStudentVerified
                            ? AppColors.secondaryGreen
                            : AppColors.canvasBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.subtleBorder),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            user.isStudentVerified
                                ? Icons.verified_rounded
                                : Icons.school_outlined,
                            color: AppColors.primaryGreen,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              user.isStudentVerified
                                  ? 'Verified student${user.verifiedSchoolName == null || user.verifiedSchoolName!.isEmpty ? '' : ' • ${user.verifiedSchoolName}'}'
                                  : (user.pendingStudentEmail != null &&
                                            user.pendingStudentEmail!.isNotEmpty)
                                        ? 'Verification pending for ${user.pendingStudentEmail}'
                                        : 'No school email verified yet',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    fontWeight: user.isStudentVerified
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _studentEmailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'School Email (.edu)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _saving || _sendingStudentCode || _confirmingStudentCode
                            ? null
                            : _startStudentVerification,
                        child: Text(
                          (user.pendingStudentEmail != null &&
                                  user.pendingStudentEmail!.isNotEmpty)
                              ? 'Resend Verification Code'
                              : 'Send Verification Code',
                        ),
                      ),
                    ),
                    if ((user.pendingStudentEmail != null &&
                            user.pendingStudentEmail!.isNotEmpty) ||
                        _devVerificationCode != null) ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _verificationCodeController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Verification Code',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      if (_devVerificationCode != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Local demo code: $_devVerificationCode',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.tonal(
                          onPressed:
                              _saving || _sendingStudentCode || _confirmingStudentCode
                              ? null
                              : _confirmStudentVerification,
                          child: const Text('Verify Student Email'),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    _buildField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      keyboardType: TextInputType.phone,
                      inputFormatters: [UsPhoneTextInputFormatter()],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _majorController,
                      decoration: const InputDecoration(
                        labelText: 'Major (optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _academicYearController,
                      decoration: const InputDecoration(
                        labelText: 'Year (optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _vibeController,
                      decoration: const InputDecoration(
                        labelText: 'Vibe (optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _favoritePlaylistController,
                      decoration: const InputDecoration(
                        labelText: 'Favorite Playlist (optional)',
                        border: OutlineInputBorder(),
                      ),
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
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
