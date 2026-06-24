import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';
import '../state/app_state.dart';

class PrescriptionCard extends StatelessWidget {
  final Appointment appointment;
  final bool isDownloading;
  final VoidCallback onDownload;
  final VoidCallback onViewRx;

  const PrescriptionCard({
    super.key,
    required this.appointment,
    required this.isDownloading,
    required this.onDownload,
    required this.onViewRx,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineVariantColor),
        boxShadow: AppTheme.ambientShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Clinic info & Doctor
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.medication_liquid_sharp,
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.professionalName,
                        style: GoogleFonts.hankenGrotesk(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.onSurfaceColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${appointment.category} • ${appointment.organizationName}",
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24, color: AppTheme.outlineVariantColor),
            
            // Meeting and PDF details
            Row(
              children: [
                const Icon(Icons.event_note, size: 16, color: AppTheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Text(
                  "${AppTheme.formatDate(appointment.date)} • ${appointment.timeSlot}",
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.onSurfaceColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.assignment_outlined, size: 16, color: AppTheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Text(
                  "Service: ${appointment.serviceName}",
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // PDF indicator bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.outlineVariantColor.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.picture_as_pdf, color: AppTheme.errorColor, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      appointment.prescriptionName ?? "prescription.pdf",
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.onSurfaceColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Action buttons row
            Row(
              children: [
                // View Prescription
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onViewRx,
                    icon: const Icon(Icons.remove_red_eye_outlined, size: 18),
                    label: Text(
                      "View PDF",
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      foregroundColor: AppTheme.primaryColor,
                      side: const BorderSide(color: AppTheme.primaryColor, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Download
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isDownloading ? null : onDownload,
                    icon: isDownloading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.download_outlined, size: 18),
                    label: Text(
                      isDownloading ? "Downloading" : "Download",
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
