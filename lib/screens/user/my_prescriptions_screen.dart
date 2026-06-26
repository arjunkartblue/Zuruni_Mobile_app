import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/theme.dart';
import '../../state/app_state.dart';
import '../../widgets/prescription_card.dart';
import '../../widgets/empty_state_widget.dart';

class MyPrescriptionsScreen extends StatefulWidget {
  const MyPrescriptionsScreen({super.key});

  @override
  State<MyPrescriptionsScreen> createState() => _MyPrescriptionsScreenState();
}

class _MyPrescriptionsScreenState extends State<MyPrescriptionsScreen> {
  // Set to track which prescriptions are currently simulating a download
  final Set<String> _downloadingIds = {};

  void _simulateDownload(BuildContext context, Appointment appointment) {
    if (_downloadingIds.contains(appointment.id)) return;

    setState(() {
      _downloadingIds.add(appointment.id);
    });

    // Show a loading snackbar to indicate starting download
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              "Downloading ${appointment.prescriptionName ?? 'prescription.pdf'}...",
              style: GoogleFonts.inter(fontSize: 14),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 1000),
      ),
    );

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        _downloadingIds.remove(appointment.id);
      });

      // Show success snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF10B981), // Emerald green
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "${appointment.prescriptionName ?? 'Prescription'} downloaded to local storage successfully!",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    });
  }

  Future<void> _openPrescriptionPdf(Appointment appointment) async {
    final urlString = appointment.prescriptionPdfUrl;
    if (urlString == null) return;

    if (urlString.startsWith('http://') || urlString.startsWith('https://')) {
      final Uri url = Uri.parse(urlString);
      try {
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
          return;
        }
      } catch (e) {
        // Fallback to snackbar if launch fails
      }
    }

    // Show mock snackbar for non-http urls or if launch fails
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.primaryColor,
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "PDF viewer will open when connected to the backend. (Mock file: ${appointment.prescriptionName})",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final prescriptions = appState.prescriptionAppointments;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.onSurfaceColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "My Prescriptions",
          style: GoogleFonts.hankenGrotesk(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppTheme.onSurfaceColor,
          ),
        ),
        centerTitle: true,
      ),
      body: prescriptions.isEmpty
          ? const EmptyStateWidget(
              icon: Icons.description_outlined,
              title: "No Prescriptions Yet",
              subtitle: "Prescriptions uploaded by your medical professionals after completed sessions will appear here.",
            )
          : ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              itemCount: prescriptions.length,
              itemBuilder: (context, index) {
                final apt = prescriptions[index];
                final isDownloading = _downloadingIds.contains(apt.id);

                return PrescriptionCard(
                  appointment: apt,
                  isDownloading: isDownloading,
                  onDownload: () => _simulateDownload(context, apt),
                  onViewRx: () => _openPrescriptionPdf(apt),
                );
              },
            ),
    );
  }


}
