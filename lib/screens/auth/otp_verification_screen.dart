import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/theme.dart';
import 'reset_password_screen.dart';
import 'account_created_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String? name;
  final String? email;
  final String? phone;
  final String? password;
  final bool isPasswordReset;

  const OtpVerificationScreen({
    Key? key,
    this.name,
    this.email,
    this.phone,
    this.password,
    this.isPasswordReset = false,
  }) : super(key: key);

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  int _secondsRemaining = 59;
  Timer? _timer;
  bool _canResend = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _secondsRemaining = 59;
      _canResend = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        _timer?.cancel();
      }
    });
  }

  void _verifyCode() {
    String code = _controllers.map((c) => c.text).join();
    if (code.length < 6) {
      setState(() {
        _errorMessage = "Please enter the complete 6-digit code";
      });
      return;
    }

    // Mock validation: accept any 6 digit code
    if (widget.isPasswordReset) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ResetPasswordScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AccountCreatedScreen(
            name: widget.name ?? "New User",
            email: widget.email ?? "user@example.com",
            phone: widget.phone ?? "",
            password: widget.password ?? "",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final destination = widget.phone != null && widget.phone!.isNotEmpty
        ? widget.phone
        : widget.email;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header Row with Back Button and Centered Title
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        left: 0,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: AppTheme.onSurfaceColor),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      SvgPicture.asset(
                        'assets/images/zuruni_logo.svg',
                        height: 28,
                      ),
                    ],
                  ),
                ),
              ),

              // Centered Header & Subheader
              Center(
                child: Column(
                  children: [
                    // Circular Icon Container above the heading
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.security_outlined,
                        color: AppTheme.primaryColor,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Verify Identity",
                      style: GoogleFonts.hankenGrotesk(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF18181B),
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                     const SizedBox(height: 12),
                    Text.rich(
                      TextSpan(
                        text: "We've sent a 6-digit code to\n",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: AppTheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                        children: [
                          TextSpan(
                            text: destination ?? '',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.onSurfaceColor,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        "Edit email or phone number",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // 6 Digits OTP Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 46,
                    height: 58,
                    child: TextFormField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: GoogleFonts.hankenGrotesk(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.onSurfaceColor,
                      ),
                      decoration: InputDecoration(
                        counterText: "",
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                          borderSide: const BorderSide(color: AppTheme.outlineVariantColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                          borderSide: const BorderSide(color: AppTheme.outlineVariantColor),
                        ),
                      ),
                      onChanged: (value) {
                        if (_errorMessage != null) {
                          setState(() {
                            _errorMessage = null;
                          });
                        }
                        if (value.isNotEmpty && index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (value.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                        if (codeEnteredComplete()) {
                          FocusScope.of(context).unfocus();
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),

              // Inline Error Message Space
              SizedBox(
                height: 24,
                child: _errorMessage != null
                    ? Center(
                        child: Text(
                          _errorMessage!,
                          style: GoogleFonts.inter(
                            color: AppTheme.errorColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 32),

              // Timer / Resend Links (Didn't receive the code?)
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      "Didn't receive the code? ",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                    if (!_canResend)
                      Text(
                        "Resend in 00:${_secondsRemaining.toString().padLeft(2, '0')}",
                        style: GoogleFonts.inter(
                          color: AppTheme.outlineColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: () {
                          _startTimer();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Mock OTP code resent successfully!")),
                          );
                        },
                        child: Text(
                          "Resend Code",
                          style: GoogleFonts.inter(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Verify Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _verifyCode,
                  child: const Text("Verify & Continue"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool codeEnteredComplete() {
    return _controllers.every((c) => c.text.isNotEmpty);
  }
}
