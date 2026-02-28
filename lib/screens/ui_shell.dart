import 'package:flutter/material.dart';

import '../debug_log.dart';
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
    this.preferBrandLeading = false,
    /// When true, content uses 70–85% of viewport width for a more open layout (e.g. Available Trips).
    this.useWideLayout = false,
  });

  final String title;
  final Widget child;
  final List<Widget> actions;
  final Widget? floatingActionButton;
  final bool preferBrandLeading;
  final bool useWideLayout;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final maxContentWidth = _contentWidthForViewport(width);
    debugLog(
      location: 'ui_shell.dart:UiShell.build',
      message: 'UiShell body build',
      data: {
        'width': width,
        'maxContentWidth': maxContentWidth,
        'useWideLayout': useWideLayout,
      },
      hypothesisId: 'H1',
    );
    // #endregion
    final navigatorCanPop = Navigator.of(context).canPop();
    final showBrandLeading = preferBrandLeading || !navigatorCanPop;
    final leading = showBrandLeading
        ? const _BrandLeading(key: ValueKey('brand-leading'))
        : IconButton(
            key: const ValueKey('back-leading'),
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            tooltip: 'Back',
          );

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: leading,
        leadingWidth: 58,
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: actions,
      ),
      floatingActionButton: floatingActionButton,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = _contentWidthForViewport(constraints.maxWidth);
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: w,
                  height: constraints.maxHeight,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: child,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  double _contentWidthForViewport(double viewportWidth) {
    if (!useWideLayout) {
      return viewportWidth >= 760 ? 760 : viewportWidth;
    }

    if (viewportWidth < 760) {
      return viewportWidth;
    }

    return (viewportWidth * 0.85).clamp(760.0, viewportWidth);
  }
}

class _BrandLeading extends StatelessWidget {
  const _BrandLeading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: ImageIcon(
          AssetImage('assets/flock_icon.png'),
          size: 30,
          color: Colors.white,
        ),
      ),
    );
  }
}
