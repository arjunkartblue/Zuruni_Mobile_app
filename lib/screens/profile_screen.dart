import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';
import '../state/app_state.dart';
import 'profile/identity_verification_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Bio Info Header
          Row(
            children: [
              const CircleAvatar(
                radius: 36,
                backgroundColor: AppTheme.surfaceContainerColor,
                backgroundImage: NetworkImage('https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=120'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appState.userName,
                      style: GoogleFonts.hankenGrotesk(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.onSurfaceColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      appState.userEmail,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      appState.userPhone,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Identity Verification Banner
          _buildVerificationBanner(context, appState),
          const SizedBox(height: 24),

          // Menu Options
          Text(
            "Account Settings",
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          _buildMenuCard(
            context,
            items: [
              _buildMenuItem(Icons.person_outline, "Edit Profile Information", () {
                _showEditProfileDialog(context, appState);
              }),
              _buildMenuItem(Icons.calendar_month_outlined, "Sync External Calendars", () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Google Calendar sync connected")),
                );
              }),
              _buildMenuItem(Icons.notifications_none_outlined, "Notification Settings", () {}),
            ],
          ),
          const SizedBox(height: 24),

          Text(
            "Support",
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          _buildMenuCard(
            context,
            items: [
              _buildMenuItem(Icons.help_outline, "Help & FAQ", () {}),
              _buildMenuItem(Icons.shield_outlined, "Privacy Policy & Terms", () {}),
            ],
          ),
          const SizedBox(height: 32),

          // Logout Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.errorColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                ),
              ),
              onPressed: () {
                appState.logout();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Logged out successfully")),
                );
              },
              child: const Text(
                "LOG OUT",
                style: TextStyle(color: AppTheme.errorColor, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildVerificationBanner(BuildContext context, AppState appState) {
    Color bannerBg;
    Color borderColor;
    IconData icon;
    Color statusColor;
    String statusTitle;
    String statusSubtitle;
    Widget? actionButton;

    switch (appState.verificationStatus) {
      case VerificationStatus.none:
        bannerBg = AppTheme.errorColor.withOpacity(0.05);
        borderColor = AppTheme.errorColor.withOpacity(0.2);
        icon = Icons.cancel_outlined;
        statusColor = AppTheme.errorColor;
        statusTitle = "Identity Not Verified";
        statusSubtitle = "Upload a government-issued ID to activate automated gate entry passes instantly.";
        actionButton = Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const IdentityVerificationScreen()),
                );
              },
              child: const Text("VERIFY IDENTITY NOW"),
            ),
          ),
        );
        break;

      case VerificationStatus.pending:
        bannerBg = AppTheme.pendingColor.withOpacity(0.05);
        borderColor = AppTheme.pendingColor.withOpacity(0.2);
        icon = Icons.hourglass_empty;
        statusColor = AppTheme.pendingColor;
        statusTitle = "Verification Pending Review";
        statusSubtitle = "Your uploaded ${appState.uploadedDocType} is undergoing automated security clearance audits. Expect approval in a few moments.";
        break;

      case VerificationStatus.verified:
        bannerBg = AppTheme.successColor.withOpacity(0.05);
        borderColor = AppTheme.successColor.withOpacity(0.2);
        icon = Icons.check_circle_outline;
        statusColor = AppTheme.successColor;
        statusTitle = "Profile Fully Verified";
        statusSubtitle = "Clearance protocols active. Digital QR passes will activate automatically for all confirmed appointments.";
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bannerBg,
        borderRadius: BorderRadius.circular(AppTheme.radius2Xl),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: statusColor, size: 24),
              const SizedBox(width: 10),
              Text(
                statusTitle,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            statusSubtitle,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppTheme.onSurfaceVariant,
              height: 1.3,
            ),
          ),
          if (actionButton != null) actionButton,
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, {required List<Widget> items}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: AppTheme.outlineVariantColor),
        boxShadow: AppTheme.ambientShadow,
      ),
      child: Column(children: items),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, color: AppTheme.onSurfaceColor, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.outlineColor, size: 20),
      onTap: onTap,
    );
  }

  void _showEditProfileDialog(BuildContext context, AppState appState) {
    final nameController = TextEditingController(text: appState.userName);
    final phoneController = TextEditingController(text: appState.userPhone);
    final emailController = TextEditingController(text: appState.userEmail);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusXl)),
          title: Text(
            "Edit Profile Info",
            style: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Full Name"),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: "Email Address"),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: "Phone Number"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCEL", style: TextStyle(color: AppTheme.onSurfaceVariant)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
              onPressed: () {
                appState.updateProfile(
                  name: nameController.text,
                  phone: phoneController.text,
                  email: emailController.text,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Profile details updated successfully")),
                );
              },
              child: const Text("SAVE"),
            ),
          ],
        );
      },
    );
  }
}
