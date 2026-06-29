import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/theme.dart';
import '../../state/app_state.dart';

class NewMeetingScreen extends StatefulWidget {
  const NewMeetingScreen({super.key});

  @override
  State<NewMeetingScreen> createState() => _NewMeetingScreenState();
}

class _NewMeetingScreenState extends State<NewMeetingScreen> {
  final _titleController = TextEditingController();
  final _dateTimeController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _selectedDuration = "30 Minutes";
  bool _isAutoApproval = true;
  bool _onlyAcceptSelected = true;
  bool _tokenSystemEnabled = true;
  final _startingTokenController = TextEditingController(text: "001");
  bool _parkingEnabled = false;

  final List<String> _durations = [
    "15 Minutes",
    "30 Minutes",
    "45 Minutes",
    "60 Minutes",
    "90 Minutes",
  ];

  final List<String> _reasons = [
    "Consultation",
    "Performance Review",
    "Client Onboarding",
    "Technical Support",
  ];

  final Set<String> _selectedReasons = {"Consultation"};

  @override
  void dispose() {
    _titleController.dispose();
    _dateTimeController.dispose();
    _startingTokenController.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay time) {
    final h = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final hour = h.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    final amPm = time.period == DayPeriod.am ? "AM" : "PM";
    return "$hour:$minute $amPm";
  }

  void _updateDateTimeTextField() {
    if (_selectedDate == null && _selectedTime == null) {
      _dateTimeController.text = "";
      return;
    }
    final dateStr = _selectedDate != null
        ? "${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}"
        : "dd/mm/yyyy";
    final timeStr = _selectedTime != null
        ? _formatTime(_selectedTime!)
        : "--:-- --";
    _dateTimeController.text = "$dateStr, $timeStr";
  }

