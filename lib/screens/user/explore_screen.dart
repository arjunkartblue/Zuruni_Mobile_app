import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/theme.dart';
import '../../state/app_state.dart';
import 'explore/org_profile_screen.dart';
import 'visitor_access/appointment_overview_screen.dart';
import '../auth/login_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String _selectedCategory = "All";
  String? _selectedCountry = "All";
  String? _selectedState = "All";
  String? _selectedDistrict = "All";
  final TextEditingController _searchController = TextEditingController();

  // Chatbot State
  bool _isChatOpen = false;
  bool _isTyping = false;
  final List<Map<String, dynamic>> _chatMessages = [];
  final TextEditingController _chatInputController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSendChatMessage() {
    final text = _chatInputController.text.trim();
    if (text.isEmpty) return;

    _chatInputController.clear();
    setState(() {
      _chatMessages.add({
        "text": text,
        "isMe": true,
        "time": TimeOfDay.now().format(context),
      });
      _isTyping = true;
    });
    _scrollToBottom();

    // Contextual bot reply simulation
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      
      String reply = "";
      final query = text.toLowerCase();
      
      if (query.contains("book") || query.contains("appointment") || query.contains("schedule")) {
        reply = "To book a visit, tap on a category tab (e.g. Healthcare, Legal) on this screen, select an organization, choose your service and doctor, and complete the Booking Wizard! Your token will activate automatically.";
      } else if (query.contains("cancel")) {
        reply = "You can cancel any upcoming appointment by heading to the 'Bookings' tab, opening the active booking details card, and selecting 'Cancel Visit'. Note: Checked-in or past visits cannot be cancelled.";
      } else if (query.contains("reschedule")) {
        reply = "To reschedule, open your appointment details inside the 'Bookings' tab and tap 'Reschedule'. You'll be prompted to select a new date and time slot.";
      } else if (query.contains("prescription") || query.contains("pdf") || query.contains("rx")) {
        reply = "Once your session is completed, your professional will upload the prescription. You can view or download it by going to 'My Prescriptions' in the drawer menu, or under your completed visit's summary card.";
      } else if (query.contains("hi") || query.contains("hello") || query.contains("hey")) {
        reply = "Hello! I am your Zuruni Assistant. How can I help you find services, manage bookings, or access your entry passes today?";
      } else if (query.contains("help") || query.contains("how to")) {
        reply = "I can guide you on: \n• How to book an appointment\n• Rescheduling or cancelling visits\n• Finding clinical prescriptions\n• Accessing your digital QR passes\nWhat would you like assistance with?";
      } else {
        reply = "Thank you for asking! I can help you with scheduling, gates passes, and prescription summaries. Try asking: 'How do I book?' or 'How can I view prescriptions?'";
      }

      setState(() {
        _isTyping = false;
        _chatMessages.add({
          "text": reply,
          "isMe": false,
          "time": TimeOfDay.now().format(context),
        });
      });
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _chatInputController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  final List<String> _categories = [
    "All",
    "Healthcare",
    "Legal",
    "Consulting",
    "Beauty",
    "Fitness",
    "Education",
  ];

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  String _getCurrentActiveToken(String tokenStr) {
    final digits = RegExp(r'\d+').stringMatch(tokenStr);
    if (digits != null) {
      final numVal = int.tryParse(digits);
      if (numVal != null) {
        final activeVal = numVal - 4;
        final safeActiveVal = activeVal < 1 ? 1 : activeVal;
        final prefix = tokenStr.split(digits)[0];
        return "$prefix$safeActiveVal";
      }
    }
    return "T-1";
  }

  final List<Map<String, dynamic>> _organizations = [
    {
      "name": "Vantage Medical Group",
      "category": "Healthcare",
      "specialty": "General Health",
      "distance": "1.2 miles away",
      "rating": "4.9",
      "imageUrl": "https://images.unsplash.com/photo-1629909613654-28e377c37b09?auto=format&fit=crop&q=80&w=240",
      "tags": ["Family Med", "Telehealth"],
      "country": "India",
      "state": "Maharashtra",
      "district": "Mumbai",
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
      "country": "India",
      "state": "Maharashtra",
      "district": "Pune",
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
      "country": "India",
      "state": "Delhi",
      "district": "New Delhi",
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
      "country": "United States",
      "state": "New York",
      "district": "New York City",
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
      "country": "United States",
      "state": "California",
      "district": "Los Angeles",
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
      "country": "India",
      "state": "Karnataka",
      "district": "Bengaluru",
      "services": [
        {"name": "Teeth Cleaning & Whitening", "price": 95.0, "duration": "30 min"},
        {"name": "Root Canal Treatment", "price": 450.0, "duration": "90 min"}
      ],
      "professionals": [
        {"name": "Dr. Sarah Paulson", "role": "Orthodontist", "rating": "4.9"}
      ]
    }
  ];

  void _showLocationFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppTheme.radius2Xl),
          topRight: Radius.circular(AppTheme.radius2Xl),
        ),
      ),
      isScrollControlled: true,
      builder: (context) {
        String tempCountry = _selectedCountry ?? "All";
        String tempState = _selectedState ?? "All";
        String tempDistrict = _selectedDistrict ?? "All";

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            List<String> getCountries() {
              final list = _organizations
                  .map((org) => org["country"] as String?)
                  .where((c) => c != null)
                  .map((c) => c!)
                  .toSet()
                  .toList();
              return ["All", ...list];
            }

            List<String> getStates() {
              final list = _organizations
                  .where((org) => tempCountry == "All" || org["country"] == tempCountry)
                  .map((org) => org["state"] as String?)
                  .where((s) => s != null)
                  .map((s) => s!)
                  .toSet()
                  .toList();
              return ["All", ...list];
            }

            List<String> getDistricts() {
              final list = _organizations
                  .where((org) => tempCountry == "All" || org["country"] == tempCountry)
                  .where((org) => tempState == "All" || org["state"] == tempState)
                  .map((org) => org["district"] as String?)
                  .where((d) => d != null)
                  .map((d) => d!)
                  .toSet()
                  .toList();
              return ["All", ...list];
            }

            final countries = getCountries();
            final states = getStates();
            final districts = getDistricts();

            if (!countries.contains(tempCountry)) tempCountry = "All";
            if (!states.contains(tempState)) tempState = "All";
            if (!districts.contains(tempDistrict)) tempDistrict = "All";

            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Location Filter",
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.onSurfaceColor,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            tempCountry = "All";
                            tempState = "All";
                            tempDistrict = "All";
                          });
                        },
                        child: Text(
                          "Reset All",
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.errorColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Filter organizations by location when location services are disabled.",
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Country Dropdown
                  Text(
                    "COUNTRY",
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurfaceVariant.withOpacity(0.6),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: tempCountry,
                    items: countries.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() {
                          tempCountry = val;
                          tempState = "All";
                          tempDistrict = "All";
                        });
                      }
                    },
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // State Dropdown
                  Text(
                    "STATE",
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurfaceVariant.withOpacity(0.6),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: tempState,
                    items: states.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() {
                          tempState = val;
                          tempDistrict = "All";
                        });
                      }
                    },
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // District Dropdown
                  Text(
                    "DISTRICT",
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurfaceVariant.withOpacity(0.6),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: tempDistrict,
                    items: districts.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() {
                          tempDistrict = val;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedCountry = tempCountry;
                          _selectedState = tempState;
                          _selectedDistrict = tempDistrict;
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Apply Location Filter",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);

    final searchQuery = _searchController.text.toLowerCase().trim();
    final filteredOrgs = _organizations.where((org) {
      final matchCategory = _selectedCategory == "All" || org["category"] == _selectedCategory;
      if (!matchCategory) return false;

      final matchCountry = _selectedCountry == null || _selectedCountry == "All" || org["country"] == _selectedCountry;
      if (!matchCountry) return false;

      final matchState = _selectedState == null || _selectedState == "All" || org["state"] == _selectedState;
      if (!matchState) return false;

      final matchDistrict = _selectedDistrict == null || _selectedDistrict == "All" || org["district"] == _selectedDistrict;
      if (!matchDistrict) return false;

      if (searchQuery.isNotEmpty) {
        final name = (org["name"] as String? ?? "").toLowerCase();
        final specialty = (org["specialty"] as String? ?? "").toLowerCase();
        final tags = (org["tags"] as List<dynamic>?)?.map((t) => t.toString().toLowerCase()).toList() ?? [];
        
        final matchesName = name.contains(searchQuery);
        final matchesSpecialty = specialty.contains(searchQuery);
        final matchesTags = tags.any((tag) => tag.contains(searchQuery));
        
        return matchesName || matchesSpecialty || matchesTags;
      }
      
      return true;
    }).toList();

    // Check if any upcoming appointment is today and has a token number
    final hasTodayToken = appState.appointments.any((apt) =>
        apt.tokenNumber != null && _isToday(apt.date)
    );

    return Stack(
      children: [
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Upcoming Appointments (If logged in) - now at the top
          if (appState.isLoggedIn && appState.appointments.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "Upcoming Appointments",
                      style: theme.textTheme.headlineSmall,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to Bookings Tab in Navigation Shell
                      // By notifying main shell, but here we can just show a SnackBar or navigate
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Upcoming Appointments list is shown in Bookings tab")),
                      );
                    },
                    child: const Text(
                      "View All",
                      style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: hasTodayToken ? 165 : 140,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: appState.appointments.length,
                itemBuilder: (context, index) {
                  final appointment = appState.appointments[index];
                  final isVerified = appointment.status == "Verified";
                  
                  return Container(
                    width: 280,
                    margin: const EdgeInsets.only(right: 16.0, bottom: 8),
                    decoration: BoxDecoration(
                      color: isVerified ? AppTheme.primaryColor : Colors.white,
                      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                      border: isVerified ? null : Border.all(color: AppTheme.outlineVariantColor),
                      boxShadow: AppTheme.ambientShadow,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                        onTap: () {
                          // Tap opens the dashboard for verified appointment
                          if (isVerified) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AppointmentOverviewScreen(appointment: appointment),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Clearance Pending. Pass will activate once verified.")),
                            );
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          appointment.category.toUpperCase(),
                                          style: GoogleFonts.jetBrainsMono(
                                            color: isVerified ? Colors.white.withOpacity(0.8) : AppTheme.onSurfaceVariant,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.0,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          appointment.professionalName,
                                          style: GoogleFonts.hankenGrotesk(
                                            color: isVerified ? Colors.white : AppTheme.onSurfaceColor,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      color: isVerified ? Colors.white.withOpacity(0.2) : AppTheme.surfaceContainerColor,
                                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                                    ),
                                    child: Icon(
                                      appointment.category == "Healthcare" ? Icons.medical_services_outlined : Icons.face_outlined,
                                      color: isVerified ? Colors.white : AppTheme.primaryColor,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Wrap(
                                spacing: 12.0,
                                runSpacing: 4.0,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.calendar_today_outlined,
                                        size: 14,
                                        color: isVerified ? Colors.white70 : AppTheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        AppTheme.formatDate(appointment.date),
                                        style: TextStyle(
                                          color: isVerified ? Colors.white70 : AppTheme.onSurfaceVariant,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        size: 14,
                                        color: isVerified ? Colors.white70 : AppTheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        appointment.timeSlot,
                                        style: TextStyle(
                                          color: isVerified ? Colors.white70 : AppTheme.onSurfaceVariant,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (appointment.tokenNumber != null && _isToday(appointment.date)) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isVerified ? Colors.white.withOpacity(0.15) : AppTheme.primaryColor.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                                    border: Border.all(
                                      color: isVerified ? Colors.white.withOpacity(0.25) : AppTheme.primaryColor.withOpacity(0.15)
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.confirmation_num_outlined,
                                            size: 12,
                                            color: isVerified ? Colors.white : AppTheme.primaryColor,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            "Token: ",
                                            style: TextStyle(
                                              color: isVerified ? Colors.white70 : AppTheme.onSurfaceVariant,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            appointment.tokenNumber!,
                                            style: TextStyle(
                                              color: isVerified ? Colors.white : AppTheme.primaryColor,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            "Active: ",
                                            style: TextStyle(
                                              color: isVerified ? Colors.white70 : AppTheme.onSurfaceVariant,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            _getCurrentActiveToken(appointment.tokenNumber!),
                                            style: TextStyle(
                                              color: isVerified ? Colors.white : AppTheme.primaryColor,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Guest Sign In Prompt Card (If not logged in) - now at the top
          if (!appState.isLoggedIn)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                  boxShadow: AppTheme.ambientShadow,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Friction-less Access Control",
                            style: GoogleFonts.hankenGrotesk(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Log in to verify your identity, get digital passes, and bypass reception wait lines.",
                            style: GoogleFonts.inter(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 13,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      child: const Text("LOGIN"),
                    ),
                  ],
                ),
              ),
            ),

          // Search Bar - shifted down
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                boxShadow: AppTheme.ambientShadow,
              ),
              child: TextFormField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {});
                },
                decoration: InputDecoration(
                  hintText: "Search services, professionals, or locations...",
                  prefixIcon: const Icon(Icons.search, color: AppTheme.outlineColor),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if ((_selectedCountry != null && _selectedCountry != "All") ||
                          (_selectedState != null && _selectedState != "All") ||
                          (_selectedDistrict != null && _selectedDistrict != "All"))
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      IconButton(
                        icon: const Icon(Icons.filter_list, color: AppTheme.primaryColor),
                        onPressed: () => _showLocationFilterSheet(context),
                      ),
                    ],
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
          ),

          // Categories Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Text(
              "Categories",
              style: theme.textTheme.headlineSmall,
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                
                IconData categoryIcon = Icons.help_outline;
                switch (category) {
                  case "All":
                    categoryIcon = Icons.grid_view_outlined;
                    break;
                  case "Healthcare":
                    categoryIcon = Icons.health_and_safety_outlined;
                    break;
                  case "Legal":
                    categoryIcon = Icons.gavel_outlined;
                    break;
                  case "Consulting":
                    categoryIcon = Icons.query_stats_outlined;
                    break;
                  case "Beauty":
                    categoryIcon = Icons.face_outlined;
                    break;
                  case "Fitness":
                    categoryIcon = Icons.fitness_center_outlined;
                    break;
                  case "Education":
                    categoryIcon = Icons.school_outlined;
                    break;
                }

                return Padding(
                  padding: const EdgeInsets.only(right: 8.0, bottom: 4),
                  child: ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          categoryIcon,
                          size: 18,
                          color: isSelected ? Colors.white : AppTheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          category,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w500,
                            color: isSelected ? Colors.white : AppTheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    selected: isSelected,
                    selectedColor: AppTheme.primaryColor,
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: isSelected ? AppTheme.primaryColor : AppTheme.outlineVariantColor,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      }
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Recommended Near You (Bento-Grid layout)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "Recommended Near You",
                    style: theme.textTheme.headlineSmall,
                  ),
                ),
              ],
            ),
          ),
          ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredOrgs.length,
            itemBuilder: (context, index) {
              final org = filteredOrgs[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                  border: Border.all(color: AppTheme.outlineVariantColor),
                  boxShadow: AppTheme.ambientShadow,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrgProfileScreen(org: org),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Org Image
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                                child: Image.network(
                                  org["imageUrl"],
                                  width: 96,
                                  height: 96,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 96,
                                      height: 96,
                                      color: AppTheme.surfaceContainerColor,
                                      child: const Icon(Icons.business, color: AppTheme.primaryColor),
                                    );
                                  },
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(4),
                                    boxShadow: AppTheme.ambientShadow,
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.star, color: Colors.amber, size: 12),
                                      const SizedBox(width: 2),
                                      Text(
                                        org["rating"],
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.onSurfaceColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          // Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  org["name"],
                                  style: GoogleFonts.hankenGrotesk(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.onSurfaceColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${org["specialty"]} • ${org["distance"]}",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: (org["tags"] as List<String>).map((tag) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppTheme.surfaceContainerColor,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: AppTheme.outlineVariantColor, width: 0.5),
                                      ),
                                      child: Text(
                                        tag,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.onSurfaceVariant,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    ),
    
    // Backdrop blur overlay when chatbot is open
    if (_isChatOpen)
      Positioned.fill(
        child: GestureDetector(
          onTap: () {
            setState(() {
              _isChatOpen = false;
            });
          },
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
            child: Container(
              color: Colors.black.withOpacity(0.15),
            ),
          ),
        ),
      ),
    
    // Chat Overlay Card
    if (_isChatOpen)
      Positioned.fill(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Material(
              color: Colors.transparent,
              elevation: 8,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                constraints: const BoxConstraints(
                  maxWidth: 340,
                  maxHeight: 450,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.outlineVariantColor),
                ),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.smart_toy_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Zuruni Assistant",
                                  style: GoogleFonts.hankenGrotesk(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: AppTheme.successColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "Online",
                                      style: GoogleFonts.inter(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.close, color: Colors.white, size: 20),
                            onPressed: () {
                              setState(() {
                                _isChatOpen = false;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    // Chat Messages Body
                    Expanded(
                      child: Container(
                        color: AppTheme.surfaceContainerLow.withOpacity(0.3),
                        child: ListView.builder(
                          controller: _chatScrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _chatMessages.length + (_isTyping ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _chatMessages.length) {
                              // Typing indicator
                              return Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12, right: 40),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: AppTheme.surfaceContainerColor,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      topRight: Radius.circular(16),
                                      bottomRight: Radius.circular(16),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 12,
                                        height: 12,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            AppTheme.primaryColor.withOpacity(0.6),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Assistant is typing...",
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontStyle: FontStyle.italic,
                                          color: AppTheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            final msg = _chatMessages[index];
                            final isMe = msg["isMe"] == true;

                            return Align(
                              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                              child: Column(
                                crossAxisAlignment:
                                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(
                                      bottom: 4,
                                      left: isMe ? 40 : 0,
                                      right: isMe ? 0 : 40,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isMe
                                          ? AppTheme.primaryColor
                                          : AppTheme.surfaceContainerColor,
                                      borderRadius: BorderRadius.only(
                                        topLeft: const Radius.circular(16),
                                        topRight: const Radius.circular(16),
                                        bottomLeft: Radius.circular(isMe ? 16 : 0),
                                        bottomRight: Radius.circular(isMe ? 0 : 16),
                                      ),
                                    ),
                                    child: Text(
                                      msg["text"] ?? "",
                                      style: GoogleFonts.inter(
                                        fontSize: 13.5,
                                        color: isMe ? Colors.white : AppTheme.onSurfaceColor,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 12, left: 4, right: 4),
                                    child: Text(
                                      msg["time"] ?? "",
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        color: AppTheme.outlineColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // Input / Footer
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          top: BorderSide(
                            color: AppTheme.outlineVariantColor.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: TextField(
                                controller: _chatInputController,
                                decoration: const InputDecoration(
                                  hintText: "Type a message...",
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                                  hintStyle: TextStyle(
                                    color: AppTheme.outlineColor,
                                    fontSize: 14,
                                  ),
                                ),
                                style: const TextStyle(fontSize: 14),
                                onSubmitted: (_) => _handleSendChatMessage(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _handleSendChatMessage,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: AppTheme.primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.send,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),

    // Floating Chat Trigger Button
    Positioned(
      bottom: 16,
      right: 16,
      child: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isChatOpen = !_isChatOpen;
            if (_isChatOpen && _chatMessages.isEmpty) {
              final firstName = appState.isLoggedIn && appState.userName.isNotEmpty
                  ? appState.userName.split(' ')[0]
                  : "there";
              _chatMessages.add({
                "text": "Hello $firstName! How can I help you with your bookings today?",
                "isMe": false,
                "time": TimeOfDay.now().format(context),
              });
            }
          });
          if (_isChatOpen) {
            _scrollToBottom();
          }
        },
        backgroundColor: AppTheme.primaryColor,
        shape: const CircleBorder(),
        child: Icon(
          _isChatOpen ? Icons.close : Icons.smart_toy,
          color: Colors.white,
          size: 28,
        ),
      ),
    ),
  ],
);
}
}
