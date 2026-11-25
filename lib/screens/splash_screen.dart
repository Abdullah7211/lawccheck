import 'dart:async';
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import 'login_screen.dart';

// Design reference: 393 x 852. Positions below are kept as fractions of the
// screen so the splash looks the same on other sizes.
const double _designWidth = 393;
const double _designHeight = 852;

// Circle center in the design: (-337 + 1068/2, -112 + 1068/2) = (197, 422)
const double _circleCenterX = 197 / _designWidth;
const double _circleCenterY = 422 / _designHeight;

// Text top positions in the design.
const double _titleTop = 497 / _designHeight;
const double _subtitleTop = 573 / _designHeight;

// Your logo: E:\Law Note\lawccheck\assets\icons\logo.png
const String _logoAsset = 'assets/icons/logo.png';
const double _logoSize = 268; // change to resize the logo
const double _logoGap = 24; // space between logo and "LAWBUDS"

const Color _subtitleColor = Color(0xFF727B86); // Text-B

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // Whole sequence: dot -> circle fills screen -> title -> subtitle -> hold.
  static const Duration _total = Duration(milliseconds: 2600);
  static const Duration _holdAfter = Duration(milliseconds: 700);

  late final AnimationController _controller;

  // Timeline (0.0 - 1.0 of _total)
  late final Animation<double> _circle;
  late final Animation<double> _logo;
  late final Animation<double> _title;
  late final Animation<double> _subtitle;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: _total);

    // 0.00 - 0.15  dot sits alone
    // 0.15 - 0.62  dot grows into the full-screen circle
    _circle = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.15, 0.62, curve: Curves.easeInOutCubic),
    );
    // 0.45 - 0.70  logo fades in / scales up as the circle finishes growing
    _logo = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.45, 0.70, curve: Curves.easeOutBack),
    );
    // 0.65 - 0.85  "LAWBUDS" fades / slides in
    _title = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.65, 0.85, curve: Curves.easeOutCubic),
    );
    // 0.75 - 0.95  tagline fades / slides in
    _subtitle = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.75, 0.95, curve: Curves.easeOutCubic),
    );

    _controller.forward().whenComplete(() async {
      await Future<void>.delayed(_holdAfter);
      if (!mounted) return;
      _goToLogin();
    });
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    final cx = size.width * _circleCenterX;
    final cy = size.height * _circleCenterY;

    // Big enough to cover the whole screen from the center point.
    final maxDiameter = math.sqrt(
          size.width * size.width + size.height * size.height,
        ) *
        1.15;
    const startDiameter = 2.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final diameter =
              startDiameter + (maxDiameter - startDiameter) * _circle.value;

          return Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // Dot -> expanding circle
              Positioned(
                left: cx - diameter / 2,
                top: cy - diameter / 2,
                width: diameter,
                height: diameter,
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              // Logo (sits just above the title)
              Positioned(
                left: 0,
                right: 0,
                top: size.height * _titleTop - _logoGap - _logoSize,
                child: Center(
                  child: Opacity(
                    opacity: _logo.value.clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: 0.8 + 0.2 * _logo.value,
                      child: Image.asset(
                        _logoAsset,
                        width: _logoSize,
                        height: _logoSize,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),

              // Title
              Positioned(
                left: 0,
                right: 0,
                top: size.height * _titleTop,
                child: _FadeSlide(
                  progress: _title.value,
                  child: const Text(
                    'LAWBUDS',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.background,
                      fontSize: 48,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      height: 1.20,
                    ),
                  ),
                ),
              ),

              // Tagline
              Positioned(
                left: 0,
                right: 0,
                top: size.height * _subtitleTop,
                child: _FadeSlide(
                  progress: _subtitle.value,
                  child: const Text(
                    'Legal Practice Companion',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _subtitleColor,
                      fontSize: 23,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      height: 1.20,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Fades in while sliding up a little. [progress] goes 0.0 -> 1.0.
class _FadeSlide extends StatelessWidget {
  final double progress;
  final Widget child;

  const _FadeSlide({required this.progress, required this.child});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: progress.clamp(0.0, 1.0),
      child: Transform.translate(
        offset: Offset(0, 16 * (1 - progress)),
        child: child,
      ),
    );
  }
}