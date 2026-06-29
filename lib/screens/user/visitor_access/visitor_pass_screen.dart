import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';
import '../../../theme/theme.dart';
import '../../../state/app_state.dart';
import '../../../utils/time_utils.dart';

class VisitorPassScreen extends StatelessWidget {
  final Appointment appointment;

  const VisitorPassScreen({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.onSurfaceColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              // Checked Circular Avatar & Title
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3E8FF), // light purple
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFE9D5FF), width: 1.5),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.check_circle_rounded,
                          color: AppTheme.primaryColor,
                          size: 32,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Digital Pass",
                      style: GoogleFonts.hankenGrotesk(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Your entry is confirmed.",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.onSurfaceVariant.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Section 1: Scan for Entry & Parking Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radius2Xl),
                  boxShadow: AppTheme.ambientShadow,
                ),
                child: Column(
                  children: [
                    Text(
                      "SCAN FOR ENTRY & PARKING",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.onSurfaceVariant.withOpacity(0.6),
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // QR Code Image
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFF1EBF1)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: QrImageView(
                        data: appointment.id,
                        version: QrVersions.auto,
                        size: 140.0,
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
                    const SizedBox(height: 16),
                    
                    Text(
                      "Present this code at ${appointment.gateAccessCode ?? 'Gate 4'} and Parking ${appointment.parkingBay != null ? 'Slot ${appointment.parkingBay!.split(' ')[0]}' : 'Slot B-12'}.",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.onSurfaceColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Section 2: Visitor Details Card
              _buildDetailsCard(
                icon: Icons.person_outline,
                title: "Visitor Details",
                children: [
                  _buildDetailRow("Name", appState.userName.isNotEmpty ? appState.userName : "Alex Johnson"),
                  _buildDetailRow("Mobile", appState.userPhone.isNotEmpty ? appState.userPhone : "+1 555-0199"),
                  if (appState.visitorNames.isNotEmpty && appState.visitorNames.any((n) => n.trim().isNotEmpty))
                    _buildDetailRow("Companions", appState.visitorNames.where((n) => n.trim().isNotEmpty).join(", ")),
                  _buildDetailRow("Vehicle", appState.vehicleNumber.isNotEmpty ? appState.vehicleNumber : "ABC-1234"),
                ],
              ),

              // Section 3: Meeting Details Card
              _buildDetailsCard(
                icon: Icons.calendar_today_outlined,
                title: "Meeting Details",
                children: [
                  _buildDetailRow("Host", appointment.professionalName),
                  _buildDetailRow("Date", AppTheme.formatDate(appointment.date)),
                  _buildDetailRow("Time", "${appointment.timeSlot} - ${TimeUtils.getEndTimeSlot(appointment.timeSlot)}"),
                  _buildDetailRow("Location", "${appointment.organizationName}, Suite 402", isPurpleAction: true),
                ],
              ),

              // Section 4: Access & Parking Card
              _buildDetailsCard(
                icon: Icons.directions_car_filled_outlined,
                title: "Access & Parking",
                children: [
                  _buildAccessRow(
                    "Entry Gate",
                    appointment.gateAccessCode != null ? "${appointment.gateAccessCode} Entry" : "Gate 4 Entry",
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF5FF), // light purple
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        "Approved",
                        style: TextStyle(
                          color: Color(0xFF6B21A8),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const Divider(color: Color(0xFFF1EBF1), height: 20),
                  _buildAccessRow(
                    "Parking Space",
                    appointment.parkingBay != null ? "Slot ${appointment.parkingBay!.split(' ')[0]}" : "Slot B-12",
                  ),
                  const Divider(color: Color(0xFFF1EBF1), height: 20),
                  _buildAccessRow(
                    "Instructions",
                    "Scan QR at gate and parking bay for automated access.",
                    isSmallText: true,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Download Pass Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Downloading pass to device...")),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.download, color: Colors.white, size: 18),
                  label: const Text("Download Pass", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),

              // Share Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Opening share panel...")),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    backgroundColor: Colors.white,
                    side: BorderSide(color: AppTheme.primaryColor.withOpacity(0.15)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.share_outlined, color: AppTheme.primaryColor, size: 18),
                  label: const Text("Share via WhatsApp/Email", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radius2Xl),
        boxShadow: AppTheme.ambientShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFFAF5FF), // light purple
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radius2Xl)),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppTheme.primaryColor, size: 18),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.hankenGrotesk(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          
          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isPurpleAction = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppTheme.onSurfaceVariant),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurfaceColor,
                ),
              ),
              if (isPurpleAction) ...[
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.explore_outlined, size: 12, color: AppTheme.primaryColor),
                    const SizedBox(width: 4),
                    Text(
                      "Open in Maps",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ]
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccessRow(String label, String value, {Widget? trailing, bool isSmallText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.onSurfaceVariant.withOpacity(0.6),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isSmallText ? 12 : 14,
                    fontWeight: isSmallText ? FontWeight.w500 : FontWeight.bold,
                    color: isSmallText ? AppTheme.onSurfaceVariant : AppTheme.onSurfaceColor,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }


}
