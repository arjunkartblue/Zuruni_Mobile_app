import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../theme/theme.dart';
import '../../../state/app_state.dart';
import '../../../utils/time_utils.dart';
import '../../../widgets/appointment_status_header.dart';
import 'visitor_pass_screen.dart';

class AppointmentOverviewScreen extends StatefulWidget {
  final Appointment appointment;

  const AppointmentOverviewScreen({Key? key, required this.appointment}) : super(key: key);

  @override
  State<AppointmentOverviewScreen> createState() => _AppointmentOverviewScreenState();
}

class _AppointmentOverviewScreenState extends State<AppointmentOverviewScreen> {
  int _activeTimelineIndex = 0;



  String _getOrgAddress(String orgName) {
    if (orgName.contains("Vantage")) return "Building A, Floor 4, Suite 402";
    if (orgName.contains("Sterling")) return "Sterling Tower, Floor 12, Suite 1205";
    if (orgName.contains("Aesthetic")) return "Aesthetic Plaza, Level 2, Suite 210";
    if (orgName.contains("Nexus")) return "Nexus Building, Level 8, Suite 803";
    if (orgName.contains("Ascent")) return "Ascent Chamber, Floor 5, Suite 501";
    if (orgName.contains("Lumina")) return "Lumina Medical Hub, Floor 1, Suite 101";
    return "Building A, Floor 4, Suite 402";
  }

  String _getFloorFromAddress(String address) {
    final regExp = RegExp(r'(Floor \d+|Level \d+|Hub)');
    final match = regExp.firstMatch(address);
    return match != null ? match.group(0)! : "Floor 4";
  }

