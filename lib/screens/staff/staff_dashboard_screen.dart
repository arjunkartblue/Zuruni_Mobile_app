import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/theme.dart';
import '../../state/app_state.dart';
import 'collections_dashboard_screen.dart';
import 'book_for_visitor_screen.dart';
import 'pending_approvals_list_screen.dart';
import 'new_meeting_screen.dart';

class StaffDashboardScreen extends StatelessWidget {
  final Function(int) onViewAllApprovals;

  const StaffDashboardScreen({
    Key? key,
    required this.onViewAllApprovals,
  }) : super(key: key);

  String _getLiveDate() {
    final now = DateTime.now();
    final weekdays = [
      "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"
    ];
    final months = [
      "January", "February", "March", "April", "May", "June", 
      "July", "August", "September", "October", "November", "December"
    ];
    final weekday = weekdays[now.weekday - 1];
    final month = months[now.month - 1];
    return "$weekday, $month ${now.day}";
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final pendingApprovals = appState.staffPendingApprovals;

    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Text(
                _getLiveDate().toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.onSurfaceVariant.withOpacity(0.5),
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Welcome back, Alex",
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.onSurfaceColor,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "Senior Manager • HR",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),

              // Quick Actions Row
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NewMeetingScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text(
                      "New Meeting",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const BookForVisitorScreen()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      side: const BorderSide(color: AppTheme.primaryColor),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                      ),
                    ),
                    child: const Text(
                      "Book on Behalf",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Up Next Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF3B0764), // Deep Amethyst
                      Color(0xFF290A45), // Dark Amethyst
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: AppTheme.ambientShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Up Next Label & Calendar icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF10B981), // Pulsing green dot
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "UP NEXT • 10:00 AM",
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.calendar_today_outlined, color: Colors.white70, size: 20),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "James Wilson",
                      style: GoogleFonts.hankenGrotesk(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.place_outlined, color: Colors.white70, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          "Boardroom A",
                          style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () {
                                _showMockDialog(context, "Meeting Details: James Wilson");
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.9),
                                foregroundColor: const Color(0xFF290A45),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                "View Details",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.more_horiz, color: Colors.white),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Stats Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  // Appointments Stat
                  _buildStatCard(
                    context: context,
                    icon: Icons.calendar_today,
                    iconBgColor: AppTheme.surfaceContainerLow,
                    iconColor: AppTheme.primaryColor,
                    value: "12",
                    suffix: " / 20 slots",
                    label: "Appointments",
                  ),
                  // Pending Approvals Stat
                  _buildStatCard(
                    context: context,
                    icon: Icons.fact_check,
                    iconBgColor: AppTheme.surfaceContainerLow,
                    iconColor: AppTheme.primaryColor,
                    value: pendingApprovals.length.toString(),
                    label: "Pending Approvals",
                    showRedDot: pendingApprovals.isNotEmpty,
                    onTap: () => onViewAllApprovals(1), // Switches tab to Booking
                  ),
                  // Next Token Stat
                  _buildStatCard(
                    context: context,
                    icon: Icons.confirmation_number_outlined,
                    iconBgColor: AppTheme.surfaceContainerLow,
                    iconColor: AppTheme.primaryColor,
                    value: "A-102",
                    label: "Next Token",
                  ),
                  // Live Checked-In
                  _buildStatCard(
                    context: context,
                    icon: Icons.people_outline,
                    iconBgColor: AppTheme.surfaceContainerLow,
                    iconColor: AppTheme.primaryColor,
                    value: "8",
                    label: "Checked-in Today",
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Collections Card
              _buildStatCard(
                context: context,
                icon: Icons.payments_outlined,
                iconBgColor: AppTheme.surfaceContainerLow,
                iconColor: AppTheme.primaryColor,
                value: "\$1,240.00",
                label: "Total Collections",
                isFullWidth: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CollectionsDashboardScreen()),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Pending Approvals Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Pending Approvals",
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurfaceColor,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PendingApprovalsListScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "View All",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Preview list of top 2 pending approvals
              pendingApprovals.isEmpty
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.outlineVariantColor.withOpacity(0.2)),
                      ),
                      child: Center(
                        child: Text(
                          "No pending approvals",
                          style: GoogleFonts.inter(
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: pendingApprovals.length > 2 ? 2 : pendingApprovals.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = pendingApprovals[index];
                        final initials = item["name"]
                            .toString()
                            .split(" ")
                            .map((s) => s.isNotEmpty ? s[0] : "")
                            .join("");

                        return ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: AppTheme.ambientShadow,
                              border: Border(
                                left: BorderSide(
                                  color: index % 2 == 0 ? const Color(0xFFF59E0B) : const Color(0xFF764AA0),
                                  width: 4,
                                ),
                                top: BorderSide(color: AppTheme.outlineVariantColor.withOpacity(0.15)),
                                right: BorderSide(color: AppTheme.outlineVariantColor.withOpacity(0.15)),
                                bottom: BorderSide(color: AppTheme.outlineVariantColor.withOpacity(0.15)),
                              ),
                            ),
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFF1F5F9),
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        initials,
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: const Color(0xFF475569),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item["name"],
                                            style: GoogleFonts.inter(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: AppTheme.onSurfaceColor,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFFAF1F9),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  item["type"].toString().toUpperCase(),
                                                  style: GoogleFonts.inter(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.w800,
                                                    color: AppTheme.primaryColor,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              const Icon(Icons.access_time, size: 12, color: AppTheme.onSurfaceVariant),
                                              const SizedBox(width: 4),
                                              Text(
                                                item["time"].toString().replaceFirst("Today, ", "").replaceFirst("Tomorrow, ", ""),
                                                style: GoogleFonts.inter(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: AppTheme.onSurfaceVariant,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        height: 44,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Provider.of<AppState>(context, listen: false)
                                                .rejectVisitorRequest(item["id"]);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFFF4EBF4),
                                            foregroundColor: AppTheme.onSurfaceVariant,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            elevation: 0,
                                          ),
                                          child: const Text(
                                            "Reject",
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: SizedBox(
                                        height: 44,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Provider.of<AppState>(context, listen: false)
                                                .approveVisitorRequest(item["id"]);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppTheme.primaryColor,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            elevation: 0,
                                          ),
                                          child: const Text(
                                            "Approve",
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String value,
    String? suffix,
    required String label,
    bool showRedDot = false,
    bool isFullWidth = false,
    VoidCallback? onTap,
  }) {
    final cardContent = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.ambientShadow,
        border: Border.all(color: AppTheme.outlineVariantColor.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              if (showRedDot)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: GoogleFonts.hankenGrotesk(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.onSurfaceColor,
                  ),
                ),
                if (suffix != null)
                  TextSpan(
                    text: suffix,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );

    return onTap != null
        ? GestureDetector(
            onTap: onTap,
            child: cardContent,
          )
        : cardContent;
  }

  void _showMockDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: const Text("This is a mock screen replication flow for demonstration."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
