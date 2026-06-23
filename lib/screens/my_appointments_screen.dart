import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';
import '../state/app_state.dart';
import 'visitor_access/appointment_overview_screen.dart';
import 'booking_flow/booking_wizard_screen.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  String _filter = "Upcoming"; // "Upcoming", "Past"

  final List<Map<String, dynamic>> _organizations = [
    {
      "name": "Vantage Medical Group",
      "category": "Healthcare",
      "specialty": "General Health",
      "distance": "1.2 miles away",
      "rating": "4.9",
      "imageUrl": "https://images.unsplash.com/photo-1629909613654-28e377c37b09?auto=format&fit=crop&q=80&w=240",
      "tags": ["Family Med", "Telehealth"],
      "services": [
        {"name": "General Consultation", "price": 120.0, "duration": "30 min"},
        {"name": "Diagnostic Lab Check", "price": 85.0, "duration": "45 min"},
        {"name": "Specialist Referral Review", "price": 200.0, "duration": "60 min"}
      ],
      "professionals": [
        {"name": "Dr. Aris Thorne", "role": "Senior Cardiologist", "rating": "4.9"},
        {"name": "Dr. Clara Oswald", "role": "Pediatrician", "rating": "4.8"},
      ]
    },
    {
      "name": "Sterling & Associates",
      "category": "Legal",
      "specialty": "Legal Services",
      "distance": "0.8 miles away",
      "rating": "4.8",
      "imageUrl": "https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&q=80&w=240",
      "tags": ["Corporate", "Estate"],
      "services": [
        {"name": "Business Legal Advice", "price": 250.0, "duration": "60 min"},
        {"name": "Estate Planning Review", "price": 180.0, "duration": "45 min"}
      ],
      "professionals": [
        {"name": "Marcus Sterling", "role": "Managing Partner", "rating": "4.9"},
        {"name": "Sarah Jenkins", "role": "Corporate Counsel", "rating": "4.7"}
      ]
    },
    {
      "name": "The Aesthetic Loft",
      "category": "Beauty",
      "specialty": "Skincare & Laser",
      "distance": "2.5 miles away",
      "rating": "5.0",
      "imageUrl": "https://images.unsplash.com/photo-1560066984-138dadb4c035?auto=format&fit=crop&q=80&w=240",
      "tags": ["Facials", "Laser"],
      "services": [
        {"name": "HydraFacial Deluxe", "price": 150.0, "duration": "60 min"},
        {"name": "Full Laser Session", "price": 320.0, "duration": "90 min"}
      ],
      "professionals": [
        {"name": "Elena Rostova", "role": "Senior Esthetician", "rating": "5.0"}
      ]
    },
    {
      "name": "Nexus Strategy Group",
      "category": "Consulting",
      "specialty": "Financial Consulting",
      "distance": "3.1 miles away",
      "rating": "4.7",
      "imageUrl": "https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?auto=format&fit=crop&q=80&w=240",
      "tags": ["Tax Advice", "Wealth"],
      "services": [
        {"name": "Corporate Tax Strategy", "price": 400.0, "duration": "120 min"},
        {"name": "Wealth Management Audit", "price": 300.0, "duration": "90 min"}
      ],
      "professionals": [
        {"name": "David Vance", "role": "Chief Strategist", "rating": "4.8"}
      ]
    },
    {
      "name": "Ascent Legal Partners",
      "category": "Legal",
      "specialty": "Litigation & IP",
      "distance": "1.4 miles away",
      "rating": "4.6",
      "imageUrl": "https://images.unsplash.com/photo-1450133064473-71024230f91b?auto=format&fit=crop&q=80&w=240",
      "tags": ["Patent", "Court"],
      "services": [
        {"name": "IP Search & Advisory", "price": 200.0, "duration": "60 min"}
      ],
      "professionals": [
        {"name": "Harvey Specter", "role": "Partner", "rating": "4.9"}
      ]
    },
    {
      "name": "Lumina Dental Center",
      "category": "Healthcare",
      "specialty": "Orthodontics",
      "distance": "1.7 miles away",
      "rating": "4.9",
      "imageUrl": "https://images.unsplash.com/photo-1588776814546-1ffcf47267a5?auto=format&fit=crop&q=80&w=240",
      "tags": ["Dental", "Braces"],
      "services": [
        {"name": "Teeth Cleaning & Whitening", "price": 95.0, "duration": "30 min"},
        {"name": "Root Canal Treatment", "price": 450.0, "duration": "90 min"}
      ],
      "professionals": [
        {"name": "Dr. Sarah Paulson", "role": "Orthodontist", "rating": "4.9"}
      ]
    }
  ];

  void _handleRebook(BuildContext context, AppState appState, Appointment appointment) {
    Map<String, dynamic>? matchedOrg;
    for (final org in _organizations) {
      if (org["name"] == appointment.organizationName) {
        matchedOrg = org;
        break;
      }
    }
    matchedOrg ??= _organizations.first;

    final services = matchedOrg["services"] as List;
    Map<String, dynamic>? matchedService;
    for (final service in services) {
      if (service is Map<String, dynamic> && service["name"] == appointment.serviceName) {
        matchedService = service;
        break;
      }
    }
    matchedService ??= services.first as Map<String, dynamic>;

    appState.clearBookingWizard();
    appState.selectedOrg = matchedOrg;
    appState.selectedCategory = matchedOrg["category"];
    appState.selectedService = appointment.serviceName;
    appState.selectedServicePrice = (matchedService["price"] as num).toDouble();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingWizardScreen(
          initialStep: 1,
          preselectedProfessionalName: appointment.professionalName,
        ),
      ),
    );
  }

  void _handleReschedule(BuildContext context, AppState appState, Appointment appointment) {
    Map<String, dynamic>? matchedOrg;
    for (final org in _organizations) {
      if (org["name"] == appointment.organizationName) {
        matchedOrg = org;
        break;
      }
    }
    matchedOrg ??= _organizations.first;

    final services = matchedOrg["services"] as List;
    Map<String, dynamic>? matchedService;
    for (final service in services) {
      if (service is Map<String, dynamic> && service["name"] == appointment.serviceName) {
        matchedService = service;
        break;
      }
    }
    matchedService ??= services.first as Map<String, dynamic>;

    appState.clearBookingWizard();
    appState.selectedOrg = matchedOrg;
    appState.selectedCategory = matchedOrg["category"];
    appState.selectedService = appointment.serviceName;
    appState.selectedServicePrice = (matchedService["price"] as num).toDouble();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingWizardScreen(
          initialStep: 1,
          preselectedProfessionalName: appointment.professionalName,
          reschedulingAppointmentId: appointment.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);

    // Filter appointments
    final list = _filter == "Upcoming" ? appState.appointments : appState.cancelledAppointments;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title & Subtitle Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "My Appointments",
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurfaceColor,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Manage your scheduled professional services",
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        // Tab Selector Row
        _buildTabBar(context),
        const SizedBox(height: 16),

        // Appointments List
        Expanded(
          child: list.isEmpty
              ? _buildEmptyState(theme)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  physics: const BouncingScrollPhysics(),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final appointment = list[index];
                    final isVerified = appointment.status == "Verified";
                    final isPending = appointment.status == "Pending";
                    final isCancelled = appointment.status == "Cancelled";

                    return GestureDetector(
                      onTap: () {
                        if (!isCancelled) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AppointmentOverviewScreen(appointment: appointment),
                            ),
                          );
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 20.0),
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFF1EBF1)),
                          boxShadow: AppTheme.ambientShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Left: Category icon box
                                _buildCategoryIcon(appointment.category, appointment.organizationName),
                                const SizedBox(width: 16),
                                
                                // Middle: Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        appointment.organizationName,
                                        style: GoogleFonts.hankenGrotesk(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.onSurfaceColor,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "${appointment.category} • ${appointment.professionalName}",
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: AppTheme.onSurfaceVariant.withOpacity(0.8),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      
                                      // Row with status badge and meeting type
                                      Row(
                                        children: [
                                          // Status badge pill
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFAF5FF), // light purple
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: const Color(0xFFF3E8FF)),
                                            ),
                                            child: Text(
                                              isVerified ? "CONFIRMED" : (isPending ? "PENDING" : "CANCELLED"),
                                              style: const TextStyle(
                                                color: Color(0xFF6B21A8), // dark purple
                                                fontWeight: FontWeight.bold,
                                                fontSize: 9,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          
                                          // Meeting type (Telehealth / In-person)
                                          _buildMeetingTypeRow(appointment.category),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            
                            // Date row
                            Row(
                              children: [
                                const Icon(Icons.calendar_today_outlined, size: 16, color: AppTheme.outlineColor),
                                const SizedBox(width: 8),
                                Text(
                                  AppTheme.formatDate(appointment.date),
                                  style: const TextStyle(
                                    fontSize: 14, 
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.onSurfaceColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            
                            // Time duration row
                            Row(
                              children: [
                                const Icon(Icons.watch_later_outlined, size: 16, color: AppTheme.outlineColor),
                                const SizedBox(width: 8),
                                Text(
                                  "${appointment.timeSlot} - ${_getEndTimeSlot(appointment.timeSlot)}",
                                  style: const TextStyle(
                                    fontSize: 14, 
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.onSurfaceColor,
                                  ),
                                ),
                              ],
                            ),
                            if (appointment.tokenNumber != null) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.confirmation_num_outlined, size: 16, color: AppTheme.primaryColor),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Token Number: ${appointment.tokenNumber}",
                                    style: const TextStyle(
                                      fontSize: 14, 
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            
                            // Divider & Action buttons (only for upcoming/active appointments)
                            if (!isCancelled) ...[
                              const Divider(color: Color(0xFFF1EBF1), height: 32),
                              Row(
                                children: [
                                  // Reschedule Button
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => _handleReschedule(context, appState, appointment),
                                      style: ElevatedButton.styleFrom(
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        backgroundColor: AppTheme.primaryColor,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text("Reschedule", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  
                                  // Cancel Button
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => _showCancelBottomSheet(context, appState, appointment.id),
                                      style: OutlinedButton.styleFrom(
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        foregroundColor: AppTheme.primaryColor,
                                        side: BorderSide(color: AppTheme.primaryColor.withOpacity(0.1)),
                                        backgroundColor: const Color(0xFFFFF7FE),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text("Cancel", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    ),
                                  ),
                                ],
                              ),
                            ] else ...[
                              const Divider(color: Color(0xFFF1EBF1), height: 32),
                              Row(
                                children: [
                                  // Rebook Button
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => _handleRebook(context, appState, appointment),
                                      style: ElevatedButton.styleFrom(
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        backgroundColor: AppTheme.primaryColor,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text("Rebook", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    ),
                                  ),
                                ],
                              ),
                            ]
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFF1EBF1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _filter = "Upcoming";
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: _filter == "Upcoming" ? AppTheme.primaryColor : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                ),
                child: Text(
                  "Upcoming",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: _filter == "Upcoming" ? AppTheme.primaryColor : AppTheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _filter = "Past";
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: _filter == "Past" ? AppTheme.primaryColor : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                ),
                child: Text(
                  "Past",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: _filter == "Past" ? AppTheme.primaryColor : AppTheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryIcon(String category, String orgName) {
    IconData iconData;
    Color bgColor;
    Color iconColor;

    if (category.toLowerCase().contains("health") || orgName.toLowerCase().contains("health")) {
      iconData = Icons.add;
      bgColor = const Color(0xFFF0FDF4); // light green
      iconColor = const Color(0xFF15803D);
    } else if (category.toLowerCase().contains("legal") || orgName.toLowerCase().contains("legal")) {
      iconData = Icons.gavel_outlined;
      bgColor = const Color(0xFFF8FAFC); // light grey
      iconColor = const Color(0xFF475569);
    } else if (category.toLowerCase().contains("beauty") || category.toLowerCase().contains("spa")) {
      iconData = Icons.spa_outlined;
      bgColor = const Color(0xFFFDF2F8); // light pink
      iconColor = const Color(0xFFDB2777);
    } else {
      iconData = Icons.business_center_outlined;
      bgColor = const Color(0xFFF3E8FF); // light purple
      iconColor = const Color(0xFF7C3AED);
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: iconColor.withOpacity(0.1)),
      ),
      child: Icon(iconData, color: iconColor, size: 20),
    );
  }

  Widget _buildMeetingTypeRow(String category) {
    final isTelehealth = category.toLowerCase().contains("health") || category.toLowerCase().contains("beauty");
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isTelehealth ? Icons.videocam_outlined : Icons.location_on_outlined,
          size: 14,
          color: AppTheme.onSurfaceVariant.withOpacity(0.7),
        ),
        const SizedBox(width: 4),
        Text(
          isTelehealth ? "Telehealth" : "In-person",
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.onSurfaceVariant.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _getEndTimeSlot(String start) {
    try {
      final parts = start.split(" ");
      final timeParts = parts[0].split(":");
      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);
      
      // Assume a 30 minutes duration for appointments
      minute += 30;
      if (minute >= 60) {
        minute -= 60;
        hour += 1;
      }
      
      String period = parts[1];
      if (hour >= 12) {
        if (hour > 12) {
          hour -= 12;
        }
        // toggle period if we transition from AM/PM or hour was exactly 12
        if (timeParts[0] != "12") {
          period = period == "AM" ? "PM" : "AM";
        }
      }
      
      final paddedHour = hour.toString();
      final paddedMinute = minute.toString().padLeft(2, '0');
      return "$paddedHour:$paddedMinute $period";
    } catch (_) {
      return "10:00 AM";
    }
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppTheme.surfaceContainerColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calendar_today_outlined,
                size: 64,
                color: AppTheme.outlineColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "No Appointments Found",
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              "You don't have any bookings matching this filter. Schedule visits via the Explore tab.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.onSurfaceVariant,
                fontSize: 14,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelBottomSheet(BuildContext context, AppState appState, String id) {
    String? selectedReason;
    final List<String> reasons = [
      "Schedule Conflict",
      "No Longer Needed",
      "Rescheduling",
      "Other",
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radius2Xl)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Cancel Appointment",
                      style: GoogleFonts.hankenGrotesk(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Are you sure you want to cancel this appointment? This action will void your facility gate pass.",
                      style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    
                    // Reasons Dropdown
                    Text(
                      "Reason for Cancellation",
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      hint: const Text("Select a reason"),
                      value: selectedReason,
                      items: reasons.map((r) {
                        return DropdownMenuItem(value: r, child: Text(r));
                      }).toList(),
                      onChanged: (val) {
                        setModalState(() {
                          selectedReason = val;
                        });
                      },
                      decoration: const InputDecoration(
                        fillColor: AppTheme.surfaceColor,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusXl)),
                              side: const BorderSide(color: AppTheme.outlineColor),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text("KEEP BOOKING", style: TextStyle(color: AppTheme.onSurfaceColor)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.errorColor,
                            ),
                            onPressed: selectedReason == null
                                ? null
                                : () {
                                    appState.cancelAppointment(id);
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Booking cancelled successfully"),
                                        backgroundColor: AppTheme.errorColor,
                                      ),
                                    );
                                  },
                            child: const Text("CANCEL NOW"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
