import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/theme.dart';

class ScheduledMeetingDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> meeting;

  const ScheduledMeetingDetailsScreen({Key? key, required this.meeting}) : super(key: key);

  // Helper helper to expand initials to realistic attendee data
  List<Map<String, String>> _getAttendeesList(List<String> initials, String hostName) {
    final Map<String, Map<String, String>> mockPeople = {
      "AR": {"name": "Alex Rivers", "role": "Senior Manager, HR", "status": "Host"},
      "MW": {"name": "Mark Wilson", "role": "Operations Director", "status": "Confirmed"},
      "SJ": {"name": "Sarah Jenkins", "role": "IT Analyst", "status": "Confirmed"},
      "RC": {"name": "Ravi Chen", "role": "Logistics Lead", "status": "Pending"},
      "AT": {"name": "Dr. Aris Thorne", "role": "Attending Physician", "status": "Host"},
      "AJ": {"name": "Alex Johnson", "role": "Patient / Visitor", "status": "Arrived"},
      "SC": {"name": "Sarah Chen", "role": "UX Lead", "status": "Host"},
      "DK": {"name": "David Kim", "role": "Software Architect", "status": "Confirmed"},
      "MC": {"name": "Michael Chen", "role": "Developer", "status": "Confirmed"},
      "AP": {"name": "Aisha Patel", "role": "Product Owner", "status": "Confirmed"},
      "SA": {"name": "Dr. Sarah Amethyst", "role": "Chief Medical Officer", "status": "Host"},
      "EL": {"name": "Elena Rostova", "role": "Clinic Supervisor", "status": "Confirmed"},
      "MM": {"name": "Mark Miller", "role": "Hardware Engineer", "status": "Host"},
    };

    final List<Map<String, String>> list = [];
    
    // Ensure host is included and marked as host
    bool hostAdded = false;
    for (final initial in initials) {
      if (mockPeople.containsKey(initial)) {
        final person = mockPeople[initial]!;
        if (person["name"] == hostName) {
          list.add({
            "initials": initial,
            "name": person["name"]!,
            "role": person["role"]!,
            "status": "Host",
          });
          hostAdded = true;
        } else {
          list.add({
            "initials": initial,
            "name": person["name"]!,
            "role": person["role"]!,
            "status": person["status"]!,
          });
        }
      } else {
        // Fallback for unknown initials
        list.add({
          "initials": initial,
          "name": initial == "AR" ? "Alex Rivers" : "Staff Attendee",
          "role": "Team Member",
          "status": "Confirmed",
        });
      }
    }

    if (!hostAdded && hostName.isNotEmpty) {
      final hostInitials = hostName.split(" ").map((s) => s[0]).join().toUpperCase();
      list.insert(0, {
        "initials": hostInitials,
        "name": hostName,
        "role": hostName.contains("Dr.") ? "Attending Physician" : "Coordinator",
        "status": "Host",
      });
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final title = meeting["title"] ?? "Untitled Meeting";
    final timeStr = meeting["time"] ?? "10:00 AM";
    final location = meeting["location"] ?? "Meeting Room";
    final type = meeting["type"] ?? "Internal";
    final host = meeting["host"] ?? "Staff Host";
    final initials = List<String>.from(meeting["attendeeInitials"] ?? []);
    final dateGroup = meeting["dateGroup"] ?? "Today";

    final attendees = _getAttendeesList(initials, host);
    final isInternal = type == "Internal";
    final typeColor = isInternal ? AppTheme.primaryColor : const Color(0xFF0D9488);
    final typeBg = isInternal ? AppTheme.primaryColor.withOpacity(0.08) : const Color(0xFFCCFBF1);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7FC), // Soft pinkish white background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.onSurfaceColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Meeting Details",
          style: GoogleFonts.hankenGrotesk(
            fontWeight: FontWeight.bold,
            color: AppTheme.onSurfaceColor,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Meeting Title & Metadata Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radius2Xl), // Staff Style ~24px
                  boxShadow: AppTheme.ambientShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Time and Type Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAF1F9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.primaryColor.withOpacity(0.1)),
                          ),
                          child: Text(
                            "${dateGroup.toUpperCase()} • $timeStr",
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryColor,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: typeBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            type.toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: typeColor,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Meeting Title
                    Text(
                      title,
                      style: GoogleFonts.hankenGrotesk(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.onSurfaceColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFFF5EEF5), height: 1),
                    const SizedBox(height: 16),

                    // Location / Room Details
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.06),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.place_outlined, color: AppTheme.primaryColor, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "LOCATION",
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.onSurfaceVariant.withOpacity(0.6),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              location,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
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
              const SizedBox(height: 24),

              // 2. Attendees Section Header
              Text(
                "ATTENDEES (${attendees.length})",
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurfaceVariant.withOpacity(0.6),
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 12),

              // 3. Attendees List Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radius2Xl),
                  boxShadow: AppTheme.ambientShadow,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: attendees.length,
                  separatorBuilder: (_, __) => const Divider(color: Color(0xFFFAF5FF), height: 1),
                  itemBuilder: (context, index) {
                    final attendee = attendees[index];
                    final isHost = attendee["status"] == "Host";
                    final isArrived = attendee["status"] == "Arrived";
                    final isConfirmed = attendee["status"] == "Confirmed";

                    Color statusBg = const Color(0xFFF1F5F9);
                    Color statusTextColor = const Color(0xFF64748B);
                    if (isHost) {
                      statusBg = AppTheme.primaryColor.withOpacity(0.1);
                      statusTextColor = AppTheme.primaryColor;
                    } else if (isArrived) {
                      statusBg = const Color(0xFFD1FAE5);
                      statusTextColor = const Color(0xFF065F46);
                    } else if (isConfirmed) {
                      statusBg = const Color(0xFFEFF6FF);
                      statusTextColor = const Color(0xFF1D4ED8);
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
                      child: Row(
                        children: [
                          // Initials Avatar
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: isHost ? AppTheme.primaryColor.withOpacity(0.12) : const Color(0xFFFAF1F9),
                            child: Text(
                              attendee["initials"] ?? "ST",
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Name and Role
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  attendee["name"] ?? "Attendee Name",
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.onSurfaceColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  attendee["role"] ?? "Attendee Role",
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppTheme.onSurfaceVariant.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              (attendee["status"] ?? "CONFIRMED").toUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: statusTextColor,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),

              // 4. Action Buttons Bar
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Starting meeting: '$title'..."),
                              backgroundColor: AppTheme.primaryColor,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.play_arrow, size: 20),
                        label: Text(
                          "Start Meeting",
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Delete/Cancel function simulation")),
                          );
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.errorColor,
                          side: const BorderSide(color: AppTheme.errorColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.cancel_outlined, size: 18),
                        label: const Text(
                          "Cancel Meeting",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
