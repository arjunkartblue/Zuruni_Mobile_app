import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/theme.dart';
import '../../state/app_state.dart';

class BookingDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> item;
  const BookingDetailsScreen({super.key, required this.item});

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  bool _showRejectInput = false;
  String _selectedReason = "Schedule Conflict";
  final TextEditingController _customReasonController = TextEditingController();

  final List<String> _rejectionReasons = [
    "Schedule Conflict",
    "Security Concern",
    "Outside Visiting Hours",
    "Custom Reason",
  ];

  @override
  void dispose() {
    _customReasonController.dispose();
    super.dispose();
  }

  Widget _buildInitialsAvatar(String initials) {
    return Container(
      width: 80,
      height: 80,
      decoration: const BoxDecoration(
        color: Color(0xFFF1F5F9),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.bold,
          fontSize: 24,
          color: const Color(0xFF475569),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    
    // Find current state of the item in AppState to reflect updates in real-time
    final currentItem = appState.staffAllApprovals.firstWhere(
      (element) => element["id"] == widget.item["id"],
      orElse: () => widget.item,
    );

    final hasAvatar = currentItem["avatar"].toString().isNotEmpty;
    final initials = currentItem["name"]
        .toString()
        .split(" ")
        .map((s) => s.isNotEmpty ? s[0] : "")
        .join("");

    final String status = currentItem["status"] ?? "Pending";
    final bool arrived = currentItem["arrived"] ?? false;

    // Derived fields for mock data visual match
    final String visitorId = currentItem["id"] ?? "V-84729";
    final String email = "${currentItem['name'].toString().toLowerCase().replaceAll(' ', '.')}@techcorp.com";
    const String phone = "+1 (555) 019-2834";
    final String company = currentItem["type"] == "Interview" ? "TechCorp Inc." : "Global Logistics";
    final String title = currentItem["type"] == "Interview" ? "Lead Systems Engineer" : "Delivery Executive";

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
          "Booking Details",
          style: GoogleFonts.hankenGrotesk(
            fontWeight: FontWeight.bold,
            color: AppTheme.onSurfaceColor,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Profile Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radius2Xl),
                boxShadow: AppTheme.ambientShadow,
                border: Border.all(color: const Color(0xFFFAF1F9), width: 1),
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      if (hasAvatar)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: Image.network(
                            currentItem["avatar"],
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildInitialsAvatar(initials),
                          ),
                        )
                      else
                        _buildInitialsAvatar(initials),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.verified,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    currentItem["name"],
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurfaceColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$company • $title",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppTheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Info Pills Row
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildInfoPill(Icons.badge_outlined, "ID: $visitorId"),
                      _buildInfoPill(Icons.phone_outlined, phone),
                      _buildInfoPill(Icons.mail_outline, email),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Appointment Details Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radius2Xl),
                boxShadow: AppTheme.ambientShadow,
                border: Border.all(color: const Color(0xFFFAF1F9), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Appointment Details",
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurfaceColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Divider(color: Color(0xFFF1F5F9), thickness: 1),
                  const SizedBox(height: 12),

                  // Host
                  _buildDetailRow(
                    Icons.person_outline,
                    "Host",
                    "Alex Rivers",
                  ),
                  const SizedBox(height: 16),

                  // Purpose of Visit Card
                  Text(
                    "Purpose of Visit",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF1F9),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.handshake_outlined,
                          color: AppTheme.secondaryColor,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            currentItem["reason"],
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppTheme.onSurfaceColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Date & Time
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Date",
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Oct 24, 2023",
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.onSurfaceColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Time",
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "14:00 - 15:30",
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.onSurfaceColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Gate Token
                  Text(
                    "Gate Token",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1EEF4),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      border: Border.all(color: const Color(0xFFE5DCE9), width: 1),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "TKN-${currentItem['token']?.replaceAll('T-', '') ?? '948A'}",
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. Reserved Parking Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF5FA),
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                border: Border.all(color: const Color(0xFFF3E7F3), width: 1),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              "P",
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: AppTheme.secondaryColor,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "Reserved Parking",
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Slot B-12",
                          style: GoogleFonts.hankenGrotesk(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.onSurfaceColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "North Garage, Level 2",
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEADCEE),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.directions_car_filled,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 4. Status Tracking Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radius2Xl),
                boxShadow: AppTheme.ambientShadow,
                border: Border.all(color: const Color(0xFFFAF1F9), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.trending_up,
                            color: AppTheme.onSurfaceColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Status Tracking",
                            style: GoogleFonts.hankenGrotesk(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.onSurfaceColor,
                            ),
                          ),
                        ],
                      ),
                      _buildStatusPill(status, arrived),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Divider(color: Color(0xFFF1F5F9), thickness: 1),
                  const SizedBox(height: 16),

                  // Vertical Timeline
                  _buildTimeline(status, arrived),
                ],
              ),
            ),
            
            // Rejection form inputs (if reject clicked)
            if (_showRejectInput) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radius2Xl),
                  boxShadow: AppTheme.ambientShadow,
                  border: Border.all(color: Colors.red.shade100, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "REJECTION REASON",
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade900,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.outlineVariantColor),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedReason,
                          isExpanded: true,
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedReason = val;
                              });
                            }
                          },
                          items: _rejectionReasons.map((String reason) {
                            return DropdownMenuItem<String>(
                              value: reason,
                              child: Text(
                                reason,
                                style: GoogleFonts.inter(fontSize: 13),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    if (_selectedReason == "Custom Reason") ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: _customReasonController,
                        style: GoogleFonts.inter(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: "Enter custom reason...",
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _showRejectInput = false;
                            });
                          },
                          child: Text(
                            "Cancel",
                            style: GoogleFonts.inter(
                              color: AppTheme.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () {
                            final reason = _selectedReason == "Custom Reason"
                                ? _customReasonController.text
                                : _selectedReason;
                            appState.rejectVisitorRequest(currentItem["id"]);
                            setState(() {
                              _showRejectInput = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Rejected visitor ${currentItem['name']} (Reason: $reason)"),
                                backgroundColor: AppTheme.errorColor,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.errorColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                            ),
                          ),
                          child: const Text("Confirm Reject"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // 5. Bottom Action Container (Using Default Buttons Theme!)
            if (!_showRejectInput)
              _buildBottomActionButtons(appState, currentItem, status, arrived),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoPill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1EEF4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppTheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppTheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.onSurfaceColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusPill(String status, bool arrived) {
    String label = status.toUpperCase();
    Color bgColor = const Color(0xFFFFFBEB);
    Color textColor = const Color(0xFFB45309);

    if (status == "Approved") {
      if (arrived) {
        label = "ACTIVE VISIT";
        bgColor = const Color(0xFFFAF1F9);
        textColor = AppTheme.secondaryColor;
      } else {
        label = "APPROVED";
        bgColor = const Color(0xFFECFDF5);
        textColor = const Color(0xFF047857);
      }
    } else if (status == "Rejected") {
      bgColor = const Color(0xFFFEF2F2);
      textColor = const Color(0xFFB91C1C);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: textColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: textColor,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(String status, bool arrived) {
    final bool isApproved = status == "Approved";
    final bool isRejected = status == "Rejected";

    return Column(
      children: [
        // Step 1: Booked
        _buildTimelineItem(
          title: "Appointment Booked",
          subtitle: "Created by Alex Rivers",
          time: "10:45 AM",
          isActive: true,
          isCompleted: true,
          showConnector: true,
        ),
        // Step 2: Gate Entry
        _buildTimelineItem(
          title: "Gate Entry Verified",
          subtitle: isApproved ? "Token scanned at Main Gate" : (isRejected ? "Access Denied at Gate" : "Awaiting scan..."),
          time: isApproved ? "13:52 PM" : "--:--",
          isActive: isApproved || isRejected,
          isCompleted: isApproved,
          showConnector: true,
        ),
        // Step 3: Checked In
        _buildTimelineItem(
          title: "Checked In",
          subtitle: arrived ? "Reception Lobby A - ID Badge Issued" : "Awaiting receptionist check-in",
          time: arrived ? "13:58 PM" : "--:--",
          isActive: arrived,
          isCompleted: arrived,
          showConnector: true,
          highlightBox: arrived,
        ),
        // Step 4: Checked Out
        _buildTimelineItem(
          title: "Checked Out",
          subtitle: "Awaiting departure",
          time: "--:--",
          isActive: false,
          isCompleted: false,
          showConnector: false,
        ),
      ],
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required String subtitle,
    required String time,
    required bool isActive,
    required bool isCompleted,
    required bool showConnector,
    bool highlightBox = false,
  }) {
    Color nodeColor = Colors.grey.shade300;
    Widget icon = Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: nodeColor,
        shape: BoxShape.circle,
      ),
    );

    if (isActive) {
      nodeColor = AppTheme.primaryColor;
      if (isCompleted) {
        icon = Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.check, color: Colors.white, size: 12),
        );
      } else {
        icon = Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.secondaryColor, width: 4),
          ),
        );
      }
    }

    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isActive ? AppTheme.onSurfaceColor : Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: isActive ? AppTheme.onSurfaceVariant : Colors.grey.shade400,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          time,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: Colors.grey.shade400,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );

    if (highlightBox) {
      content = Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF2FE),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFF9E0F8)),
        ),
        child: content,
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              const SizedBox(height: 4),
              SizedBox(
                width: 24,
                child: Center(child: icon),
              ),
              if (showConnector)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.grey.shade300,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: content,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionButtons(
    AppState appState,
    Map<String, dynamic> currentItem,
    String status,
    bool arrived,
  ) {
    // Top Info message (e.g. Auto-checkout message)
    Widget? messageWidget;
    if (status == "Approved" && arrived) {
      messageWidget = Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.circle, size: 8, color: AppTheme.secondaryColor),
            const SizedBox(width: 6),
            Text(
              "Auto-checkout armed for 16:00",
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    List<Widget> buttons = [];

    if (status == "Pending") {
      buttons = [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _showRejectInput = true;
              });
            },
            icon: const Icon(Icons.close, size: 18),
            label: const Text("Reject"),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
              side: const BorderSide(color: AppTheme.errorColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              appState.approveVisitorRequest(currentItem["id"]);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Approved visitor ${currentItem['name']}"),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            icon: const Icon(Icons.check, size: 18),
            label: const Text("Approve"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ];
    } else if (status == "Approved") {
      buttons = [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Edit feature is under development")),
              );
            },
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text("Edit"),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
              side: const BorderSide(color: AppTheme.primaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              appState.toggleArrivalStatus(currentItem["id"]);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    arrived 
                        ? "Checked out visitor ${currentItem['name']}"
                        : "Checked in visitor ${currentItem['name']}",
                  ),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            icon: Icon(arrived ? Icons.logout : Icons.login, size: 18),
            label: Text(arrived ? "Manual Check Out" : "Check In"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ];
    } else {
      // Rejected
      buttons = [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              appState.approveVisitorRequest(currentItem["id"]);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Re-approved visitor ${currentItem['name']}"),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text("Re-approve Booking"),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
              side: const BorderSide(color: AppTheme.primaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ];
    }

    return Column(
      children: [
        if (messageWidget != null) messageWidget,
        Row(children: buttons),
      ],
    );
  }
}
