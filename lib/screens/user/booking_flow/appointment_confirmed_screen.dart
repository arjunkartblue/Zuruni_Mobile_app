import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../../theme/theme.dart';
import '../../../state/app_state.dart';
import '../../../utils/time_utils.dart';

class AppointmentConfirmedScreen extends StatefulWidget {
  final Appointment appointment;

  const AppointmentConfirmedScreen({Key? key, required this.appointment}) : super(key: key);

  @override
  State<AppointmentConfirmedScreen> createState() => _AppointmentConfirmedScreenState();
}

class _AppointmentConfirmedScreenState extends State<AppointmentConfirmedScreen> with SingleTickerProviderStateMixin {
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

  String _formatFullDate(DateTime date) {
    const weekdays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    final weekday = weekdays[date.weekday - 1];
    final month = months[date.month - 1];
    return "$weekday, $month ${date.day}, ${date.year}";
  }



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
    final hasParking = widget.appointment.parkingBay != null || appState.parkingNeeded;
    final parkingSlot = widget.appointment.parkingBay != null 
        ? widget.appointment.parkingBay!.split(' ')[0] 
        : "Slot B-12";
    final gate = widget.appointment.gateAccessCode != null 
        ? widget.appointment.gateAccessCode!.replaceAll(RegExp(r'[^0-9]'), '') 
        : "4";

    // Dynamic fee calculations matching Review & Pay screen
    double servicePrice = appState.selectedServicePrice ?? 85.0;
    double parkingPrice = hasParking ? 12.50 : 0.0;
    double convenienceFee = 5.00;
    double totalPaid = servicePrice + parkingPrice + convenienceFee;

    final serviceName = appState.selectedService ?? widget.appointment.category;
    final orgAddress = _getOrgAddress(widget.appointment.organizationName);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            children: [
              const SizedBox(height: 16),
              
              // Animated checkmark badge
              ScaleTransition(
                scale: _scaleAnim,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              Text(
                "Appointment Confirmed!",
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurfaceColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "We've sent a confirmation email to ${appState.userEmail.isNotEmpty ? appState.userEmail : 'alex.j@example.com'}",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),

              // Card 1: Main Booking Details
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
                      serviceName,
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
                    
                    // Date & Time Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.calendar_today_outlined, color: AppTheme.primaryColor, size: 18),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatFullDate(widget.appointment.date),
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.onSurfaceColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "${widget.appointment.timeSlot} — ${TimeUtils.getEndTimeSlot(widget.appointment.timeSlot)}",
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
                    const SizedBox(height: 16),
                    
                    // Location Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on_outlined, color: AppTheme.primaryColor, size: 18),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            orgAddress,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.onSurfaceColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Professional Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const CircleAvatar(
                          radius: 16,
                          backgroundColor: Color(0xFFFAF5FF),
                          child: Icon(Icons.person, color: AppTheme.primaryColor, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.appointment.professionalName,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.onSurfaceColor,
                                ),
                              ),
                              Text(
                                "Host",
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppTheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFFF1EBF1), height: 1),
                    const SizedBox(height: 16),

                    if (widget.appointment.tokenNumber != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "TOKEN NUMBER",
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  widget.appointment.tokenNumber!,
                                  style: GoogleFonts.hankenGrotesk(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Color(0xFFF1EBF1), height: 1),
                      const SizedBox(height: 16),
                    ],

                    // Reference ID Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "REFERENCE ID",
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.onSurfaceVariant.withOpacity(0.6),
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.appointment.id,
                              style: GoogleFonts.hankenGrotesk(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 18, color: AppTheme.primaryColor),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: widget.appointment.id));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Reference ID copied to clipboard!")),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Card 2: Access Details
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

              // Card 3: Logistics Timeline
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
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Card 4: Pass & QR Code Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF5FF),
                  borderRadius: BorderRadius.circular(AppTheme.radius2Xl),
                  boxShadow: AppTheme.ambientShadow,
                ),
                child: Column(
                  children: [
                    // Access Granted pill badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3E8FF),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE9D5FF)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.circle, color: AppTheme.primaryColor, size: 8),
                          const SizedBox(width: 6),
                          Text(
                            "Access Granted",
                            style: GoogleFonts.inter(
                              color: AppTheme.primaryColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // QR Code Container
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFF1EBF1)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: QrImageView(
                        data: widget.appointment.id,
                        version: QrVersions.auto,
                        size: 160.0,
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

                    // Explanation message
                    Text(
                      hasParking
                          ? "Scan this code at Gate $gate for entry and at $parkingSlot for parking."
                          : "Scan this code at Gate $gate for entry and lobby check-in.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.onSurfaceColor,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFFE9D5FF), height: 1),
                    const SizedBox(height: 16),

                    // Ref ID and Total Paid Info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Ref ID",
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.outlineColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.appointment.id,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.onSurfaceColor,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "Total Paid",
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.outlineColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "\$${totalPaid.toStringAsFixed(2)}",
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.onSurfaceColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Bottom buttons
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
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Mock Event added to Google Calendar!")),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.calendar_today_outlined, color: AppTheme.primaryColor, size: 18),
                  label: Text(
                    "Add to Calendar",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurfaceColor,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Return to Home",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurfaceColor,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeline(String timeSlot, bool parkingNeeded) {
    final times = _computeTimelineTimes(timeSlot);
    final List<Map<String, dynamic>> items = [
      {"time": times["Entry"], "title": "Entry", "active": false},
      {"time": times["Meeting Starts"], "title": "Meeting Starts", "active": false},
      {"time": times["Exit"], "title": "Exit", "active": false},
    ];
    if (parkingNeeded) {
      items.add({"time": times["Parking Checkout"], "title": "Parking Checkout", "active": false});
    }

    return Column(
      children: List.generate(items.length, (index) {
        final item = items[index];
        final isActive = item["active"] as bool;
        final isLast = index == items.length - 1;

        String description = "";
        if (item["title"] == "Entry") {
          description = isActive ? "Token scanned at Main Gate" : "Awaiting main gate verification";
        } else if (item["title"] == "Meeting Starts") {
          description = isActive ? "Checked in by receptionist" : "Awaiting receptionist check-in";
        } else if (item["title"] == "Exit") {
          description = isActive ? "Checked out successfully" : "Awaiting departure";
        } else if (item["title"] == "Parking Checkout") {
          description = isActive ? "Parking slot released" : "Awaiting vehicle departure";
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
                    child: isActive
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
                          color: isActive ? AppTheme.onSurfaceColor : AppTheme.onSurfaceVariant.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isActive ? AppTheme.onSurfaceVariant : AppTheme.onSurfaceVariant.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item["time"] as String,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isActive ? AppTheme.onSurfaceVariant.withOpacity(0.7) : AppTheme.onSurfaceVariant.withOpacity(0.4),
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
