import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/theme.dart';

class AccountVerifiedScreen extends StatelessWidget {
  const AccountVerifiedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
              const Spacer(),
              
              // Celebration Icon
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.security_outlined,
                    color: AppTheme.successColor,
                    size: 48,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              Text(
                "Document Submitted",
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF18181B),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Your identity document has been submitted for secure automated gate-clearance auditing.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerColor,
                  borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                ),
                child: const Text(
                  "Note: The audit process takes about 6 seconds. Your status will automatically update to 'Verified' upon approval.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              const Spacer(),

              // Return CTA
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate back to the main shell (profile screen is open)
                    Navigator.pop(context);
                  },
                  child: const Text("RETURN TO PROFILE"),
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
