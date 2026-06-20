import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../theme/theme.dart';
import '../../state/app_state.dart';

class VisitorPassScreen extends StatelessWidget {
  final Appointment appointment;

  const VisitorPassScreen({Key? key, required this.appointment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.onSurfaceColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Digital Pass",
          style: GoogleFonts.hankenGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppTheme.onSurfaceColor),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Mock share widget launched!")),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              // Pass Card Container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radius2Xl),
                  border: Border.all(color: AppTheme.outlineVariantColor),
                  boxShadow: AppTheme.ambientShadow,
                ),
                child: Column(
                  children: [
                    // Facility Logo / Org Name
                    Text(
                      appointment.organizationName,
                      style: GoogleFonts.hankenGrotesk(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "VISITOR clearance pass".toUpperCase(),
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // QR Code Wrapper
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                        border: Border.all(color: AppTheme.outlineVariantColor, width: 0.5),
                      ),
                      child: QrImageView(
                        data: appointment.id,
                        version: QrVersions.auto,
                        size: 180.0,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: AppTheme.primaryColor,
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Pass ID: ${appointment.id}",
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        color: AppTheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Divider(height: 36),

                    // Detail list
                    _buildPassDetailRow("Visitor Name", "Alex Mercer"),
                    _buildPassDetailRow("Date", "${appointment.date.month}/${appointment.date.day}/${appointment.date.year}"),
                    _buildPassDetailRow("Scheduled Time", appointment.timeSlot),
                    _buildPassDetailRow("Clearance Status", appointment.status, isStatus: true),
                    
                    if (appointment.gateAccessCode != null) ...[
                      const Divider(height: 24),
                      _buildPassDetailRow("Gate Access", appointment.gateAccessCode!),
                      if (appointment.parkingBay != null)
                        _buildPassDetailRow("Parking Spot", appointment.parkingBay!),
                      _buildPassDetailRow("Door Entry Code", appointment.doorAccessCode!),
                    ]
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Add to Wallet Style Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Mock pass added to Apple / Google Wallet!"),
                        backgroundColor: Colors.black87,
                      ),
                    );
                  },
                  icon: const Icon(Icons.wallet, color: Colors.white),
                  label: const Text("ADD TO WALLET"),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPassDetailRow(String label, String value, {bool isStatus = false}) {
    Color? textColor;
    FontWeight fontWeight = FontWeight.bold;
    if (isStatus) {
      textColor = value == "Verified" ? AppTheme.successColor : AppTheme.pendingColor;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppTheme.onSurfaceVariant),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: fontWeight,
              color: textColor ?? AppTheme.onSurfaceColor,
            ),
          ),
        ],
      ),
    );
  }
}
