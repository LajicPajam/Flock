import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class UiShell extends StatelessWidget {
  const UiShell({
    super.key,
    required this.title,
    required this.child,
    this.actions = const [],
    this.floatingActionButton,
  });

  final String title;
  final Widget child;
  final List<Widget> actions;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/flock_icon.png', height: 28),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        actions: actions,
      ),
      floatingActionButton: floatingActionButton,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryGreen,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.subtleBorder),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'This app is for voluntary cost-sharing carpools only.',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'No commercial transportation services are provided.',
                        ),
                        Text(
                          'Drivers and riders participate at their own risk.',
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: child),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
