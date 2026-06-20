import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/theme.dart';
import 'otp_verification_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();

  @override
  void dispose() {
    _identifierController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final value = _identifierController.text.trim();
      final isEmail = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEmail ? "Recovery code sent to email!" : "Recovery code sent to phone number!"),
          backgroundColor: AppTheme.successColor,
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpVerificationScreen(
            email: isEmail ? value : null,
            phone: !isEmail ? value : null,
            isPasswordReset: true,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
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
                        Text(
                          "BookWell",
                          style: GoogleFonts.hankenGrotesk(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Centered Header & Subheader
                Center(
                  child: Column(
                    children: [
                      Text(
                        "Forgot Password?",
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF18181B),
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Enter your email address or phone number to receive a recovery code.",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: AppTheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Email or Phone Input
                Text(
                  "Email or Phone",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.onSurfaceColor,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _identifierController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: "Enter your email or phone number",
                    prefixIcon: Icon(Icons.person_outline, color: AppTheme.outlineColor),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email or phone';
                    }
                    final isEmail = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value);
                    final isPhone = RegExp(r'^\+?[0-9]{7,15}$').hasMatch(value.replaceAll(RegExp(r'[\s-()]+'), ''));
                    if (!isEmail && !isPhone) {
                      return 'Please enter a valid email or phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Submit Button (Send Reset Code)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: const Text("Send Reset Code"),
                  ),
                ),
                const SizedBox(height: 16),

                // Back to Log In Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.outlineVariantColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Back to Log In",
                      style: GoogleFonts.inter(
                        color: AppTheme.onSurfaceColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
