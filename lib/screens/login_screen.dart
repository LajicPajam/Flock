import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_colors.dart';
import '../state/app_state.dart';
import 'register_screen.dart';
import 'settings_screen.dart';
import 'ui_shell.dart';

class _HeroSlogan extends StatelessWidget {
  const _HeroSlogan();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Center(
        child: Text(
          'find your flock',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
                height: 1.1,
                letterSpacing: -0.5,
              ),
        ),
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          'assets/carpool_hero.png',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit(AppState appState) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await appState.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    if (!success && appState.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(appState.errorMessage!)));
    }
  }

  void _showSocialComingSoon(String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$provider sign-in is coming soon.')),
    );
  }

  Widget _buildSignInCard(AppState appState) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sign In',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Use the same email and password you registered with.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter your email.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter your password.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: appState.isLoading
                          ? null
                          : () => _submit(appState),
                      child: Text(
                        appState.isLoading ? 'Signing In...' : 'Sign In',
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final dividerLabel = Text(
                        'or continue with',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.black54,
                        ),
                      );

                      if (constraints.maxWidth < 260) {
                        return Center(child: dividerLabel);
                      }

                      return Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: AppColors.subtleBorder,
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: dividerLabel,
                          ),
                          Expanded(
                            child: Divider(
                              color: AppColors.subtleBorder,
                              thickness: 1,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  _GoogleContinueButton(
                    onPressed: () => _showSocialComingSoon('Google'),
                  ),
                  const SizedBox(height: 10),
                  _SocialSignInButton(
                    label: 'Continue with Apple',
                    leading: const _AppleGlyph(),
                    backgroundColor: AppColors.textInk,
                    borderColor: AppColors.textInk,
                    foregroundColor: Colors.white,
                    onPressed: () => _showSocialComingSoon('Apple'),
                  ),
                  const SizedBox(height: 6),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text('New here? Create an account'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final heroHeight = MediaQuery.of(context).size.height * 0.5;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset('assets/flock_icon.png', height: 32),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const SettingsScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.settings),
                      tooltip: 'Settings',
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sign In',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Use the same email and password you registered with.',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: Colors.black54),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _emailController,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Enter your email.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: 'Password',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Enter your password.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.actionBlue,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: appState.isLoading ? null : () => _submit(appState),
                                  child: Text(
                                    appState.isLoading ? 'Signing In...' : 'Sign In',
                                  ),
                                ),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.actionBlue,
                                ),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => const RegisterScreen(),
                                    ),
                                  );
                                },
                                child: const Text('New here? Create an account'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final useRow = constraints.maxWidth >= 980;
                  if (useRow) {
                    return SizedBox(
                      height: heroHeight + 60,
                      child: Row(
                        children: [
                          const Expanded(child: _HeroSlogan()),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 24,
                              ),
                              child: _buildSignInCard(appState),
                            ),
                          ),
                          const Expanded(child: _HeroImage()),
                        ],
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Column(
                      children: [
                        const _HeroSlogan(),
                        _buildSignInCard(appState),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: heroHeight * 0.58,
                          child: const _HeroImage(),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: _WhyFlockSection(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _QuoteSection(),
              ),
            ),
            SliverToBoxAdapter(
              child: const AppFooter(),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoogleContinueButton extends StatelessWidget {
  const _GoogleContinueButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return _SocialSignInButton(
      label: 'Continue with Google',
      leading: const _GoogleGlyph(size: 22),
      onPressed: onPressed,
    );
  }
}

class _SocialSignInButton extends StatelessWidget {
  const _SocialSignInButton({
    required this.label,
    required this.leading,
    required this.onPressed,
    this.backgroundColor = Colors.white,
    this.borderColor = AppColors.subtleBorder,
    this.foregroundColor = AppColors.textInk,
  });

  final String label;
  final Widget leading;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color borderColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: backgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          side: BorderSide(color: borderColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          foregroundColor: foregroundColor,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              child: Align(
                alignment: Alignment.centerRight,
                child: leading,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: foregroundColor,
                ),
              ),
            ),
            const SizedBox(width: 22),
          ],
        ),
      ),
    );
  }
}

class _GoogleGlyph extends StatelessWidget {
  const _GoogleGlyph({this.size = 34});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.network(
        'https://developers.google.com/identity/images/g-logo.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return CustomPaint(
            painter: const _GoogleGlyphPainter(),
          );
        },
      ),
    );
  }
}

class _AppleGlyph extends StatelessWidget {
  const _AppleGlyph();

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    final useAppleGlyph =
        platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;

    if (useAppleGlyph) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: Center(
          child: Text(
            '\uF8FF',
            style: TextStyle(
              color: Colors.white,
              fontSize: 27,
              height: 1,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      );
    }

    return const SizedBox(
      width: 24,
      height: 24,
      child: Center(
        child: Icon(
          Icons.apple,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}

class _GoogleGlyphPainter extends CustomPainter {
  const _GoogleGlyphPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.18;
    final radius = (size.width - stroke) / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, 3.70, 1.42, false, paint);

    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, 2.72, 1.00, false, paint);

    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 1.86, 1.28, false, paint);

    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -0.28, 2.02, false, paint);

    final cutout = Paint()..color = Colors.white;
    final cutoutWidth = stroke * 1.45;
    canvas.drawRect(
      Rect.fromLTWH(
        center.dx + size.width * 0.10,
        center.dy - stroke * 0.95,
        cutoutWidth,
        stroke * 1.9,
      ),
      cutout,
    );

    final bar = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke * 0.92;
    canvas.drawLine(
      Offset(center.dx + size.width * 0.02, center.dy),
      Offset(center.dx + size.width * 0.34, center.dy),
      bar,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WhyFlockSection extends StatelessWidget {
  const _WhyFlockSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Why Flock?',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primaryGreen,
              ),
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final useRow = constraints.maxWidth >= 600;
            final items = [
              _BenefitItem(
                icon: Icons.savings_outlined,
                title: 'Save money',
                body:
                    'Split gas and tolls for game days, breaks, and weekend trips instead of driving solo.',
              ),
              _BenefitItem(
                icon: Icons.eco_outlined,
                title: 'Reduce emissions',
                body: 'Carpooling cuts CO₂ by ~110g per km. Track your impact.',
              ),
              _BenefitItem(
                icon: Icons.groups_outlined,
                title: 'Meet your flock',
                body:
                    'Perfect for students heading to rival campuses, airports, concerts, and home for the weekend.',
              ),
            ];
            if (useRow) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < items.length; i++) ...[
                    if (i > 0) const SizedBox(width: 16),
                    Expanded(child: items[i]),
                  ],
                ],
              );
            }
            return Column(
              children: items
                  .map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: e,
                      ))
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _BenefitItem extends StatelessWidget {
  const _BenefitItem({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.secondaryGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 28, color: AppColors.primaryGreen),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textInk,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textInk.withValues(alpha: 0.72),
                ),
          ),
        ],
      );
  }
}

class _QuoteSection extends StatelessWidget {
  const _QuoteSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.secondaryGreen,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.subtleBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.format_quote, size: 32, color: AppColors.primaryGreen),
          const SizedBox(height: 12),
          Text(
            'Perfect for away games, weekend trips, and rides home on break. I use Flock to find people already headed my way, and it makes the whole trip easier.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppColors.textInk.withValues(alpha: 0.86),
                  height: 1.6,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            '— Flock student rider',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGreen,
                ),
          ),
        ],
      ),
    );
  }
}
