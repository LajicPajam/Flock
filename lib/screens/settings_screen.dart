import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'ui_shell.dart';

/// Max width for body paragraphs so lines stay readable on wide viewports.
const double _kMaxParagraphWidth = 640;

/// Horizontal padding for cards: responsive to viewport width.
double _cardPadding(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  if (width < 400) return 12;
  if (width < 600) return 16;
  return 20;
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return UiShell(
      title: 'Settings',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxW = constraints.maxWidth.clamp(0.0, _kMaxParagraphWidth);
          return ListView(
            children: [
              _SettingsCard(
                title: 'About This App',
                body:
                    'Flock is a college-focused carpool app for students traveling between supported college towns. Drivers post trips they are already planning to take, and riders request to join.',
                maxBodyWidth: maxW,
                padding: _cardPadding(context),
              ),
              const SizedBox(height: 12),
              _SettingsCard(
                title: 'Carpool-Only Policy',
                body:
                    'This app is for voluntary cost-sharing carpools only. No commercial transportation services are provided. Drivers and riders participate at their own risk.',
                maxBodyWidth: maxW,
                padding: _cardPadding(context),
              ),
              const SizedBox(height: 12),
              _SettingsCard(
                title: 'Privacy Policy',
                body:
                    'Flock stores account details, trip posts, ride requests, messages, and ratings so the app can function. Profile photos and vehicle details are shown only as needed for coordination and trust within the app. This is a local-development hackathon prototype and is not intended for production use.',
                maxBodyWidth: maxW,
                padding: _cardPadding(context),
              ),
              const SizedBox(height: 12),
              _SettingsCard(
                title: 'Safety Guidelines',
                body:
                    'Meet in public places when possible, confirm the driver and vehicle before entering, and only travel with people you are comfortable coordinating with. Use ratings and profile details to make informed decisions.',
                maxBodyWidth: maxW,
                padding: _cardPadding(context),
              ),
              const SizedBox(height: 12),
              _SettingsCard(
                title: 'Terms and Limitations',
                body:
                    'There are no in-app payments, no live location tracking, and no commercial transportation services. Cost-sharing, timing, and meetup details are arranged directly by users.',
                maxBodyWidth: maxW,
                padding: _cardPadding(context),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.title,
    required this.body,
    required this.maxBodyWidth,
    required this.padding,
  });

  final String title;
  final String body;
  final double maxBodyWidth;
  final double padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isNarrow = MediaQuery.sizeOf(context).width < 400;
    final bodyStyle = theme.textTheme.bodyMedium?.copyWith(
      height: 1.45,
      fontSize: isNarrow ? 14.0 : null,
    );

    return Card(
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.bold,
                fontSize: isNarrow ? 15.0 : null,
              ),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxBodyWidth),
              child: Text(
                body,
                style: bodyStyle,
                textAlign: TextAlign.start,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