  Future<void> _selectDateOnly(BuildContext context) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date == null) return;
    if (!context.mounted) return;

    setState(() {
      _selectedDate = date;
      _updateDateTimeTextField();
    });
  }

  Future<void> _selectTimeOnly(BuildContext context) async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );

    if (time == null) return;
    if (!context.mounted) return;

    setState(() {
      _selectedTime = time;
      _updateDateTimeTextField();
    });
  }

  Future<void> _selectDateTimeSequential(BuildContext context) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date == null) return;
    if (!context.mounted) return;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );

    if (time == null) return;
    if (!context.mounted) return;

    setState(() {
      _selectedDate = date;
      _selectedTime = time;
      _updateDateTimeTextField();
    });
  }

  InputDecoration _buildInputDecoration({required String hintText, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.inter(
        color: AppTheme.onSurfaceVariant.withOpacity(0.4),
        fontSize: 14,
      ),
      fillColor: Colors.white,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        borderSide: const BorderSide(color: Color(0xFFEADDF0), width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        borderSide: const BorderSide(color: Color(0xFFEADDF0), width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.onSurfaceColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Screen Title Header
                    Text(
                      "New Meeting",
                      style: GoogleFonts.hankenGrotesk(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.onSurfaceColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Configure details, access controls, and resources for your upcoming session.",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppTheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Section 1: Meeting Details Card
                    _buildSectionCard(
                      title: "Meeting Details",
                      children: [
                        Text(
                          "Meeting Title / Agenda",
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _titleController,
                          style: GoogleFonts.inter(fontSize: 14),
                          decoration: _buildInputDecoration(hintText: "e.g. Quarterly Review"),
                        ),
                        const SizedBox(height: 16),
                        
                        Text(
                          "Date & Time",
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _dateTimeController,
                          readOnly: true,
                          onTap: () => _selectDateTimeSequential(context),
                          style: GoogleFonts.inter(fontSize: 14),
                          decoration: _buildInputDecoration(
                            hintText: "dd/mm/yyyy, --:-- --",
                            suffixIcon: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () => _selectDateOnly(context),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.calendar_today_outlined, 
                                        size: 18, 
                                        color: AppTheme.onSurfaceVariant.withOpacity(0.6),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () => _selectTimeOnly(context),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.access_time, 
                                        size: 18, 
                                        color: AppTheme.onSurfaceVariant.withOpacity(0.6),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        Text(
                          "Duration",
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                            border: Border.all(color: const Color(0xFFEADDF0), width: 1.0),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedDuration,
                              isExpanded: true,
                              icon: Icon(Icons.keyboard_arrow_down, color: AppTheme.onSurfaceVariant.withOpacity(0.6)),
                              style: GoogleFonts.inter(fontSize: 14, color: AppTheme.onSurfaceColor),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _selectedDuration = val;
                                  });
                                }
                              },
                              items: _durations.map((String duration) {
                                return DropdownMenuItem<String>(
                                  value: duration,
                                  child: Text(duration),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Section 2: Access Control Card
                    _buildSectionCard(
                      title: "Access Control",
                      children: [
                        // Approval Type segmented control
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Approval Type",
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.onSurfaceColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Choose how attendees join",
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: AppTheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 38,
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEADCEE),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => setState(() => _isAutoApproval = true),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: _isAutoApproval ? Colors.white : Colors.transparent,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        "Auto",
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: _isAutoApproval ? AppTheme.onSurfaceColor : AppTheme.onSurfaceVariant.withOpacity(0.6),
                                        ),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => setState(() => _isAutoApproval = false),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: !_isAutoApproval ? Colors.white : Colors.transparent,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        "Manual",
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: !_isAutoApproval ? AppTheme.onSurfaceColor : AppTheme.onSurfaceVariant.withOpacity(0.6),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Allowed Reasons List
                        Text(
                          "Allowed Reasons for Meeting",
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                            border: Border.all(color: const Color(0xFFEADDF0), width: 1.0),
                          ),
                          child: Column(
                            children: _reasons.map((String reason) {
                              final isSelected = _selectedReasons.contains(reason);
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      _selectedReasons.remove(reason);
                                    } else {
                                      _selectedReasons.add(reason);
                                    }
                                  });
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  color: isSelected ? const Color(0xFFFAF1F9) : Colors.transparent,
                                  child: Text(
                                    reason,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? AppTheme.primaryColor : AppTheme.onSurfaceColor,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Only accept selected reasons checkbox
                        Row(
                          children: [
                            Checkbox(
                              value: _onlyAcceptSelected,
                              activeColor: Colors.black,
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _onlyAcceptSelected = val;
                                  });
                                }
                              },
                            ),
                            Text(
                              "Only accept selected reasons",
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.onSurfaceColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Section 3: Resources & Logistics Card
                    _buildSectionCard(
                      title: "Resources & Logistics",
                      children: [
                        // Token System Block
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAF1F9),
                            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.confirmation_num_outlined, color: AppTheme.primaryColor),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Token System",
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.onSurfaceColor,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          "Enable physical/digital queuing",
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: AppTheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Switch(
                                    value: _tokenSystemEnabled,
                                    activeColor: Colors.black,
                                    onChanged: (val) {
                                      setState(() {
                                        _tokenSystemEnabled = val;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              if (_tokenSystemEnabled) ...[
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Text(
                                      "Starting Token:",
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.onSurfaceColor,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    SizedBox(
                                      width: 80,
                                      height: 38,
                                      child: TextField(
                                        controller: _startingTokenController,
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryColor,
                                        ),
                                        decoration: InputDecoration(
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                                          fillColor: Colors.white,
                                          filled: true,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                                            borderSide: const BorderSide(color: Color(0xFFEADDF0)),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                                            borderSide: const BorderSide(color: Color(0xFFEADDF0)),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                                            borderSide: const BorderSide(color: AppTheme.primaryColor),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Visitor Parking Block
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAF1F9),
                            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                          ),
                          child: Row(
                            children: [
                              const Text(
                                "P",
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.primaryColor,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Visitor Parking",
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.onSurfaceColor,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "Allocate parking slots",
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: AppTheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _parkingEnabled,
                                activeColor: Colors.black,
                                onChanged: (val) {
                                  setState(() {
                                    _parkingEnabled = val;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Bottom Buttons Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Cancel",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.onSurfaceVariant,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_titleController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Please enter a meeting title")),
                            );
                            return;
                          }

                          final appState = Provider.of<AppState>(context, listen: false);
                          
                          String dateGroup = "Upcoming";
                          if (_selectedDate != null) {
                            final now = DateTime.now();
                            final today = DateTime(now.year, now.month, now.day);
                            final target = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day);
                            final diff = target.difference(today).inDays;
                            if (diff == 0) {
                              dateGroup = "Today";
                            } else if (diff == 1) {
                              dateGroup = "Tomorrow";
                            }
                          } else {
                            dateGroup = "Today";
                          }

                          String timeStr = "10:00 AM - 10:30 AM";
                          if (_selectedTime != null) {
                            final startStr = _formatTime(_selectedTime!);
                            timeStr = "$startStr (${_selectedDuration})";
                          }

                          String initials = "AR";
                          if (appState.userName.isNotEmpty) {
                            try {
                              initials = appState.userName.split(" ").map((s) => s[0]).join().toUpperCase();
                            } catch (_) {}
                          }

                          appState.addScheduledMeeting({
                            "title": _titleController.text,
                            "time": timeStr,
                            "location": appState.isHospitalStaff ? "Consultation Room 4" : "Boardroom A",
                            "type": "Internal",
                            "dateGroup": dateGroup,
                            "host": appState.userName,
                            "attendeeInitials": [initials, "MW"],
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Meeting '${_titleController.text}' saved and published"),
                              backgroundColor: AppTheme.successColor,
                            ),
                          );
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          "Save & Publish",
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radius2Xl),
        boxShadow: AppTheme.ambientShadow,
        border: Border.all(color: AppTheme.outlineVariantColor.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.hankenGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.onSurfaceColor,
            ),
          ),
          const SizedBox(height: 4),
          const Divider(color: Color(0xFFF1F5F9), thickness: 1),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}
