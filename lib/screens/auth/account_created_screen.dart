import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../theme/theme.dart';
import '../../state/app_state.dart';

class AccountCreatedScreen extends StatefulWidget {
  final String name;
  final String email;
  final String phone;
  final String password;

  const AccountCreatedScreen({
    Key? key,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
  }) : super(key: key);

  @override
  State<AccountCreatedScreen> createState() => _AccountCreatedScreenState();
}

class _AccountCreatedScreenState extends State<AccountCreatedScreen> {
  Timer? _timer;
  double _progress = 0.0;
  final int _totalDurationMs = 3000;
  final int _tickMs = 50;
  int _elapsedMs = 0;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(milliseconds: _tickMs), (timer) {
      if (!mounted) return;
      setState(() {
        _elapsedMs += _tickMs;
        _progress = (_elapsedMs / _totalDurationMs).clamp(0.0, 1.0);
        if (_elapsedMs >= _totalDurationMs) {
          _timer?.cancel();
          _goToDashboard();
        }
      });
    });
  }

  void _goToDashboard() {
    if (_navigated || !mounted) return;
    _navigated = true;
    _timer?.cancel();

    final appState = Provider.of<AppState>(context, listen: false);
    appState.signup(widget.name, widget.email, widget.phone, widget.password);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Welcome to Zuruni, ${appState.userName}!"),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int secondsRemaining = ((_totalDurationMs - _elapsedMs) / 1000).ceil();
    if (secondsRemaining < 0) secondsRemaining = 0;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Top Header Row with Centered Title (no back button since flow is finished)
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/images/zuruni_logo.svg',
                      height: 28,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              
              // Success Celebration Icon
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_circle_outline,
                    color: AppTheme.successColor,
                    size: 48,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Centered Heading & Subheading
              Text(
                "Account Verified",
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF18181B),
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                "Your account has been verified successfully. Let's get started!",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: AppTheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),

              // Smooth countdown indicator
              Text(
                "Redirecting to dashboard in $secondsRemaining seconds...",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 140,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                    minHeight: 4,
                  ),
                ),
              ),
              const Spacer(),

              // Get Started CTA
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _goToDashboard,
                  child: const Text("Go to Dashboard"),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
