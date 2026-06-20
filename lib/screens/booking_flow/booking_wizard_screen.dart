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

  // Step 2: Visitor Registration states
  final _visitorFormKey = GlobalKey<FormState>();
  String _visitorPurpose = "Medical Checkup";
  bool _parkingNeeded = false;
  final _vehicleController = TextEditingController();
  final List<TextEditingController> _visitorNameControllers = [TextEditingController()];

  final List<String> _timeSlots = [
    "09:00 AM", "09:30 AM", "10:00 AM", "10:30 AM",
    "11:00 AM", "11:30 AM", "01:30 PM", "02:00 PM",
    "02:30 PM", "03:00 PM", "03:30 PM", "04:00 PM"
  ];

  final List<String> _purposes = [
    "Medical Checkup",
    "Legal Consultation",
    "Professional Meeting",
    "General Visit",
  ];

  @override
  void dispose() {
    _vehicleController.dispose();
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
    appState.visitorPurpose = _visitorPurpose;
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
    final theme = Theme.of(context);

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
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Choose Professional
        Text(
          "Select Professional",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: professionals.length,
            itemBuilder: (context, index) {
              final prof = professionals[index];
              final isSelected = _selectedProfessional == prof;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedProfessional = prof;
                  });
                },
                child: Container(
                  width: 180,
                  margin: const EdgeInsets.only(right: 12.0),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.surfaceContainerColor : Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryColor : AppTheme.outlineVariantColor,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: isSelected ? Colors.white : AppTheme.surfaceContainerColor,
                        child: Text(
                          prof["name"][0] + prof["name"].split(" ")[1][0],
                          style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              prof["name"],
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              prof["role"],
                              style: const TextStyle(fontSize: 10, color: AppTheme.onSurfaceVariant),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),

        // Choose Date
        Text(
          "Select Date",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 64,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: 14,
            itemBuilder: (context, index) {
              final date = DateTime.now().add(Duration(days: index + 1));
              final isSelected = date.day == _selectedDate.day && date.month == _selectedDate.month;
              
              final weekday = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"][date.weekday - 1];
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                  });
                },
                child: Container(
                  width: 56,
                  margin: const EdgeInsets.only(right: 8.0),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryColor : Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryColor : AppTheme.outlineVariantColor,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        weekday,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white70 : AppTheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${date.day}",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : AppTheme.onSurfaceColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),

        // Choose Time
        Text(
          "Available Time Slots",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 2.2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: _timeSlots.length,
          itemBuilder: (context, index) {
            final slot = _timeSlots[index];
            final isSelected = _selectedTimeSlot == slot;
            
            return ChoiceChip(
              label: Container(
                alignment: Alignment.center,
                child: Text(
                  slot,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : AppTheme.onSurfaceColor,
                  ),
                ),
              ),
              selected: isSelected,
              selectedColor: AppTheme.primaryColor,
              backgroundColor: Colors.white,
              side: BorderSide(
                color: isSelected ? AppTheme.primaryColor : AppTheme.outlineVariantColor,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              ),
              showCheckmark: false,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedTimeSlot = slot;
                  });
                }
              },
            );
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildVisitorStep() {
    return Form(
      key: _visitorFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Visitor Management",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text(
            "Clearance protocols require registering visit particulars. Assures seamless parking entry and lobby check-in validation.",
            style: TextStyle(fontSize: 13, color: AppTheme.onSurfaceVariant, height: 1.3),
          ),
          const SizedBox(height: 24),

          // Purpose of Visit
          Text(
            "Purpose of Visit",
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.onSurfaceColor,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _visitorPurpose,
            items: _purposes.map((p) {
              return DropdownMenuItem(value: p, child: Text(p));
            }).toList(),
            onChanged: (val) {
              setState(() {
                _visitorPurpose = val!;
              });
            },
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.info_outline, color: AppTheme.outlineColor),
            ),
          ),
          const SizedBox(height: 20),

          // Parking Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Require Parking Access",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.onSurfaceColor,
                    ),
                  ),
                  const Text(
                    "Assigns automated gate clearance & bay",
                    style: TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant),
                  ),
                ],
              ),
              Switch(
                value: _parkingNeeded,
                activeColor: AppTheme.primaryColor,
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
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.onSurfaceColor,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _vehicleController,
              decoration: const InputDecoration(
                hintText: "e.g., KA-03-HA-1988",
                prefixIcon: Icon(Icons.directions_car_outlined, color: AppTheme.outlineColor),
              ),
              validator: (value) {
                if (_parkingNeeded && (value == null || value.isEmpty)) {
                  return 'Please enter vehicle registration number';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
          ],

          // Companion Visitor Names
          Text(
            "Visitor Names",
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.onSurfaceColor,
            ),
          ),
          const Text(
            "Add names of companions attending the session",
            style: TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _visitorNameControllers.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _visitorNameControllers[index],
                        decoration: InputDecoration(
                          hintText: index == 0 ? "Alex Mercer (Primary)" : "Visitor ${index + 1}",
                          prefixIcon: const Icon(Icons.person_outline, color: AppTheme.outlineColor),
                        ),
                        validator: (value) {
                          if (index == 0 && (value == null || value.isEmpty)) {
                            return 'Primary visitor name is required';
                          }
                          return null;
                        },
                      ),
                    ),
                    if (index > 0) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: AppTheme.errorColor),
                        onPressed: () {
                          setState(() {
                            _visitorNameControllers.removeAt(index);
                          });
                        },
                      )
                    ]
                  ],
                ),
              );
            },
          ),
          TextButton.icon(
            onPressed: () {
              setState(() {
                _visitorNameControllers.add(TextEditingController());
              });
            },
            icon: const Icon(Icons.add, color: AppTheme.primaryColor),
            label: const Text(
              "Add Companion Visitor",
              style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 24),
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
                "${_selectedDate.month}/${_selectedDate.day}/${_selectedDate.year} at $_selectedTimeSlot",
              ),
              _buildSummaryRow("Purpose", _visitorPurpose),
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
    final isLastStep = _currentStep == 2;
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
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
              child: Text(isLastStep ? "PAY & CONFIRM" : "CONTINUE"),
            ),
          ),
        ],
      ),
    );
  }
}
