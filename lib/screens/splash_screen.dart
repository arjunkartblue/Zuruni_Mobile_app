import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/theme.dart';
import 'auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Phase 1: Logo scale + fade
  late final AnimationController _logoController;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;

  // Phase 2: Text reveal
  late final AnimationController _textController;
  late final Animation<double> _textReveal;

  bool _navigating = false;

  @override
  void initState() {
    super.initState();

    // ── Phase 1 ──────────────────────────────────────────────────────────────
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOutCubic),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOutCubic),
    );

    // ── Phase 2 ──────────────────────────────────────────────────────────────
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _textReveal = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeInOutCubic),
    );

    // Start the animation sequence
    _runSequence();
  }

  Future<void> _runSequence() async {
    // Phase 1: Logo scale-in + fade-in
    await _logoController.forward();

    // Phase 2: Text reveal from behind the logo
    await _textController.forward();

    // Brief pause to let the full lockup register visually
    await Future.delayed(const Duration(milliseconds: 400));

    // Phase 3: Navigate to LoginScreen with Hero transition
    _navigateToLogin();
  }

  void _navigateToLogin() {
    if (_navigating || !mounted) return;
    _navigating = true;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        reverseTransitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (context, animation, secondaryAnimation) {
          return const LoginScreen();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Simple fade for the page — the Hero handles the logo motion
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            ),
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Center(
        child: Hero(
          tag: 'zuruni_brand',
          child: Material(
            color: Colors.transparent,
            child: _buildLogoLockup(),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoLockup() {
    return AnimatedBuilder(
      animation: Listenable.merge([_logoController, _textController]),
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Z Icon ────────────────────────────────────────────
            Opacity(
              opacity: _logoOpacity.value,
              child: Transform.scale(
                scale: _logoScale.value,
                child: SvgPicture.asset(
                  'assets/images/app_logo.svg',
                  height: 48,
                ),
              ),
            ),

            // ── "zuruni" text ─────────────────────────────────────
            ClipRect(
              child: Align(
                alignment: Alignment.centerLeft,
                widthFactor: _textReveal.value,
                child: Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Opacity(
                    opacity: _textReveal.value,
                    child: SvgPicture.asset(
                      'assets/images/app_text.svg',
                      height: 48,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
