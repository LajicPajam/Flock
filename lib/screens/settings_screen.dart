import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'ui_shell.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return UiShell(
      title: 'Settings',
      child: ListView(
        children: const [
          _SettingsCard(
            title: 'About This App',
            body:
                'Flock is a college-focused carpool app for students traveling between supported college towns. Drivers post trips they are already planning to take, and riders request to join.',
          ),
          SizedBox(height: 12),
          _SettingsCard(
            title: 'Carpool-Only Policy',
            body:
                'This app is for voluntary cost-sharing carpools only. No commercial transportation services are provided. Drivers and riders participate at their own risk.',
          ),
          SizedBox(height: 12),
          _SettingsCard(
            title: 'Privacy Policy',
            body:
                'Flock stores account details, trip posts, ride requests, messages, and ratings so the app can function. Profile photos and vehicle details are shown only as needed for coordination and trust within the app. This is a local-development hackathon prototype and is not intended for production use.',
          ),
          SizedBox(height: 12),
          _SettingsCard(
            title: 'Safety Guidelines',
            body:
                'Meet in public places when possible, confirm the driver and vehicle before entering, and only travel with people you are comfortable coordinating with. Use ratings and profile details to make informed decisions.',
          ),
          SizedBox(height: 12),
          _SettingsCard(
            title: 'Terms and Limitations',
            body:
                'There are no in-app payments, no live location tracking, and no commercial transportation services. Cost-sharing, timing, and meetup details are arranged directly by users.',
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(body),
          ],
        ),
      ),
    );
  }
}
