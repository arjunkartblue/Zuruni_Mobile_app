import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/theme.dart';
import '../../state/app_state.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  static const String _googleSvg = '''
<svg viewBox="0 0 24 24" width="20" height="20" xmlns="http://www.w3.org/2000/svg">
  <path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" fill="#4285F4"/>
  <path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853"/>
  <path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z" fill="#FBBC05"/>
  <path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335"/>
</svg>
''';

  static const String _appleSvg = '''
<svg viewBox="0 0 24 24" width="20" height="20" fill="#000000" xmlns="http://www.w3.org/2000/svg">
  <path d="M17.05 20.28c-.98.95-2.05.8-3.08.35-1.09-.46-2.09-.48-3.24 0-1.44.62-2.2.44-3.06-.35C2.79 15.25 3.51 7.59 9.05 7.31c1.35.05 2.25.68 2.74.68.42 0 1.64-.81 3.3-.77 1.5.04 2.85.73 3.65 1.88-3.1 1.9-2.58 5.96.48 7.21-.69 1.77-1.3 3.06-2.17 3.97zm-4.71-13.62c-.22-2.45 2.22-4.5 4.54-4.66.45 2.65-2.36 4.79-4.54 4.66z"/>
</svg>
''';

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final appState = Provider.of<AppState>(context, listen: false);
      appState.login(_emailController.text, _passwordController.text);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Welcome back, ${appState.userName}!"),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  void _mockSocialLogin(String provider) {
    final appState = Provider.of<AppState>(context, listen: false);
    appState.login("$provider.user@example.com", "password123");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Signed in via $provider! Welcome back, ${appState.userName}!"),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: Navigator.canPop(context)
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppTheme.onSurfaceColor),
                onPressed: () => Navigator.pop(context),
              ),
            )
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // BookWell Title in Top Center
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: SizedBox(
                    height: 48,
                    child: Center(
                      child: Text(
                        "BookWell",
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),
                ),
                // Centered Header & Subheader
                Center(
                  child: Column(
                    children: [
                      Text(
                        "Welcome Back",
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
                        "Log in to manage your appointments and professional network.",
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
                
                // Email or Phone Field
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
                  controller: _emailController,
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
                const SizedBox(height: 20),
                
                // Password Field
                Text(
                  "Password",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.onSurfaceColor,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: "Enter your password",
                    prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.outlineColor),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: AppTheme.outlineColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                
                // Remember Me & Forgot Password
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _rememberMe,
                              activeColor: AppTheme.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value ?? false;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              "Remember me",
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: AppTheme.onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                        );
                      },
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: const Text("LOG IN"),
                  ),
                ),
                const SizedBox(height: 24),

                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider(color: AppTheme.outlineVariantColor)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "OR CONTINUE WITH",
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.onSurfaceVariant,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider(color: AppTheme.outlineVariantColor)),
                  ],
                ),
                const SizedBox(height: 20),

                // Social Buttons
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppTheme.surfaceContainerLowest,
                    side: const BorderSide(color: AppTheme.outlineVariantColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () => _mockSocialLogin("Google"),
                  icon: SvgPicture.string(
                    _googleSvg,
                    width: 20,
                    height: 20,
                  ),
                  label: Text(
                    "Continue with Google",
                    style: GoogleFonts.inter(
                      color: AppTheme.onSurfaceColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppTheme.surfaceContainerLowest,
                    side: const BorderSide(color: AppTheme.outlineVariantColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () => _mockSocialLogin("Apple"),
                  icon: SvgPicture.string(
                    _appleSvg,
                    width: 20,
                    height: 20,
                  ),
                  label: Text(
                    "Continue with Apple",
                    style: GoogleFonts.inter(
                      color: AppTheme.onSurfaceColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Continue as Guest
                Center(
                  child: GestureDetector(
                    onTap: () {
                      final appState = Provider.of<AppState>(context, listen: false);
                      appState.continueAsGuest();
                    },
                    child: Text(
                      "Continue as Guest",
                      style: GoogleFonts.inter(
                        color: AppTheme.onSurfaceColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                const Divider(color: AppTheme.outlineVariantColor),
                const SizedBox(height: 24),

                // Signup Link
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(color: AppTheme.onSurfaceVariant),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const SignupScreen()),
                        );
                      },
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
