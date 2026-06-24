import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';
import '../state/app_state.dart';
import 'profile/edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isAccountVerified = appState.verificationStatus == VerificationStatus.verified;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CARD 1: Profile Photo & Contact Information
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              border: Border.all(color: AppTheme.outlineVariantColor),
              boxShadow: AppTheme.ambientShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Photo, Name, Verification Badge)
                Center(
                  child: Column(
                    children: [
                      // Square Profile image with rounded corners and stacked black badge
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: const Image(
                              image: NetworkImage(
                                'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=240',
                              ),
                              width: 108,
                              height: 108,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        appState.userName,
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.onSurfaceColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      
                      // Verified Account Badge Pill (Lavender themed)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF5FF), // light lavender background
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFE9D5FF)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isAccountVerified ? Icons.verified_outlined : Icons.watch_later_outlined,
                              color: const Color(0xFF6B21A8), // purple/lavender color
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isAccountVerified ? "Verified Account" : "Verification Pending",
                              style: GoogleFonts.inter(
                                color: const Color(0xFF6B21A8),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                const Divider(color: AppTheme.outlineVariantColor, height: 1),
                const SizedBox(height: 20),
                
                // Contact Details
                Text(
                  "Contact Information",
                  style: GoogleFonts.hankenGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.onSurfaceColor,
                  ),
                ),
                const SizedBox(height: 16),
                _buildContactRow(
                  label: "EMAIL",
                  value: appState.userEmail,
                  isVerified: true,
                ),
                const SizedBox(height: 14),
                _buildContactRow(
                  label: "PHONE",
                  value: appState.userPhone,
                  isVerified: true,
                ),
                const SizedBox(height: 14),
                _buildContactRow(
                  label: "COUNTRY",
                  value: appState.userCountry,
                  isVerified: false,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),

          // CARD 2: Identity & Access Documents Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              border: Border.all(color: AppTheme.outlineVariantColor),
              boxShadow: AppTheme.ambientShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Identity & Access Documents",
                  style: GoogleFonts.hankenGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.onSurfaceColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Documents used for automated gate-entry verification.",
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.onSurfaceVariant.withOpacity(0.8),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 20),
                
                if (appState.documents.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "No identity documents uploaded yet.",
                      style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 13),
                    ),
                  )
                else
                  ...appState.documents.map((doc) => _buildDocumentTile(doc)),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Edit Profile Details Button (Black capsule style)
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                );
              },
              icon: const Icon(Icons.edit, size: 16),
              label: const Text("Edit Profile Details"),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildContactRow({
    required String label,
    required String value,
    required bool isVerified,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurfaceVariant.withOpacity(0.6),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.onSurfaceColor,
                ),
              ),
            ],
          ),
        ),
        if (isVerified)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFD1FAE5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle, color: Color(0xFF059669), size: 12),
                SizedBox(width: 4),
                Text(
                  "VERIFIED",
                  style: TextStyle(
                    color: Color(0xFF059669),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDocumentTile(VerificationDocument doc) {
    final isVerified = doc.status == "Verified";
    final isAadhaar = doc.type.toLowerCase().contains("aadhaar");

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.outlineVariantColor),
        boxShadow: AppTheme.ambientShadow,
      ),
      child: Row(
        children: [
          Icon(
            isAadhaar ? Icons.assignment_ind_outlined : Icons.menu_book_outlined,
            color: AppTheme.primaryColor,
            size: 24,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              doc.type,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.onSurfaceColor,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isVerified ? const Color(0xFFD1FAE5) : const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isVerified ? Icons.check_circle : Icons.watch_later,
                  color: isVerified ? const Color(0xFF059669) : const Color(0xFFD97706),
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  doc.status,
                  style: TextStyle(
                    color: isVerified ? const Color(0xFF059669) : const Color(0xFFD97706),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
