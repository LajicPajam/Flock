import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class WelcomeTourScreen extends StatelessWidget {
  const WelcomeTourScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.canvasBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primaryGreen, Color(0xFF4A8A6A)],
                  ),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.82),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.waving_hand_rounded,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Welcome to Flock',
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'A quick guide so your first ride request does not feel like guesswork.',
                      style: textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.84),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _TourCard(
                        step: '01',
                        icon: Icons.route_rounded,
                        title: 'Search by route first',
                        body:
                            'Pick where you are and where you want to go. Flock is built around common student routes, not open-ended ride hailing.',
                      ),
                      SizedBox(height: 14),
                      _TourCard(
                        step: '02',
                        icon: Icons.hail_rounded,
                        title: 'Request a seat politely',
                        body:
                            'Send a short note with your ride request so the driver knows who you are and what to expect.',
                      ),
                      SizedBox(height: 14),
                      _TourCard(
                        step: '03',
                        icon: Icons.verified_user_outlined,
                        title: 'Vehicle details unlock after acceptance',
                        body:
                            'Once a driver accepts you, you can see the car details and message them in-app to coordinate pickup.',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Enter Flock'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TourCard extends StatelessWidget {
  const _TourCard({
    required this.step,
    required this.icon,
    required this.title,
    required this.body,
  });

  final String step;
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.subtleBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.secondaryGreen,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.primaryGreen),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step,
                  style: textTheme.labelLarge?.copyWith(
                    color: AppColors.primaryAccent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textInk.withValues(alpha: 0.7),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
