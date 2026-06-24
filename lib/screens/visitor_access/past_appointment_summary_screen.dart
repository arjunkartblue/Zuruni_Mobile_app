import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/theme.dart';
import '../../state/app_state.dart';
import '../../utils/time_utils.dart';
import '../../widgets/prescription_card.dart';
import '../../widgets/appointment_status_header.dart';
import '../booking_flow/booking_wizard_screen.dart';

class PastAppointmentSummaryScreen extends StatefulWidget {
  final Appointment appointment;

  const PastAppointmentSummaryScreen({super.key, required this.appointment});

  @override
  State<PastAppointmentSummaryScreen> createState() => _PastAppointmentSummaryScreenState();
}

class _PastAppointmentSummaryScreenState extends State<PastAppointmentSummaryScreen> {
  bool _isDownloading = false;

  final List<Map<String, dynamic>> _organizations = [
    {
      "name": "Vantage Medical Group",
      "category": "Healthcare",
      "specialty": "Multispecialty Clinic",
      "distance": "1.2 miles away",
      "rating": "4.8",
      "imageUrl": "https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?auto=format&fit=crop&q=80&w=240",
      "tags": ["GP", "Cardiology"],
      "country": "United States",
      "state": "California",
      "district": "Los Angeles",
      "services": [
        {"name": "General Consultation", "price": 80.0, "duration": "30 min"},
        {"name": "Cardiology Screening", "price": 200.0, "duration": "45 min"}
      ],
      "professionals": [
        {"name": "Dr. Aris Thorne", "role": "General Physician", "rating": "4.9"},
        {"name": "Dr. Clara Mercer", "role": "Cardiologist", "rating": "4.8"}
      ]
    },
    {
      "name": "Sterling Strategy Law",
      "category": "Legal",
      "specialty": "Corporate & Family Law",
      "distance": "0.8 miles away",
      "rating": "4.9",
      "imageUrl": "https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&q=80&w=240",
      "tags": ["Consultation", "Contracts"],
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



  void _handleRebook(BuildContext context, AppState appState) {
    Map<String, dynamic>? matchedOrg;
    for (final org in _organizations) {
      if (org["name"] == widget.appointment.organizationName) {
        matchedOrg = org;
        break;
      }
    }
    matchedOrg ??= _organizations.first;

    final services = matchedOrg["services"] as List;
    Map<String, dynamic>? matchedService;
    for (final service in services) {
      if (service is Map<String, dynamic> && service["name"] == widget.appointment.serviceName) {
        matchedService = service;
        break;
      }
    }
    matchedService ??= services.first as Map<String, dynamic>;

    appState.clearBookingWizard();
    appState.selectedOrg = matchedOrg;
    appState.selectedCategory = matchedOrg["category"];
    appState.selectedService = widget.appointment.serviceName;
    appState.selectedServicePrice = (matchedService["price"] as num).toDouble();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingWizardScreen(
          initialStep: 1,
          preselectedProfessionalName: widget.appointment.professionalName,
        ),
      ),
    );
  }

  Future<void> _openPrescriptionPdf(Appointment appointment) async {
    final urlString = appointment.prescriptionPdfUrl;
    if (urlString == null) return;

    if (urlString.startsWith('http://') || urlString.startsWith('https://')) {
      final Uri url = Uri.parse(urlString);
      try {
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
          return;
        }
      } catch (e) {
        // Fallback to snackbar if launch fails
      }
    }

    // Show mock snackbar for non-http urls or if launch fails
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.primaryColor,
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "PDF viewer will open when connected to the backend. (Mock file: ${appointment.prescriptionName})",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _simulateDownload() {
    setState(() {
      _isDownloading = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  "Prescription downloaded successfully!",
                  style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isCompleted = widget.appointment.status == "Completed";
    final isCancelled = widget.appointment.status == "Cancelled";

    Color statusColor = AppTheme.successColor;
    String statusText = "COMPLETED";
    String statusMessage = "This visit was completed successfully.";

    if (isCancelled) {
      statusColor = AppTheme.errorColor;
      statusText = "CANCELLED";
      statusMessage = "This appointment was cancelled.";
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.onSurfaceColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Visit Summary",
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
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Badge Card
                    AppointmentStatusHeader(
                      statusColor: statusColor,
                      statusText: statusText,
                      statusMessage: statusMessage,
                    ),
                    const SizedBox(height: 20),

                    // Appointment Details Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20.0),
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
                            widget.appointment.category,
                            style: GoogleFonts.hankenGrotesk(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.onSurfaceColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.appointment.organizationName.toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.onSurfaceVariant.withOpacity(0.6),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Divider(color: Color(0xFFF1EBF1), height: 1),
                          const SizedBox(height: 16),

                          // Service Row
                          _buildDetailRow(
                            icon: Icons.assignment_outlined,
                            label: "Service",
                            value: widget.appointment.serviceName,
                          ),
                          const SizedBox(height: 16),

                          // Date & Time Row
                          _buildDetailRow(
                            icon: Icons.calendar_today_outlined,
                            label: "Date & Time",
                            value: AppTheme.formatDate(widget.appointment.date),
                            subvalue: "${widget.appointment.timeSlot} — ${TimeUtils.getEndTimeSlot(widget.appointment.timeSlot)}",
                          ),
                          const SizedBox(height: 16),

                          // Location Row
                          _buildDetailRow(
                            icon: Icons.location_on_outlined,
                            label: "Location",
                            value: widget.appointment.organizationName.contains("Vantage")
                                ? "Building A, Floor 4, Suite 402"
                                : widget.appointment.organizationName.contains("Aesthetic")
                                    ? "Aesthetic Plaza, Level 2, Suite 210"
                                    : "Building A, Floor 4, Suite 402",
                          ),
                          const SizedBox(height: 16),

                          // Professional Row
                          _buildDetailRow(
                            icon: Icons.person_outline,
                            label: "Professional",
                            value: widget.appointment.professionalName,
                            subvalue: "Appointment Reference ID: ${widget.appointment.id}",
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),                     // Prescription Section (Only if completed and prescription is uploaded)
                    if (isCompleted && widget.appointment.prescriptionPdfUrl != null) ...[
                      Text(
                        "Prescriptions",
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.onSurfaceColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      PrescriptionCard(
                        appointment: widget.appointment,
                        isDownloading: _isDownloading,
                        onDownload: _simulateDownload,
                        onViewRx: () => _openPrescriptionPdf(widget.appointment),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            // Rebook Section
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Color(0xFFF1EBF1)),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () => _handleRebook(context, appState),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.refresh, size: 20),
                  label: Text(
                    "Rebook this Service",
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    String? subvalue,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppTheme.onSurfaceVariant.withOpacity(0.7)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurfaceVariant.withOpacity(0.6),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.onSurfaceColor,
                ),
              ),
              if (subvalue != null) ...[
                const SizedBox(height: 2),
                Text(
                  subvalue,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.onSurfaceVariant.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
