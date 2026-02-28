import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Shared footer with logo, social icons, address, and copyright.
/// Shown on all app screens (login and every UiShell page).
class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 40),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.08),
      ),
      child: Column(
        children: [
          Image.asset('assets/flock_logo.png', height: 48, fit: BoxFit.contain),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.facebook_rounded),
                color: AppColors.primaryGreen,
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.camera_alt_outlined),
                color: AppColors.primaryGreen,
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.alternate_email),
                color: AppColors.primaryGreen,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '123 University Ave, Provo, UT 84601',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textInk.withValues(alpha: 0.7),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '© 2025 Flock Carpool. All rights reserved.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textInk.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
          ),
        ],
      ),
    );
  }
}

class UiShell extends StatelessWidget {
  const UiShell({
    super.key,
    required this.title,
    required this.child,
    this.actions = const [],
    this.floatingActionButton,
    /// When true, content uses 70–85% of viewport width for a more open layout (e.g. Available Trips).
    this.useWideLayout = false,
  });

  final String title;
  final Widget child;
  final List<Widget> actions;
  final Widget? floatingActionButton;
  final bool useWideLayout;

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final width = MediaQuery.sizeOf(context).width;
    final maxContentWidth = useWideLayout
        ? (width * 0.85).clamp(760.0, double.infinity)
        : 760.0;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: canPop
            ? null
            : Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Image.asset('assets/flock_icon.png', height: 28),
                ),
              ),
        leadingWidth: canPop ? null : 58,
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: actions,
      ),
      floatingActionButton: floatingActionButton,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: child,
                  ),
                ),
              ),
            ),
            const AppFooter(),
          ],
        ),
      ),
    );
  }
}
