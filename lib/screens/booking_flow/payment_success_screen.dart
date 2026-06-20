import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/theme.dart';
import '../../state/app_state.dart';
import '../visitor_access/operational_dashboard_screen.dart';
import '../visitor_access/visitor_pass_screen.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final Appointment appointment;

  const PaymentSuccessScreen({Key? key, required this.appointment}) : super(key: key);

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isVerified = widget.appointment.status == "Verified";

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              
              // Animated checkmark
              ScaleTransition(
                scale: _scaleAnim,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_circle,
                      color: AppTheme.successColor,
                      size: 56,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              Text(
                "Payment Confirmed",
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Your appointment has been successfully scheduled",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),

              // Booking Detail Card
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radius2Xl),
                  border: Border.all(color: AppTheme.outlineVariantColor),
                  boxShadow: AppTheme.ambientShadow,
                ),
                child: Column(
                  children: [
                    _buildRow("Booking ID", widget.appointment.id),
                    _buildRow("Organization", widget.appointment.organizationName),
                    _buildRow("Professional", widget.appointment.professionalName),
                    _buildRow(
                      "Date & Time",
                      "${widget.appointment.date.month}/${widget.appointment.date.day}/${widget.appointment.date.year} at ${widget.appointment.timeSlot}",
                    ),
                    const Divider(height: 24),
                    
                    // Access Clearance Info
                    if (isVerified) ...[
                      _buildAccessRow("Gate Entry Access", widget.appointment.gateAccessCode ?? "Assigned"),
                      if (widget.appointment.parkingBay != null)
                        _buildAccessRow("Parking Bay", widget.appointment.parkingBay!),
                      _buildAccessRow("Door Access Code", widget.appointment.doorAccessCode ?? "Assigned"),
                    ] else ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline, color: AppTheme.pendingColor, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Digital visitor passes will activate once identity verification is completed in your profile.",
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppTheme.onSurfaceVariant,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Quick action: Add to Calendar
              TextButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Mock Event added to Google Calendar!")),
                  );
                },
                icon: const Icon(Icons.calendar_today_outlined, color: AppTheme.primaryColor),
                label: const Text(
                  "ADD TO CALENDAR",
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Main CTAs
              if (isVerified)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VisitorPassScreen(appointment: widget.appointment),
                        ),
                      );
                    },
                    child: const Text("GET DIGITAL PASS"),
                  ),
                ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                    ),
                  ),
                  onPressed: () {
                    // Navigate to Dashboard
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OperationalDashboardScreen(appointment: widget.appointment),
                      ),
                    );
                  },
                  child: Text(
                    isVerified ? "VISIT DASHBOARD" : "VIEW BOOKING DETAILS",
                    style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Back to Home
              TextButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text(
                  "Return to Home Explorer",
                  style: TextStyle(color: AppTheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.onSurfaceVariant)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildAccessRow(String label, String code) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.onSurfaceVariant)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.successColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              code,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppTheme.successColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