  Map<String, String> _computeTimelineTimes(String timeSlot) {
    try {
      final parts = timeSlot.split(" ");
      final timeParts = parts[0].split(":");
      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);
      String period = parts[1];

      int totalMinutes = (period == "PM" && hour != 12) ? (hour + 12) * 60 + minute : (period == "AM" && hour == 12) ? minute : hour * 60 + minute;

      String formatTime(int minutes) {
        int h = (minutes ~/ 60) % 24;
        int m = minutes % 60;
        String p = h >= 12 ? "PM" : "AM";
        int displayH = h % 12;
        if (displayH == 0) displayH = 12;
        return "${displayH.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} $p";
      }

      return {
        "Entry": formatTime(totalMinutes - 15),
        "Meeting Starts": formatTime(totalMinutes),
        "Exit": formatTime(totalMinutes + 60),
        "Parking Checkout": formatTime(totalMinutes + 75),
      };
    } catch (e) {
      return {
        "Entry": "09:15 AM",
        "Meeting Starts": "09:30 AM",
        "Exit": "10:30 AM",
        "Parking Checkout": "10:45 AM",
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isVerified = widget.appointment.status == "Verified";
    final isCancelled = widget.appointment.status == "Cancelled";
    final hasParking = widget.appointment.parkingBay != null || appState.parkingNeeded;
    final gate = widget.appointment.gateAccessCode != null 
        ? widget.appointment.gateAccessCode!.replaceAll(RegExp(r'[^0-9]'), '') 
        : "4";

    Color statusColor = AppTheme.pendingColor;
    String statusText = "PENDING CLEARANCE";
    if (isVerified) {
      statusColor = AppTheme.successColor;
      statusText = "CONFIRMED";
    } else if (isCancelled) {
      statusColor = AppTheme.errorColor;
      statusText = "CANCELLED";
    }

    final orgAddress = _getOrgAddress(widget.appointment.organizationName);

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
          "Appointment Overview",
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
              // Status Header Card
              AppointmentStatusHeader(
                statusColor: statusColor,
                statusText: statusText,
                statusMessage: isVerified
                    ? "Your digital entry pass is active"
                    : (isCancelled ? "This visit was cancelled" : "Identity verification in progress"),
              ),
              const SizedBox(height: 20),

              // Appointment Details Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radius2Xl),
                  boxShadow: AppTheme.ambientShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.appointment.category,
                      style: GoogleFonts.hankenGrotesk(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.onSurfaceColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.appointment.organizationName.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.onSurfaceVariant.withOpacity(0.6),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFFF1EBF1), height: 1),
                    const SizedBox(height: 16),

                    // Service Row
                    _buildDetailRow(
                      icon: Icons.assignment_outlined,
                      label: "Service",
                      value: widget.appointment.serviceName,
                    ),
                    if (widget.appointment.tokenNumber != null) ...[
                      const SizedBox(height: 16),
                      _buildDetailRow(
                        icon: Icons.confirmation_num_outlined,
                        label: "Token Number",
                        value: widget.appointment.tokenNumber!,
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Date & Time Row
                    _buildDetailRow(
                      icon: Icons.calendar_today_outlined,
                      label: "Date & Time",
                      value: AppTheme.formatDate(widget.appointment.date),
                      subvalue: "${widget.appointment.timeSlot} — ${TimeUtils.getEndTimeSlot(widget.appointment.timeSlot)}",
                    ),
                    const SizedBox(height: 16),

                    // Location Row
                    _buildDetailRow(
                      icon: Icons.location_on_outlined,
                      label: "Location",
                      value: orgAddress,
                    ),
                    const SizedBox(height: 16),

                    // Host Row
                    _buildDetailRow(
                      icon: Icons.person_outline,
                      label: "Host Professional",
                      value: widget.appointment.professionalName,
                      subvalue: "Host Reference ID: ${widget.appointment.id}",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Access Details Card (Only if Verified/Confirmed)
              if (isVerified) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radius2Xl),
                    boxShadow: AppTheme.ambientShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Access Details",
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.onSurfaceColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Gate Entry
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFAF5FF),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.domain_outlined, color: AppTheme.primaryColor, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Gate Entry",
                                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.onSurfaceColor),
                                ),
                                Text(
                                  "Gate $gate, scan QR",
                                  style: GoogleFonts.inter(fontSize: 13, color: AppTheme.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Door Access
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFAF5FF),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.vpn_key_outlined, color: AppTheme.primaryColor, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Door Access",
                                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.onSurfaceColor),
                                ),
                                Text(
                                  "${_getFloorFromAddress(orgAddress)}, secure access granted via QR",
                                  style: GoogleFonts.inter(fontSize: 13, color: AppTheme.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Red warning container
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.shield_outlined, color: Color(0xFFEF4444), size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Security Note: ID required at lobby",
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF991B1B),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Logistics Timeline Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radius2Xl),
                  boxShadow: AppTheme.ambientShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Logistics Timeline",
                      style: GoogleFonts.hankenGrotesk(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.onSurfaceColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTimeline(widget.appointment.timeSlot, hasParking),
                    const SizedBox(height: 16),
                    
                    // Simulate Progress Button
                    Center(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          final stepsCount = hasParking ? 4 : 3;
                          setState(() {
                            if (_activeTimelineIndex < stepsCount - 1) {
                              _activeTimelineIndex++;
                            } else {
                              _activeTimelineIndex = 0; // Reset for demo/simulation
                            }
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(_activeTimelineIndex == 0 
                                  ? "Timeline reset to start." 
                                  : "Simulated timeline progress advanced!"),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.play_arrow_outlined, color: AppTheme.primaryColor, size: 16),
                        label: Text(
                          "Simulate Timeline Progress",
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // View Digital Pass (QR code) Button
              if (!isCancelled && isVerified) ...[
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VisitorPassScreen(appointment: widget.appointment),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.qr_code, color: Colors.white, size: 18),
                    label: const Text("View Digital Pass", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    String? subvalue,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurfaceVariant.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurfaceColor,
                ),
              ),
              if (subvalue != null) ...[
                const SizedBox(height: 2),
                Text(
                  subvalue,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeline(String timeSlot, bool parkingNeeded) {
    final times = _computeTimelineTimes(timeSlot);
    final List<Map<String, dynamic>> items = [
      {"time": times["Entry"], "title": "Entry"},
      {"time": times["Meeting Starts"], "title": "Meeting Starts"},
      {"time": times["Exit"], "title": "Exit"},
    ];
    if (parkingNeeded) {
      items.add({"time": times["Parking Checkout"], "title": "Parking Checkout"});
    }

    return Column(
      children: List.generate(items.length, (index) {
        final item = items[index];
        final isDoneOrCurrent = index <= _activeTimelineIndex;
        final isLast = index == items.length - 1;

        String description = "";
        if (item["title"] == "Entry") {
          description = isDoneOrCurrent ? "Token scanned at Main Gate" : "Awaiting main gate verification";
        } else if (item["title"] == "Meeting Starts") {
          description = isDoneOrCurrent ? "Checked in by receptionist" : "Awaiting receptionist check-in";
        } else if (item["title"] == "Exit") {
          description = isDoneOrCurrent ? "Checked out successfully" : "Awaiting departure";
        } else if (item["title"] == "Parking Checkout") {
          description = isDoneOrCurrent ? "Parking slot released" : "Awaiting vehicle departure";
        }

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Indicator column (circle checkmark / grey dot + line)
              Column(
                children: [
                  const SizedBox(height: 4),
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    child: isDoneOrCurrent
                        ? Container(
                            width: 22,
                            height: 22,
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 12,
                            ),
                          )
                        : Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Color(0xFFCBD5E1),
                              shape: BoxShape.circle,
                            ),
                          ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2.0,
                        color: const Color(0xFFE2E8F0),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              
              // Text Content Column (Title, Description, Time)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item["title"] as String,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDoneOrCurrent ? AppTheme.onSurfaceColor : AppTheme.onSurfaceVariant.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isDoneOrCurrent ? AppTheme.onSurfaceVariant : AppTheme.onSurfaceVariant.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item["time"] as String,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDoneOrCurrent ? AppTheme.onSurfaceVariant.withOpacity(0.7) : AppTheme.onSurfaceVariant.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
