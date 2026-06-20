import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/theme.dart';
import '../../state/app_state.dart';
import 'payment_success_screen.dart';

class BookingWizardScreen extends StatefulWidget {
  const BookingWizardScreen({Key? key}) : super(key: key);

  @override
  State<BookingWizardScreen> createState() => _BookingWizardScreenState();
}

class _BookingWizardScreenState extends State<BookingWizardScreen> {
  int _currentStep = 0; // 0: Schedule, 1: Visitor Registration, 2: Checkout/Summary
  
  // Step 1: Schedule states
  Map<String, dynamic>? _selectedProfessional;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedTimeSlot;
  DateTime _currentCalendarMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);

  // Step 2: Visitor Registration states
  final _visitorFormKey = GlobalKey<FormState>();
  String? _visitorPurpose;
  bool _parkingNeeded = false;
  final _vehicleController = TextEditingController();
  final List<TextEditingController> _visitorNameControllers = [];
  
  bool _initializedUserFields = false;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final List<String> _timeSlots = [
    "09:00 AM", "09:30 AM", "10:00 AM", "10:30 AM", "11:00 AM", "11:30 AM",
    "01:00 PM", "02:00 PM", "02:30 PM", "03:00 PM", "04:00 PM", "04:30 PM",
    "06:00 PM", "06:30 PM", "07:00 PM"
  ];

  final List<String> _purposes = [
    "Medical Checkup",
    "Legal Consultation",
    "Professional Meeting",
    "General Visit",
  ];

  // Helper methods for scheduling and calendar mapping
  String _getProfessionalAvatar(String name) {
    final lower = name.toLowerCase();
    if (lower.contains("thorne")) {
      return "https://images.unsplash.com/photo-1622253692010-333f2da6031d?auto=format&fit=crop&q=80&w=240";
    } else if (lower.contains("oswald")) {
      return "https://images.unsplash.com/photo-1594824813573-246434de83fb?auto=format&fit=crop&q=80&w=240";
    } else if (lower.contains("paulson")) {
      return "https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&q=80&w=240";
    } else if (lower.contains("sterling")) {
      return "https://images.unsplash.com/photo-1560250097-0b93528c311a?auto=format&fit=crop&q=80&w=240";
    } else if (lower.contains("jenkins")) {
      return "https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&q=80&w=240";
    } else if (lower.contains("rostova")) {
      return "https://images.unsplash.com/photo-1614608682850-e0d6ed316d47?auto=format&fit=crop&q=80&w=240";
    } else if (lower.contains("vance")) {
      return "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&q=80&w=240";
    } else if (lower.contains("specter")) {
      return "https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?auto=format&fit=crop&q=80&w=240";
    }
    return "https://images.unsplash.com/photo-1622253692010-333f2da6031d?auto=format&fit=crop&q=80&w=240";
  }

  String _formatFullDate(DateTime date) {
    const weekdays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];
    const months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
    return "${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}";
  }

  List<String> _getSlotsForPeriod(String period) {
    return _timeSlots.where((slot) {
      final isPM = slot.contains("PM");
      final hourStr = slot.split(":")[0];
      final hour = int.parse(hourStr);
      
      if (period == "Morning") {
        return !isPM;
      } else if (period == "Afternoon") {
        return isPM && (hour == 12 || hour < 5);
      } else {
        return isPM && hour >= 5 && hour != 12;
      }
    }).toList();
  }

  List<DateTime> _generateCalendarDays(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final startWeekday = firstDay.weekday; // 1 to 7
    final padDays = startWeekday - 1;
    final calendarStartDate = firstDay.subtract(Duration(days: padDays));
    
    // Generate exactly 21 days (3 weeks) to match the mockup grid exactly
    return List.generate(21, (index) => calendarStartDate.add(Duration(days: index)));
  }

  String _getMonthYearString(DateTime date) {
    const months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
    return "${months[date.month - 1]} ${date.year}";
  }

  Widget _buildPeriodSlots(String period, IconData icon) {
    final slots = _getSlotsForPeriod(period);
    if (slots.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppTheme.onSurfaceVariant.withOpacity(0.8)),
            const SizedBox(width: 6),
            Text(
              period,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.onSurfaceColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3.2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: slots.length,
          itemBuilder: (context, index) {
            final slot = slots[index];
            final isSelected = _selectedTimeSlot == slot;
            final isDisabled = slot == "03:00 PM";
            
            return GestureDetector(
              onTap: isDisabled ? null : () {
                setState(() {
                  _selectedTimeSlot = slot;
                });
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppTheme.primaryColor 
                      : (isDisabled ? const Color(0xFFF1F5F9) : Colors.white),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  border: Border.all(
                    color: isSelected 
                        ? AppTheme.primaryColor 
                        : (isDisabled ? const Color(0xFFE2E8F0) : const Color(0xFFF1EBF1)),
                  ),
                ),
                child: Text(
                  slot,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected 
                        ? Colors.white 
                        : (isDisabled ? AppTheme.outlineColor.withOpacity(0.5) : AppTheme.onSurfaceColor),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  @override
  void dispose() {
    _vehicleController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    for (var controller in _visitorNameControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_selectedProfessional == null) {
        _showError("Please select a professional");
        return;
      }
      if (_selectedTimeSlot == null) {
        _showError("Please select a time slot");
        return;
      }
      setState(() {
        _currentStep = 1;
      });
    } else if (_currentStep == 1) {
      if (_visitorFormKey.currentState!.validate()) {
        setState(() {
          _currentStep = 2;
        });
      }
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.errorColor),
    );
  }

  void _completeBooking(AppState appState) {
    // Synchronize primary visitor fields back to the user's profile state
    appState.updateProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      country: appState.userCountry,
    );

    // Generate mock parking bay & gate codes if they had verified profile
    final hasVerified = appState.verificationStatus == VerificationStatus.verified;
    
    // Create new appointment model
    final newApt = Appointment(
      id: "APT-${10000 + (DateTime.now().millisecond * 17) % 90000}",
      professionalName: _selectedProfessional!["name"],
      organizationName: appState.selectedOrg!["name"],
      category: appState.selectedCategory ?? "Healthcare",
      date: _selectedDate,
      timeSlot: _selectedTimeSlot!,
      status: hasVerified ? "Verified" : "Pending",
      gateAccessCode: hasVerified ? "G-${4000 + (DateTime.now().millisecond) % 6000}" : null,
      doorAccessCode: hasVerified ? "D-${1000 + (DateTime.now().millisecond) % 9000}" : null,
      parkingBay: (_parkingNeeded && hasVerified) 
          ? "B-${1 + (DateTime.now().second) % 30} (P2 Level)" 
          : null,
      timelineSteps: hasVerified 
        ? [
            "Gate Check-in Approved",
            _parkingNeeded ? "Vehicle Parked in Assigned Bay" : "Visitor Entry Recorded",
            "Elevator Door Code Unlocked",
            "Checked-in at Reception",
            "Session in Progress",
            "Facility Exit Complete"
          ]
        : [
            "Pending Identity Verification",
            "Awaiting Host Clearance",
            "Gate Access Activation",
            "Lobby Check-in",
            "Facility Exit"
          ],
      activeTimelineIndex: 0,
    );

    appState.addAppointment(newApt);

    // Save wizard details in AppState to show on success screen if needed
    appState.selectedDate = _selectedDate;
    appState.selectedTimeSlot = _selectedTimeSlot;
    appState.visitorPurpose = _visitorPurpose ?? "Medical Checkup";
    appState.parkingNeeded = _parkingNeeded;
    appState.vehicleNumber = _vehicleController.text;
    appState.visitorNames = _visitorNameControllers.map((c) => c.text).toList();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentSuccessScreen(appointment: newApt),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    if (!_initializedUserFields) {
      _nameController.text = appState.userName;
      _emailController.text = appState.userEmail;
      _phoneController.text = appState.userPhone;
      _initializedUserFields = true;
    }

    // Initial professional selection if not selected yet
    if (_selectedProfessional == null && appState.selectedOrg != null) {
      final professionals = appState.selectedOrg!["professionals"] as List;
      if (professionals.isNotEmpty) {
        _selectedProfessional = professionals.first;
      }
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.onSurfaceColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          appState.selectedService ?? "Book Appointment",
          style: GoogleFonts.hankenGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Custom Stepper
            _buildStepper(),
            const Divider(color: AppTheme.surfaceContainerColor, height: 1),
            
            // Step Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: _buildStepContent(appState),
              ),
            ),
            
            // Bottom Action Bar
            _buildBottomBar(appState),
          ],
        ),
      ),
    );
  }

  Widget _buildStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      color: Colors.white,
      child: Row(
        children: [
          _buildStepNode(0, "Schedule"),
          _buildStepLine(0),
          _buildStepNode(1, "Visitors"),
          _buildStepLine(1),
          _buildStepNode(2, "Checkout"),
        ],
      ),
    );
  }

  Widget _buildStepNode(int index, String title) {
    final isActive = _currentStep == index;
    final isCompleted = _currentStep > index;
    
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isCompleted 
                ? AppTheme.primaryColor 
                : (isActive ? AppTheme.primaryColor : Colors.white),
            shape: BoxShape.circle,
            border: Border.all(
              color: isCompleted || isActive ? AppTheme.primaryColor : AppTheme.outlineVariantColor,
              width: 2,
            ),
          ),
          child: Center(
            child: isCompleted 
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : Text(
                    "${index + 1}",
                    style: TextStyle(
                      color: isActive ? Colors.white : AppTheme.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: isActive || isCompleted ? FontWeight.bold : FontWeight.w500,
            color: isActive || isCompleted ? AppTheme.onSurfaceColor : AppTheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(int index) {
    final isCompleted = _currentStep > index;
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 16.0),
        color: isCompleted ? AppTheme.primaryColor : AppTheme.surfaceContainerColor,
      ),
    );
  }

  Widget _buildStepContent(AppState appState) {
    switch (_currentStep) {
      case 0:
        return _buildScheduleStep(appState);
      case 1:
        return _buildVisitorStep();
      case 2:
        return _buildCheckoutStep(appState);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildScheduleStep(AppState appState) {
    final professionals = appState.selectedOrg!["professionals"] as List;
    final calendarDays = _generateCalendarDays(_currentCalendarMonth);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Choose Professional
        Text(
          "Choose Professional",
          style: GoogleFonts.hankenGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.onSurfaceColor,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: List.generate(professionals.length, (index) {
            final prof = professionals[index];
            final isSelected = _selectedProfessional == prof;
            final avatarUrl = _getProfessionalAvatar(prof["name"]);
            
            // availability text: Available Today for index 0, Next: Tue, May 14 (or equivalent) for index 1
            final availability = index == 0 
                ? "Available Today" 
                : "Next: ${_formatFullDate(DateTime.now().add(const Duration(days: 1))).split(", ")[1]}"; // Formatted like "May 14" or "June 21"
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedProfessional = prof;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12.0),
                padding: const EdgeInsets.all(14.0),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFAF5FF) : Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                  border: Border.all(
                    color: isSelected ? AppTheme.primaryColor : const Color(0xFFF1EBF1),
                    width: isSelected ? 2.0 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundImage: NetworkImage(avatarUrl),
                      backgroundColor: const Color(0xFFF1EBF1),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            prof["name"],
                            style: GoogleFonts.hankenGrotesk(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.onSurfaceColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            availability,
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected 
                                  ? AppTheme.primaryColor.withOpacity(0.8) 
                                  : AppTheme.onSurfaceVariant.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle,
                        color: AppTheme.primaryColor,
                        size: 22,
                      ),
                  ],
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 24),

        // Select Date (Calendar Header with month navigation)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Select Date",
              style: GoogleFonts.hankenGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.onSurfaceColor,
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, size: 20),
                  onPressed: () {
                    setState(() {
                      _currentCalendarMonth = DateTime(
                        _currentCalendarMonth.year,
                        _currentCalendarMonth.month - 1,
                        1,
                      );
                    });
                  },
                ),
                Text(
                  _getMonthYearString(_currentCalendarMonth),
                  style: GoogleFonts.hankenGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.onSurfaceColor,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, size: 20),
                  onPressed: () {
                    setState(() {
                      _currentCalendarMonth = DateTime(
                        _currentCalendarMonth.year,
                        _currentCalendarMonth.month + 1,
                        1,
                      );
                    });
                  },
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Days of week Mo Tu We Th Fr Sa Su
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"].map((day) {
              return Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurfaceVariant.withOpacity(0.6),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 10),

        // Calendar Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1.1,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: calendarDays.length,
          itemBuilder: (context, index) {
            final day = calendarDays[index];
            final isSelected = day.day == _selectedDate.day &&
                day.month == _selectedDate.month &&
                day.year == _selectedDate.year;
            final isCurrentMonth = day.month == _currentCalendarMonth.month;
            final isWeekend = day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;
            final isPast = day.isBefore(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));
            
            final isEnabled = isCurrentMonth && !isPast;
            
            return GestureDetector(
              onTap: !isEnabled ? null : () {
                setState(() {
                  _selectedDate = day;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    "${day.day}",
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : (isCurrentMonth
                              ? (isWeekend || isPast
                                  ? AppTheme.outlineColor.withOpacity(0.4)
                                  : AppTheme.onSurfaceColor)
                              : AppTheme.outlineColor.withOpacity(0.25)),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),

        // Available Time Slots
        Text(
          "Available Time Slots",
          style: GoogleFonts.hankenGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.onSurfaceColor,
          ),
        ),
        const SizedBox(height: 16),

        _buildPeriodSlots("Morning", Icons.wb_sunny_outlined),
        _buildPeriodSlots("Afternoon", Icons.wb_twilight),
        _buildPeriodSlots("Evening", Icons.mode_night_outlined),
      ],
    );
  }

  Widget _buildVisitorStep() {
    final appState = Provider.of<AppState>(context, listen: false);
    final orgName = appState.selectedOrg != null ? appState.selectedOrg!["name"] : "Zuruni Partner";
    
    return Form(
      key: _visitorFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Centered Header matching screenshot
          Center(
            child: Column(
              children: [
                Text(
                  "Visitor Registration",
                  style: GoogleFonts.hankenGrotesk(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.onSurfaceColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  orgName,
                  style: GoogleFonts.hankenGrotesk(
                    fontSize: 14,
                    color: AppTheme.onSurfaceVariant.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Full Name field
          Text(
            "Full Name",
            style: GoogleFonts.hankenGrotesk(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.onSurfaceColor,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: "Jane Doe",
              prefixIcon: null, // Clean, no prefix icon
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter full name';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Email Address field
          Text(
            "Email Address",
            style: GoogleFonts.hankenGrotesk(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.onSurfaceColor,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: "jane@example.com",
              prefixIcon: null,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter email address';
              }
              if (!value.contains("@")) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Mobile Number field
          Text(
            "Mobile Number",
            style: GoogleFonts.hankenGrotesk(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.onSurfaceColor,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              hintText: "+1 (555) 000-0000",
              prefixIcon: null,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter mobile number';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Purpose of Visit field
          Text(
            "Purpose of Visit",
            style: GoogleFonts.hankenGrotesk(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.onSurfaceColor,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _visitorPurpose,
            hint: Text(
              "Select purpose...",
              style: GoogleFonts.inter(
                color: AppTheme.outlineColor.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
            icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.outlineColor),
            items: _purposes.map((p) {
              return DropdownMenuItem(
                value: p,
                child: Text(
                  p,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppTheme.onSurfaceColor,
                  ),
                ),
              );
            }).toList(),
            onChanged: (val) {
              setState(() {
                _visitorPurpose = val;
              });
            },
            decoration: const InputDecoration(
              prefixIcon: null, // Clean, no prefix icon
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a purpose';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Need Parking SWITCH row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Need Parking?",
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurfaceColor,
                ),
              ),
              Switch(
                value: _parkingNeeded,
                activeColor: AppTheme.primaryColor,
                activeTrackColor: AppTheme.primaryColor.withOpacity(0.3),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: const Color(0xFFE8E1EB),
                onChanged: (val) {
                  setState(() {
                    _parkingNeeded = val;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Vehicle Number (if parking needed)
          if (_parkingNeeded) ...[
            Text(
              "Vehicle Registration Number",
              style: GoogleFonts.hankenGrotesk(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.onSurfaceColor,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _vehicleController,
              decoration: const InputDecoration(
                hintText: "e.g., KA-03-HA-1988",
                prefixIcon: null,
              ),
              validator: (value) {
                if (_parkingNeeded && (value == null || value.trim().isEmpty)) {
                  return 'Please enter vehicle registration number';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
          ],

          // Companion Visitor Section
          const Divider(color: Color(0xFFF4EBF4), height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Companion Visitors",
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurfaceColor,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _visitorNameControllers.add(TextEditingController());
                  });
                },
                icon: const Icon(Icons.add, size: 16, color: AppTheme.primaryColor),
                label: Text(
                  "Add Companion",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          if (_visitorNameControllers.isNotEmpty) ...[
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _visitorNameControllers.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Companion ${index + 1} Name",
                            style: GoogleFonts.hankenGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.onSurfaceColor,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _visitorNameControllers[index].dispose();
                                _visitorNameControllers.removeAt(index);
                              });
                            },
                            child: Text(
                              "Remove",
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.errorColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _visitorNameControllers[index],
                        decoration: const InputDecoration(
                          hintText: "Enter companion's full name",
                          prefixIcon: null, // Clean, no prefix icon
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Please enter companion's name";
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCheckoutStep(AppState appState) {
    double servicePrice = appState.selectedServicePrice ?? 0.0;
    double parkingPrice = _parkingNeeded ? 10.0 : 0.0;
    double convenienceFee = 5.0;
    double total = servicePrice + parkingPrice + convenienceFee;

    // Check verification status
    final isVerified = appState.verificationStatus == VerificationStatus.verified;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Unified Checkout",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        
        // Security Banner if unverified
        if (!isVerified)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: AppTheme.pendingColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              border: Border.all(color: AppTheme.pendingColor, width: 0.5),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber_rounded, color: AppTheme.pendingColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Verification Required",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.pendingColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Your profile is not verified. To activate digital gate QR passes instantly, upload a government ID in your Profile tab before checkout, or complete verification at reception.",
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppTheme.onSurfaceVariant,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        // Summary Card
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            border: Border.all(color: AppTheme.outlineVariantColor),
            boxShadow: AppTheme.ambientShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                appState.selectedOrg!["name"],
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "${appState.selectedOrg!["specialty"]} • ${appState.selectedOrg!["distance"]}",
                style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant),
              ),
              const Divider(height: 24),
              
              // Appointment Summary
              _buildSummaryRow("Professional", _selectedProfessional!["name"]),
              _buildSummaryRow("Service", appState.selectedService ?? ""),
              _buildSummaryRow(
                "Date & Time",
                "${AppTheme.formatDate(_selectedDate)} at $_selectedTimeSlot",
              ),
              _buildSummaryRow("Purpose", _visitorPurpose ?? ""),
              _buildSummaryRow("Parking", _parkingNeeded ? "Requested (Assigned on arrival)" : "Not Required"),
              _buildSummaryRow("Visitors", _visitorNameControllers.map((c) => c.text).join(", ")),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Charge breakdown
        Text(
          "Payment Breakdown",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            border: Border.all(color: AppTheme.outlineVariantColor),
          ),
          child: Column(
            children: [
              _buildPriceRow("Service Fee", servicePrice),
              if (_parkingNeeded) _buildPriceRow("Valet Parking reservation", parkingPrice),
              _buildPriceRow("Zuruni Convenience Charge", convenienceFee),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total Amount",
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurfaceColor,
                    ),
                  ),
                  Text(
                    "\$${total.toStringAsFixed(2)}",
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: AppTheme.onSurfaceVariant, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, color: AppTheme.onSurfaceColor, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppTheme.onSurfaceVariant),
          ),
          Text(
            "\$${amount.toStringAsFixed(2)}",
            style: const TextStyle(fontSize: 13, color: AppTheme.onSurfaceColor, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(AppState appState) {
    if (_currentStep == 0) {
      final isReady = _selectedProfessional != null && _selectedTimeSlot != null;
      
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              offset: const Offset(0, -4),
              blurRadius: 10,
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Summary row: icon, service name, selection details
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF5FF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFF3E8FF)),
                    ),
                    child: const Icon(
                      Icons.assignment_outlined,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appState.selectedService ?? "General Consultation",
                          style: GoogleFonts.hankenGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.onSurfaceColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _selectedTimeSlot != null
                              ? "${_formatFullDate(_selectedDate)} • $_selectedTimeSlot"
                              : "Select date and time slot",
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppTheme.onSurfaceVariant.withOpacity(0.8),
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
              // Fee and Confirm Button row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Estimated Fee",
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.outlineColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "\$${(appState.selectedServicePrice ?? 85.0).toStringAsFixed(2)}",
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.onSurfaceColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isReady ? _nextStep : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        disabledBackgroundColor: AppTheme.outlineVariantColor,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Confirm Selection",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
    }
    
    // Other steps bottom bar (Step 1 and Step 2)
    final isLastStep = _currentStep == 2;
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (_currentStep > 0) ...[
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                  ),
                  side: const BorderSide(color: AppTheme.outlineColor),
                ),
                onPressed: _prevStep,
                child: const Icon(Icons.arrow_back, color: AppTheme.onSurfaceColor),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (isLastStep) {
                    _completeBooking(appState);
                  } else {
                    _nextStep();
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                  ),
                ),
                child: Text(
                  isLastStep ? "PAY & CONFIRM" : "CONTINUE",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
