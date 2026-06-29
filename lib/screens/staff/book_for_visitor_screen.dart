import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/theme.dart';
import '../../state/app_state.dart';

class BookForVisitorScreen extends StatefulWidget {
  const BookForVisitorScreen({super.key});

  @override
  State<BookForVisitorScreen> createState() => _BookForVisitorScreenState();
}

class _BookForVisitorScreenState extends State<BookForVisitorScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController(text: "Jane Doe");
  final TextEditingController _emailController = TextEditingController(text: "jane@example.com");
  final TextEditingController _phoneController = TextEditingController(text: "+1 (555) 000-0000");
  final TextEditingController _companyController = TextEditingController(text: "Acme Corp");
  final TextEditingController _dateTimeController = TextEditingController();
  
  String _selectedReason = "Client Pitch";
  String _selectedParking = "No Parking Needed";

  final List<String> _reasons = [
    "Client Pitch",
    "Interview",
    "Consultation",
    "Delivery",
    "Maintenance"
  ];

  final List<String> _parkingOptions = [
    "No Parking Needed",
    "Allocated Parking Bay",
    "General Parking Access"
  ];

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    // Do not prefill date and time to match the placeholder "dd/mm/yyyy, --:-- --" in the mockup!
    _selectedDate = null;
    _selectedTime = null;
    _dateTimeController.clear();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    _dateTimeController.dispose();
    super.dispose();
  }

  void _updateDateTimeText() {
    if (_selectedDate != null && _selectedTime != null) {
      final dateStr = AppTheme.formatDate(_selectedDate!);
      final timeStr = _selectedTime!.format(context);
      _dateTimeController.text = "$dateStr, $timeStr";
    }
  }

  Future<void> _pickDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              onSurface: AppTheme.onSurfaceColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      if (!mounted) return;
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: _selectedTime ?? TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppTheme.primaryColor,
                onPrimary: Colors.white,
                onSurface: AppTheme.onSurfaceColor,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        if (!mounted) return;
        setState(() {
          _selectedDate = pickedDate;
          _selectedTime = pickedTime;
          _updateDateTimeText();
        });
      }
    }
  }

  void _submitBooking() {
    if (_formKey.currentState!.validate()) {
      final appState = Provider.of<AppState>(context, listen: false);
      const refCode = "ZR-9824-XV";
      final timeText = _dateTimeController.text.isNotEmpty 
          ? _dateTimeController.text 
          : "Tomorrow, 2:00 PM"; // Fallback if left empty in testing

      // Add to pending approvals in app state
      appState.addPendingApproval({
        "id": "VIS-9824",
        "name": _nameController.text.trim(),
        "avatar": "",
        "type": _selectedReason,
        "time": timeText,
        "reason": "Booked on behalf by Staff. Purpose: $_selectedReason. Company: ${_companyController.text.trim()}",
        "status": "Pending"
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Booking created successfully! Reference: $refCode"),
          backgroundColor: AppTheme.successColor,
        ),
      );

      Navigator.pop(context);
    }
  }

  InputDecoration _buildInputDecoration({
    String? hintText,
    Widget? suffixIcon,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.inter(
        color: AppTheme.onSurfaceVariant.withOpacity(0.4),
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white, // Changed from Color(0xFFFFF5FD) to white as requested
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEADDF0), width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEADDF0), width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.errorColor, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.errorColor, width: 1.5),
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
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.onSurfaceColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 32.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Portion
                Text(
                  "Book for Visitor",
                  style: GoogleFonts.hankenGrotesk(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.onSurfaceColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Schedule a new appointment on behalf of a guest.",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppTheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),

                // Search Bar
                TextField(
                  controller: _searchController,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppTheme.onSurfaceColor,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: "Search by name, phone, or email...",
                    hintStyle: GoogleFonts.inter(
                      color: AppTheme.onSurfaceVariant.withOpacity(0.5),
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(Icons.search, color: AppTheme.onSurfaceVariant, size: 20),
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Color(0xFFEADDF0), width: 1.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Color(0xFFEADDF0), width: 1.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Send Booking Link Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Booking link sent to visitor's email and phone")),
                      );
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFEDE2EC), // Light grayish pink/purple matching mockup
                      foregroundColor: AppTheme.onSurfaceColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Transform.rotate(
                          angle: -0.2, // slight tilt like paper plane icon in mockup
                          child: const Icon(Icons.send_rounded, size: 16, color: AppTheme.onSurfaceColor),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Send Booking Link",
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppTheme.onSurfaceColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // CARD 1: Add New Visitor Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radius2Xl),
                    border: Border.all(color: const Color(0xFFF1F5F9), width: 1.0),
                    boxShadow: AppTheme.ambientShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Add New Visitor",
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.onSurfaceColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Divider(color: Color(0xFFF1F5F9)),
                      const SizedBox(height: 12),

                      _buildFieldLabel("Full Name"),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nameController,
                        validator: (value) => value == null || value.trim().isEmpty ? "Visitor name cannot be empty" : null,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppTheme.onSurfaceColor,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: _buildInputDecoration(
                          hintText: "Enter visitor's full name",
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildFieldLabel("Email Address"),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _emailController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return "Email address cannot be empty";
                          if (!value.contains("@")) return "Enter a valid email address";
                          return null;
                        },
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppTheme.onSurfaceColor,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: _buildInputDecoration(
                          hintText: "Enter visitor's email address",
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),

                      _buildFieldLabel("Phone Number"),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _phoneController,
                        validator: (value) => value == null || value.trim().isEmpty ? "Phone number cannot be empty" : null,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppTheme.onSurfaceColor,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: _buildInputDecoration(
                          hintText: "Enter visitor's phone number",
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildFieldLabel("Company (Optional)"),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _companyController,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppTheme.onSurfaceColor,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: _buildInputDecoration(
                          hintText: "Enter visitor's company name",
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildFieldLabel("Meeting Reason"),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _selectedReason,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.onSurfaceVariant, size: 20),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppTheme.onSurfaceColor,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: _buildInputDecoration(),
                        items: _reasons.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedReason = val!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      _buildFieldLabel("Date & Time"),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: _pickDateTime,
                        child: AbsParagraph(
                          child: TextFormField(
                            controller: _dateTimeController,
                            readOnly: true,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppTheme.onSurfaceColor,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: _buildInputDecoration(
                              hintText: "dd/mm/yyyy, --:-- --",
                              suffixIcon: const Icon(Icons.calendar_today_outlined, color: AppTheme.onSurfaceVariant, size: 18),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildFieldLabel("Parking Request"),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _selectedParking,
                        icon: const Icon(Icons.directions_car_outlined, color: AppTheme.onSurfaceVariant, size: 18),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppTheme.onSurfaceColor,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: _buildInputDecoration(),
                        items: _parkingOptions.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedParking = val!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // CARD 2: Booking Summary (Amethyst theme card)
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF26053D), // Rich dark amethyst
                            Color(0xFF130120),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(AppTheme.radius2Xl),
                        boxShadow: AppTheme.ambientShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Booking Summary",
                            style: GoogleFonts.hankenGrotesk(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Ref: ZR-9824-XV",
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFFFAF1F9).withOpacity(0.6),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Pending final confirmation.",
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFFFAF1F9).withOpacity(0.5),
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // Big Ticket Badge Container
                          Center(
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 24.0),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                                border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "T-42",
                                style: GoogleFonts.hankenGrotesk(
                                  fontSize: 56,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Background Watermark Geometric Circles
                    Positioned(
                      right: -20,
                      top: -20,
                      child: Opacity(
                        opacity: 0.04,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 12),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 20,
                      top: -40,
                      child: Opacity(
                        opacity: 0.03,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Share with Visitor Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _submitBooking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.share, size: 16, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          "Share with Visitor",
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String labelText) {
    return Text(
      labelText,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: AppTheme.onSurfaceColor,
      ),
    );
  }
}

// Helper widget to prevent taps inside the read-only TextFormField from showing keyboard
class AbsParagraph extends StatelessWidget {
  final Widget child;
  const AbsParagraph({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      child: child,
    );
  }
}

