import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/theme.dart';
import 'prescription_details_screen.dart';

class Prescription {
  final String date;
  final String patientName;
  final String medicinesSummary;
  final String status; // "Refill Available", "Follow-up Required", "Completed", "Last entry"
  final String attendingPhysician;
  final String diagnosis;
  final List<Map<String, String>> medicines;
  final List<String> additionalInstructions;

  Prescription({
    required this.date,
    required this.patientName,
    required this.medicinesSummary,
    required this.status,
    required this.attendingPhysician,
    required this.diagnosis,
    required this.medicines,
    required this.additionalInstructions,
  });
}

class PrescriptionHistoryScreen extends StatefulWidget {
  const PrescriptionHistoryScreen({super.key});

  @override
  State<PrescriptionHistoryScreen> createState() => _PrescriptionHistoryScreenState();
}

class _PrescriptionHistoryScreenState extends State<PrescriptionHistoryScreen> {
  String _searchQuery = "";
  String _selectedFilter = "ALL";

  final List<Prescription> _prescriptions = [
    Prescription(
      date: "2023-11-24",
      patientName: "Eleanor Shellstrop",
      medicinesSummary: "Paracetamol 500mg, Amoxicillin 250mg, Cetirizine 10mg",
      status: "Refill Available",
      attendingPhysician: "Dr. Sarah Amethyst, MD",
      diagnosis: "Acute Respiratory Infection with mild bronchial inflammation. Patient exhibits symptoms of persistent dry cough and low-grade fever.",
      medicines: [
        {"name": "Amoxicillin", "info": "500mg Capsule", "dosage": "1 Cap", "frequency": "Every 8 Hours"},
        {"name": "Guaifenesin", "info": "Cough Syrup", "dosage": "10ml", "frequency": "Twice Daily"},
        {"name": "Vitamin C", "info": "1000mg Effervescent", "dosage": "1 Tab", "frequency": "Once Daily"},
      ],
      additionalInstructions: [
        "Ensure complete rest for at least 72 hours.",
        "Maintain hydration: drink at least 2.5 liters of water daily.",
        "Avoid cold beverages and oily foods until symptoms subside.",
      ],
    ),
    Prescription(
      date: "2023-11-22",
      patientName: "Chidi Anagonye",
      medicinesSummary: "Lisinopril 10mg, Metformin 500mg",
      status: "Follow-up Required",
      attendingPhysician: "Dr. Sarah Amethyst, MD",
      diagnosis: "Essential Hypertension and Type 2 Diabetes Mellitus control. Patient reports stable blood glucose levels but occasional mild morning headaches.",
      medicines: [
        {"name": "Lisinopril", "info": "10mg Tablet", "dosage": "1 Tab", "frequency": "Once Daily"},
        {"name": "Metformin", "info": "500mg Capsule", "dosage": "1 Cap", "frequency": "Twice Daily with meals"},
      ],
      additionalInstructions: [
        "Monitor blood pressure daily in the morning and record readings.",
        "Avoid high-sodium meals and foods with added processed sugar.",
        "Follow up in clinic if systolic blood pressure exceeds 140 mmHg.",
      ],
    ),
    Prescription(
      date: "2023-11-18",
      patientName: "Tahani Al-Jamil",
      medicinesSummary: "Vitamin D3 2000IU, Magnesium 250mg",
      status: "Completed",
      attendingPhysician: "Dr. Sarah Amethyst, MD",
      diagnosis: "Mild Vitamin D insufficiency and general wellness recommendation. Patient reports mild seasonal fatigue.",
      medicines: [
        {"name": "Vitamin D3", "info": "2000IU Softgel", "dosage": "1 Softgel", "frequency": "Once Daily"},
        {"name": "Magnesium Oxide", "info": "250mg Tablet", "dosage": "1 Tab", "frequency": "Every Night"},
      ],
      additionalInstructions: [
        "Take Vitamin D3 preferably with a fat-containing meal for absorption.",
        "Ensure moderate sunlight exposure for 15-20 minutes daily.",
      ],
    ),
    Prescription(
      date: "2023-11-15",
      patientName: "Jason Mendoza",
      medicinesSummary: "Ibuprofen 400mg, Omeprazole 20mg",
      status: "Last entry",
      attendingPhysician: "Dr. Sarah Amethyst, MD",
      diagnosis: "Mild gastric irritation and localized musculoskeletal pain in the right shoulder due to minor sprain.",
      medicines: [
        {"name": "Ibuprofen", "info": "400mg Tablet", "dosage": "1 Tab", "frequency": "Every 8 Hours (PRN)"},
        {"name": "Omeprazole", "info": "20mg Delayed-Release Capsule", "dosage": "1 Cap", "frequency": "Once Daily (30m before breakfast)"},
      ],
      additionalInstructions: [
        "Take Ibuprofen strictly after meals to prevent gastric discomfort.",
        "Apply cold compress to right shoulder for 15 minutes twice daily.",
        "Rest the shoulder; avoid lifting weights or sudden movements.",
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Search + filter logic
    final filtered = _prescriptions.where((prescription) {
      final matchesSearch = prescription.patientName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          prescription.date.contains(_searchQuery) ||
          prescription.medicinesSummary.toLowerCase().contains(_searchQuery.toLowerCase());

      if (!matchesSearch) return false;

      if (_selectedFilter == "PENDING") {
        return prescription.status == "Follow-up Required";
      } else if (_selectedFilter == "CHRONIC") {
        return prescription.patientName == "Chidi Anagonye"; // representative chronic case
      } else if (_selectedFilter == "THIS WEEK") {
        return prescription.date.startsWith("2023-11-2"); // latest items
      }

      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7FC), // Soft pinkish/white matching mockup background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.onSurfaceColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Prescription History",
          style: GoogleFonts.hankenGrotesk(
            fontWeight: FontWeight.bold,
            color: AppTheme.onSurfaceColor,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Input Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1E6F1), // Soft lavender tint search input background
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppTheme.onSurfaceColor,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: "Search patient or date...",
                    hintStyle: GoogleFonts.inter(
                      color: AppTheme.onSurfaceVariant.withOpacity(0.6),
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(Icons.search, color: AppTheme.onSurfaceVariant, size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  ),
                ),
              ),
            ),

            // Horizontal Filter Chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildFilterChip("ALL"),
                    const SizedBox(width: 8),
                    _buildFilterChip("THIS WEEK"),
                    const SizedBox(width: 8),
                    _buildFilterChip("PENDING"),
                    const SizedBox(width: 8),
                    _buildFilterChip("CHRONIC"),
                  ],
                ),
              ),
            ),

            // Recent Records label row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "RECENT RECORDS",
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurfaceVariant,
                      letterSpacing: 1.0,
                    ),
                  ),
                  Text(
                    "SORT BY DATE",
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurfaceVariant,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),

            // Prescription list scroll area
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        "No records found",
                        style: GoogleFonts.inter(color: AppTheme.onSurfaceVariant),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                      physics: const BouncingScrollPhysics(),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        return _buildRecordCard(context, item);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String filter) {
    final isSelected = _selectedFilter == filter;
    final activeBg = const Color(0xFF290A45); // Dark amethyst
    final inactiveBg = const Color(0xFFF1E6F1); // Light lavender
    final activeText = Colors.white;
    final inactiveText = AppTheme.onSurfaceVariant;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = filter;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? activeBg : inactiveBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          filter,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? activeText : inactiveText,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildRecordCard(BuildContext context, Prescription item) {
    // Determine status badge icon and color
    IconData statusIcon = Icons.info_outline;
    Color statusColor = AppTheme.onSurfaceVariant;
    if (item.status == "Refill Available") {
      statusIcon = Icons.history;
      statusColor = AppTheme.primaryColor;
    } else if (item.status == "Follow-up Required") {
      statusIcon = Icons.warning_amber_rounded;
      statusColor = const Color(0xFFC2410C); // dark orange
    } else if (item.status == "Completed") {
      statusIcon = Icons.check_circle_outline;
      statusColor = const Color(0xFF15803D); // dark green
    }

    return Container(
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
                builder: (context) => PrescriptionDetailsScreen(prescription: item),
              ),
            );
          },
          borderRadius: BorderRadius.circular(AppTheme.radius2Xl),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date & Chevron Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.date,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        color: AppTheme.onSurfaceVariant.withOpacity(0.6),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppTheme.outlineColor, size: 20),
                  ],
                ),
                const SizedBox(height: 8),

                // Patient Name
                Text(
                  item.patientName,
                  style: GoogleFonts.hankenGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.onSurfaceColor,
                  ),
                ),
                const SizedBox(height: 6),

                // Medicines Summary
                Text(
                  item.medicinesSummary,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppTheme.onSurfaceVariant.withOpacity(0.85),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),

                // Status & View Details action link
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Status Row
                    Row(
                      children: [
                        Icon(statusIcon, size: 16, color: statusColor),
                        const SizedBox(width: 6),
                        Text(
                          item.status,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),

                    // View Details action link
                    Text(
                      "View Details",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
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
