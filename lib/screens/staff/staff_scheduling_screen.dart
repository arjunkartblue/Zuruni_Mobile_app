import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/theme.dart';
import '../../state/app_state.dart';
import 'new_meeting_screen.dart';
import 'scheduled_meeting_details_screen.dart';

class StaffSchedulingScreen extends StatefulWidget {
  const StaffSchedulingScreen({Key? key}) : super(key: key);

  @override
  State<StaffSchedulingScreen> createState() => _StaffSchedulingScreenState();
}

class _StaffSchedulingScreenState extends State<StaffSchedulingScreen> {
  String _selectedFilter = "All";

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final rawMeetings = appState.scheduledMeetings;

        // Filter logic
        final filtered = rawMeetings.where((meeting) {
          final type = meeting["type"] ?? "Internal";
          if (_selectedFilter == "Internal") return type == "Internal";
          if (_selectedFilter == "Public") return type == "Public";
          return true;
        }).toList();

        // Grouping by date
        final todayMeetings = filtered.where((m) => m["dateGroup"] == "Today").toList();
        final tomorrowMeetings = filtered.where((m) => m["dateGroup"] == "Tomorrow").toList();
        final upcomingMeetings = filtered.where((m) => m["dateGroup"] == "Upcoming").toList();

        return Scaffold(
          backgroundColor: AppTheme.surfaceColor,
          body: SafeArea(
            child: Column(
              children: [
                // Top Header Row with "+ New Meeting"
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 16.0, bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Scheduling",
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.onSurfaceColor,
                          letterSpacing: -0.5,
                        ),
                      ),
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
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.add, size: 14),
                        label: const Text(
                          "New Meeting",
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),

                // Filter Chips Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                  child: Row(
                    children: [
                      _buildFilterChip("All"),
                      const SizedBox(width: 8),
                      _buildFilterChip("Internal"),
                      const SizedBox(width: 8),
                      _buildFilterChip("Public"),
                    ],
                  ),
                ),

                // Scrollable meetings list
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (todayMeetings.isNotEmpty) ...[
                          _buildSectionHeader("TODAY"),
                          ...todayMeetings.map((m) => _buildMeetingCard(m)),
                          const SizedBox(height: 20),
                        ],
                        if (tomorrowMeetings.isNotEmpty) ...[
                          _buildSectionHeader("TOMORROW"),
                          ...tomorrowMeetings.map((m) => _buildMeetingCard(m)),
                          const SizedBox(height: 20),
                        ],
                        if (upcomingMeetings.isNotEmpty) ...[
                          _buildSectionHeader("UPCOMING"),
                          ...upcomingMeetings.map((m) => _buildMeetingCard(m)),
                          const SizedBox(height: 20),
                        ],
                        if (filtered.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 80.0),
                              child: Text(
                                "No scheduled meetings found.",
                                style: GoogleFonts.inter(color: AppTheme.onSurfaceVariant),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    final activeBg = const Color(0xFF290A45); // Dark Amethyst
    final inactiveBg = const Color(0xFFFAF1F9); // Light lavender/pinkish

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeBg : inactiveBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.white : AppTheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 4.0),
      child: Text(
        title,
        style: GoogleFonts.jetBrainsMono(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppTheme.onSurfaceVariant.withOpacity(0.6),
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildMeetingCard(Map<String, dynamic> meeting) {
    final title = meeting["title"] ?? "Untitled Meeting";
    final timeStr = meeting["time"] ?? "10:00 AM";
    final location = meeting["location"] ?? "Meeting Room";
    final type = meeting["type"] ?? "Internal";
    final host = meeting["host"] ?? "Staff Host";
    final attendeeInitials = List<String>.from(meeting["attendeeInitials"] ?? []);

    final isInternal = type == "Internal";
    final typeColor = isInternal ? AppTheme.primaryColor : const Color(0xFF0D9488);
    final typeBg = isInternal ? AppTheme.primaryColor.withOpacity(0.08) : const Color(0xFFCCFBF1);

    return Container(
      margin: const EdgeInsets.only(bottom: 14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radius2Xl), // Staff Style ~24px
        boxShadow: AppTheme.ambientShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ScheduledMeetingDetailsScreen(meeting: meeting),
              ),
            );
          },
          borderRadius: BorderRadius.circular(AppTheme.radius2Xl),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time & Type pill row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 14, color: AppTheme.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Text(
                          timeStr,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: typeBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        type.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: typeColor,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Meeting Title
                Text(
                  title,
                  style: GoogleFonts.hankenGrotesk(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.onSurfaceColor,
                  ),
                ),
                const SizedBox(height: 6),

                // Location
                Row(
                  children: [
                    const Icon(Icons.place_outlined, size: 14, color: AppTheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Attendees list row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Host: $host",
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.onSurfaceVariant.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        // Overlapping avatars
                        SizedBox(
                          height: 28,
                          width: 70,
                          child: Stack(
                            children: List.generate(
                              attendeeInitials.length > 3 ? 3 : attendeeInitials.length,
                              (index) {
                                return Positioned(
                                  left: index * 16.0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                    child: CircleAvatar(
                                      radius: 12,
                                      backgroundColor: const Color(0xFFF1EBF1),
                                      child: Text(
                                        attendeeInitials[index],
                                        style: const TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        if (attendeeInitials.length > 3)
                          Text(
                            "+${attendeeInitials.length - 3}",
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
