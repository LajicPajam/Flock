import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../utils/phone_formatter.dart';
import 'settings_screen.dart';
import 'ui_shell.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  Uint8List? _photoBytes;
  String? _photoName;
  bool _uploadingPhoto = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
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

  Future<void> _submit(AppState appState) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final photoBytes = _photoBytes;
    final photoName = _photoName;
    if (photoBytes == null || photoName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a profile photo.')),
      );
      return;
    }

    setState(() {
      _uploadingPhoto = true;
    });

    String profilePhotoUrl;
    try {
      profilePhotoUrl = await appState.uploadProfilePhoto(
        bytes: photoBytes,
        fileName: photoName,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _uploadingPhoto = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
      return;
    }

    final success = await appState.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      phoneNumber: digitsOnlyPhone(_phoneController.text),
      profilePhotoUrl: profilePhotoUrl,
    );

    if (mounted) {
      setState(() {
        _uploadingPhoto = false;
      });
    }

    if (!mounted) {
      return;
    }

    if (success) {
      Navigator.of(context).pop();
      return;
    }

    if (appState.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(appState.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return UiShell(
      title: 'Create Account',
      actions: [
        IconButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
            );
          },
          icon: const Icon(Icons.settings),
          tooltip: 'Settings',
        ),
      ],
      child: ListView(
        children: [
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF9FDDEB), Color(0xFFD8F3DC)],
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.person_add_alt_1_rounded,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(height: 18),
                Image.asset(
                  'assets/flock_logo.png',
                  height: 30,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 14),
                Text(
                  'Create your rider profile.',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'It only takes a minute. After signup, we will give you a quick walkthrough so the app makes sense right away.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textInk.withValues(alpha: 0.74),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account Details',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Use a clear profile photo so drivers and riders can recognize you.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textInk.withValues(alpha: 0.66),
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Enter your name.'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Enter your email.'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Enter a password.'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [UsPhoneTextInputFormatter()],
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Enter your phone number.'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Profile Photo',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: _photoBytes == null
                              ? null
                              : MemoryImage(_photoBytes!),
                          child: _photoBytes == null
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _uploadingPhoto ? null : _pickPhoto,
                            icon: const Icon(Icons.photo_library_outlined),
                            label: Text(
                              _photoName == null ? 'Upload Photo' : _photoName!,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: appState.isLoading || _uploadingPhoto
                            ? null
                            : () => _submit(appState),
                        child: Text(
                          appState.isLoading || _uploadingPhoto
                              ? 'Creating...'
                              : 'Create Account',
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
