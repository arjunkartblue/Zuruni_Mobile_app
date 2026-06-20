import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/theme.dart';
import '../../state/app_state.dart';
import 'visitor_pass_screen.dart';

class OperationalDashboardScreen extends StatefulWidget {
  final Appointment appointment;

  const OperationalDashboardScreen({Key? key, required this.appointment}) : super(key: key);

  @override
  State<OperationalDashboardScreen> createState() => _OperationalDashboardScreenState();
}

class _OperationalDashboardScreenState extends State<OperationalDashboardScreen> {
  late int _activeStepIndex;

  @override
  void initState() {
    super.initState();
    _activeStepIndex = widget.appointment.activeTimelineIndex;
  }

  void _nextTimelineStep() {
    if (_activeStepIndex < widget.appointment.timelineSteps.length - 1) {
      setState(() {
        _activeStepIndex++;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Access timeline updated: ${widget.appointment.timelineSteps[_activeStepIndex]}"),
          backgroundColor: AppTheme.successColor,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isVerified = widget.appointment.status == "Verified";

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
          "Access Dashboard",
          style: GoogleFonts.hankenGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.appointment.organizationName,
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${widget.appointment.professionalName} • ${widget.appointment.timeSlot}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isVerified ? AppTheme.successColor.withOpacity(0.1) : AppTheme.pendingColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      widget.appointment.status,
                      style: TextStyle(
                        color: isVerified ? AppTheme.successColor : AppTheme.pendingColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Access Codes Panel (Only if Verified)
              if (isVerified) ...[
                Text(
                  "Facility Access Details",
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 1.3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _buildAccessCard(
                      "Gate Entry Code",
                      widget.appointment.gateAccessCode ?? "N/A",
                      Icons.vpn_key_outlined,
                      "Tap to open gate",
                    ),
                    _buildAccessCard(
                      "Door Code",
                      widget.appointment.doorAccessCode ?? "N/A",
                      Icons.door_sliding_outlined,
                      "Unlock elevator",
                    ),
                    if (widget.appointment.parkingBay != null)
                      _buildAccessCard(
                        "Parking Spot",
                        widget.appointment.parkingBay!.split(" ")[0],
                        Icons.local_parking,
                        widget.appointment.parkingBay!.contains("(") 
                            ? widget.appointment.parkingBay!.substring(widget.appointment.parkingBay!.indexOf("(")) 
                            : "",
                      ),
                    _buildAccessCard(
                      "Visitor ID Pass",
                      widget.appointment.id,
                      Icons.qr_code,
                      "Tap to view pass",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VisitorPassScreen(appointment: widget.appointment),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 28),
              ],

              // Logistics Timeline Stepper
              Text(
                "Access Timeline Checklist",
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radius2Xl),
                  border: Border.all(color: AppTheme.outlineVariantColor),
                  boxShadow: AppTheme.ambientShadow,
                ),
                child: Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.appointment.timelineSteps.length,
                      itemBuilder: (context, index) {
                        final step = widget.appointment.timelineSteps[index];
                        final isDone = index < _activeStepIndex;
                        final isCurrent = index == _activeStepIndex;
                        final isLast = index == widget.appointment.timelineSteps.length - 1;
                        
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Timeline circle & line
                            Column(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: isDone 
                                        ? AppTheme.successColor 
                                        : (isCurrent ? AppTheme.primaryColor : Colors.white),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isDone 
                                          ? AppTheme.successColor 
                                          : (isCurrent ? AppTheme.primaryColor : AppTheme.outlineVariantColor),
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: isDone 
                                        ? const Icon(Icons.check, size: 12, color: Colors.white)
                                        : (isCurrent 
                                            ? Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle))
                                            : null),
                                  ),
                                ),
                                if (!isLast)
                                  Container(
                                    width: 2,
                                    height: 36,
                                    color: isDone ? AppTheme.successColor : AppTheme.surfaceContainerColor,
                                  ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            // Text Detail
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 2.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      step,
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: isCurrent ? FontWeight.bold : (isDone ? FontWeight.w500 : FontWeight.normal),
                                        color: isCurrent 
                                            ? AppTheme.primaryColor 
                                            : (isDone ? AppTheme.onSurfaceColor : AppTheme.onSurfaceVariant),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    if (isCurrent)
                                      Text(
                                        "Current Status",
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.primaryColor.withOpacity(0.8),
                                        ),
                                      )
                                    else if (isDone)
                                      const Text(
                                        "Completed",
                                        style: TextStyle(fontSize: 11, color: AppTheme.successColor),
                                      ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        );
                      },
                    ),
                    
                    // Demo Timeline Trigger (Advance Button)
                    if (_activeStepIndex < widget.appointment.timelineSteps.length - 1) ...[
                      const Divider(height: 32),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                          ),
                        ),
                        onPressed: _nextTimelineStep,
                        icon: const Icon(Icons.play_arrow_outlined, color: AppTheme.primaryColor),
                        label: const Text(
                          "SIMULATE NEXT ACCESS STEP",
                          style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Directions/Map Block
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                  border: Border.all(color: AppTheme.outlineVariantColor),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerColor,
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      ),
                      child: const Icon(Icons.navigation_outlined, color: AppTheme.primaryColor),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Facility Directions",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Open Vantage Medical Group in Google Maps",
                            style: TextStyle(fontSize: 12, color: AppTheme.primaryColor.withOpacity(0.8)),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppTheme.outlineColor),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: isVerified 
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VisitorPassScreen(appointment: widget.appointment),
                      ),
                    );
                  },
                  child: const Text("VIEW QR VISITOR PASS"),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildAccessCard(String title, String code, IconData icon, String footnote, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          border: Border.all(color: AppTheme.outlineVariantColor),
          boxShadow: AppTheme.ambientShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 11, color: AppTheme.onSurfaceVariant, fontWeight: FontWeight.w600),
                ),
                Icon(icon, size: 16, color: AppTheme.primaryColor),
              ],
            ),
            Text(
              code,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            Text(
              footnote,
              style: const TextStyle(fontSize: 10, color: AppTheme.successColor, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
