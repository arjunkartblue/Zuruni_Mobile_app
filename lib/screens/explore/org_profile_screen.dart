import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/theme.dart';
import '../../state/app_state.dart';
import '../booking_flow/booking_wizard_screen.dart';
import '../auth/login_screen.dart';

class OrgProfileScreen extends StatelessWidget {
  final Map<String, dynamic> org;

  const OrgProfileScreen({super.key, required this.org});

  String _getOrgAddress(Map<String, dynamic> org) {
    final name = org["name"].toLowerCase();
    final cat = org["category"].toLowerCase();
    if (cat.contains("health") || name.contains("medical") || name.contains("dental") || name.contains("hospital")) {
      return "1224 Medical District Blvd, Metro City";
    } else if (cat.contains("legal") || name.contains("law") || name.contains("associates")) {
      return "88 Law Chambers Suite 5A, Metro City";
    } else if (cat.contains("beauty") || name.contains("spa") || name.contains("aesthetic")) {
      return "44 Glamour Way Plaza, Metro City";
    }
    return "100 Corporate Drive Suite 101, Metro City";
  }

  List<Map<String, dynamic>> _getOrgSpecialties(Map<String, dynamic> org) {
    final name = org["name"].toLowerCase();
    final cat = org["category"].toLowerCase();
    
    if (cat.contains("health") || name.contains("medical") || name.contains("dental") || name.contains("hospital")) {
      return [
        {"name": "Cardiology", "icon": Icons.favorite_border},
        {"name": "Neurology", "icon": Icons.psychology_outlined},
        {"name": "Urgent Care", "icon": Icons.flash_on_outlined},
        {"name": "Radiology", "icon": Icons.document_scanner_outlined},
      ];
    } else if (cat.contains("legal") || name.contains("law") || name.contains("associates")) {
      return [
        {"name": "Corporate Law", "icon": Icons.business_outlined},
        {"name": "IP Protection", "icon": Icons.gavel_outlined},
        {"name": "Tax Advisory", "icon": Icons.attach_money_outlined},
        {"name": "Litigation", "icon": Icons.security_outlined},
      ];
    } else if (cat.contains("beauty") || name.contains("spa") || name.contains("aesthetic")) {
      return [
        {"name": "Facial Spa", "icon": Icons.face_outlined},
        {"name": "Laser Skincare", "icon": Icons.spa_outlined},
        {"name": "Hair Therapy", "icon": Icons.content_cut_outlined},
        {"name": "Aromatherapy", "icon": Icons.air_outlined},
      ];
    }
    return [
      {"name": "Consulting", "icon": Icons.work_outline},
      {"name": "Strategy", "icon": Icons.analytics_outlined},
      {"name": "Auditing", "icon": Icons.shield_outlined},
      {"name": "Advisory", "icon": Icons.lightbulb_outline},
    ];
  }

  String _getOrgDescription(Map<String, dynamic> org) {
    final name = org["name"];
    final cat = org["category"];
    
    if (cat == "Healthcare" || name.toLowerCase().contains("medical") || name.toLowerCase().contains("dental")) {
      return "$name is a premier medical institution dedicated to providing world-class healthcare with a patient-first philosophy. Our facility features state-of-the-art diagnostic technology and is staffed by a multidisciplinary team of board-certified specialists. For over 40 years, we have served as a cornerstone of the community, pioneering research-backed treatments.";
    } else if (cat == "Legal" || name.toLowerCase().contains("legal") || name.toLowerCase().contains("associates")) {
      return "$name is a leading legal consultancy firm specializing in corporate governance, intellectual property protection, and commercial dispute resolution. With over 25 years of expert counsel experience, our attorneys are committed to defending your business interests, offering custom-tailored representation and advice.";
    } else if (cat == "Beauty" || name.toLowerCase().contains("spa") || name.toLowerCase().contains("aesthetic")) {
      return "$name is an award-winning beauty and wellness sanctuary designed to restore harmony to your body, mind, and spirit. Combining advanced medical aesthetics with holistic therapies, our certified practitioners provide custom facials, laser treatments, and massage therapies in a serene, luxurious setting.";
    }
    return "$name is a global consulting firm helping enterprise leaders navigate market volatility, optimize operational frameworks, and accelerate digital transformation. Our strategists deliver rigorous, data-driven solutions that fuel sustainable business growth and long-term security.";
  }

  String _getServiceDescription(String serviceName) {
    final name = serviceName.toLowerCase();
    if (name.contains("consultation")) {
      return "Initial health assessment and diagnostic overview.";
    } else if (name.contains("follow-up")) {
      return "Review of treatment progress and test results.";
    } else if (name.contains("diagnostic") || name.contains("lab") || name.contains("search")) {
      return "Advanced screening, imaging, and full laboratory panel.";
    } else if (name.contains("teeth") || name.contains("cleaning")) {
      return "Professional oral hygiene checkup and whitening treatment.";
    } else if (name.contains("root canal") || name.contains("treatment")) {
      return "Advanced dental surgery and pain relief treatment.";
    } else if (name.contains("business") || name.contains("tax")) {
      return "Corporate strategy audit and compliance consultation.";
    } else if (name.contains("estate") || name.contains("wealth")) {
      return "Estate planning review and wealth advisory.";
    } else if (name.contains("facial") || name.contains("laser")) {
      return "Premium aesthetic treatment and skin restoration session.";
    }
    return "Specialist advisory consultation and detailed action plan.";
  }

  IconData _getServiceIcon(String serviceName, String category) {
    final name = serviceName.toLowerCase();
    final cat = category.toLowerCase();
    if (cat.contains("health") || cat.contains("medical") || cat.contains("dental") || cat.contains("hospital")) {
      if (name.contains("consultation")) {
        return Icons.local_hospital_outlined;
      } else if (name.contains("follow-up") || name.contains("follow up")) {
        return Icons.sync_outlined;
      } else if (name.contains("diagnostic") || name.contains("lab") || name.contains("screening")) {
        return Icons.analytics_outlined;
      }
      return Icons.medical_services_outlined;
    } else if (cat.contains("legal") || cat.contains("law")) {
      if (name.contains("advice") || name.contains("consultation")) {
        return Icons.gavel_outlined;
      }
      return Icons.description_outlined;
    } else if (cat.contains("beauty") || cat.contains("spa") || cat.contains("aesthetic")) {
      if (name.contains("facial") || name.contains("skincare")) {
        return Icons.face_outlined;
      }
      return Icons.spa_outlined;
    }
    return Icons.business_center_outlined;
  }

  IconData _getWhyChooseUsWatermark(String category) {
    final cat = category.toLowerCase();
    if (cat.contains("health") || cat.contains("medical") || cat.contains("dental") || cat.contains("hospital")) {
      return Icons.local_hospital;
    } else if (cat.contains("legal") || cat.contains("law")) {
      return Icons.balance;
    } else if (cat.contains("beauty") || cat.contains("spa") || cat.contains("aesthetic")) {
      return Icons.spa;
    }
    return Icons.insights;
  }

  List<String> _getWhyChooseUsPoints(String category) {
    if (category == "Healthcare") {
      return [
        "24/7 Professional Support",
        "Direct Insurance Billing",
        "Multi-lingual Staff",
        "Accredited by National Health Board",
      ];
    } else if (category == "Legal") {
      return [
        "Confidential & Secure Counsel",
        "Direct Retainer billing option",
        "Experienced Practice Attorneys",
        "Accredited by State Bar Council",
      ];
    } else if (category == "Beauty") {
      return [
        "Certified Medical Estheticians",
        "Premium FDA-approved Products",
        "Customized Skincare Programs",
        "Calming & Hygienic Sanctuary",
      ];
    }
    return [
      "Rigorous Analytical Frameworks",
      "Confidential Advisory Support",
      "Industry-Leading Consultants",
      "Results-Driven Business Value",
    ];
  }

  Widget _buildSpecialtyTag(Map<String, dynamic> spec) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF5FF), // light purple
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFF3E8FF)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(spec["icon"] as IconData, size: 16, color: AppTheme.primaryColor),
          const SizedBox(width: 8),
          Text(
            spec["name"] as String,
            style: GoogleFonts.hankenGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  void _bookService(BuildContext context, AppState appState, Map<String, dynamic> service) {
    if (!appState.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Authentication required to complete booking")),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
      return;
    }
    
    // Initialize Wizard State
    appState.clearBookingWizard();
    appState.selectedOrg = org;
    appState.selectedService = service["name"];
    appState.selectedServicePrice = service["price"];
    appState.selectedCategory = org["category"];
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BookingWizardScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final isTopRated = double.parse(org["rating"]) >= 4.8;
    final address = _getOrgAddress(org);
    final description = _getOrgDescription(org);
    final specialties = _getOrgSpecialties(org);
    final chooseUsPoints = _getWhyChooseUsPoints(org["category"]);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Collapsible Image Header
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                backgroundColor: AppTheme.primaryColor,
                elevation: 0,
                leading: CircleAvatar(
                  backgroundColor: Colors.black26,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        org["imageUrl"],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppTheme.primaryColor,
                            child: const Icon(Icons.business, size: 64, color: Colors.white),
                          );
                        },
                      ),
                      // Dark gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                      // Overlay Info
                      Positioned(
                        bottom: 16,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withOpacity(0.85),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    isTopRated ? "TOP RATED" : "POPULAR",
                                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: Colors.white24),
                                  ),
                                  child: const Text(
                                    "OPEN NOW",
                                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              org["name"],
                              style: GoogleFonts.hankenGrotesk(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.location_on, color: Colors.white, size: 14),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    address,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content Body
              SliverList(
                delegate: SliverChildListDelegate([
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // About Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFF1EBF1)),
                            boxShadow: AppTheme.ambientShadow,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "About the Facility",
                                style: GoogleFonts.hankenGrotesk(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                description,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.onSurfaceVariant.withOpacity(0.85),
                                  height: 1.45,
                                ),
                              ),
                              const SizedBox(height: 18),
                              
                              // Specialties tags grid in 2-column layout matching mockup
                              Column(
                                children: [
                                  for (int i = 0; i < specialties.length; i += 2)
                                    Padding(
                                      padding: EdgeInsets.only(bottom: i + 2 < specialties.length ? 8.0 : 0.0),
                                      child: Row(
                                        children: [
                                          Expanded(child: _buildSpecialtyTag(specialties[i])),
                                          const SizedBox(width: 8),
                                          if (i + 1 < specialties.length)
                                            Expanded(child: _buildSpecialtyTag(specialties[i + 1]))
                                          else
                                            const Expanded(child: SizedBox()),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Available Services header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Available Services",
                              style: GoogleFonts.hankenGrotesk(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.onSurfaceColor,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  "Filter",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor.withOpacity(0.8),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(Icons.tune, size: 14, color: AppTheme.primaryColor.withOpacity(0.8)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // List of Services Offered
                        ...List.generate((org["services"] as List).length, (index) {
                          final service = org["services"][index];
                          final servIcon = _getServiceIcon(service["name"], org["category"]);
                          final servBg = const Color(0xFFFAF5FF); // light purple background
                          final servColor = AppTheme.primaryColor; // deep amethyst

                          // Format duration to match mockup (e.g. 30 MIN -> 30 MINS)
                          String durationText = service["duration"].toString().toUpperCase();
                          if (durationText.contains("MIN") && !durationText.contains("MINS")) {
                            durationText = durationText.replaceAll("MIN", "MINS");
                          }

                          return GestureDetector(
                            onTap: () => _bookService(context, appState, service),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12.0),
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFF1EBF1)),
                                boxShadow: AppTheme.ambientShadow,
                              ),
                              child: Row(
                                children: [
                                  // Styled Icon Box
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: servBg,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFFF3E8FF)),
                                    ),
                                    child: Icon(servIcon, color: servColor, size: 20),
                                  ),
                                  const SizedBox(width: 14),

                                  // Service Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          service["name"],
                                          style: GoogleFonts.hankenGrotesk(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.onSurfaceColor,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _getServiceDescription(service["name"]),
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            color: AppTheme.onSurfaceVariant.withOpacity(0.7),
                                            height: 1.3,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(Icons.access_time, size: 12, color: AppTheme.outlineColor),
                                            const SizedBox(width: 4),
                                            Text(
                                              durationText,
                                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.outlineColor),
                                            ),
                                            const SizedBox(width: 16),
                                            const Icon(Icons.payments_outlined, size: 12, color: AppTheme.outlineColor),
                                            const SizedBox(width: 4),
                                            Text(
                                              "\$${service["price"].toStringAsFixed(2)}",
                                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.outlineColor),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // Circular Chevron button
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: const Color(0xFFF1EBF1)),
                                    ),
                                    child: const Icon(Icons.chevron_right, size: 18, color: AppTheme.outlineColor),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 16),

                        // Why Choose Us
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Stack(
                            children: [
                              // Watermark cross/icon matching the category
                              Positioned(
                                bottom: -20,
                                right: -20,
                                child: Icon(
                                  _getWhyChooseUsWatermark(org["category"]),
                                  color: Colors.white.withOpacity(0.08),
                                  size: 120,
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Why choose us?",
                                    style: GoogleFonts.hankenGrotesk(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  ...chooseUsPoints.map((point) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.only(top: 2.0),
                                          child: Icon(Icons.check_circle_outline, color: Colors.white, size: 14),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            point,
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(0.9),
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              height: 1.3,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Location & Contact Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFF1EBF1)),
                            boxShadow: AppTheme.ambientShadow,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "LOCATION & CONTACT",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.onSurfaceVariant.withOpacity(0.6),
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              // Stylized Mock Map preview
                              Container(
                                height: 140,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8ECE9), // Soft map land color
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: CustomPaint(
                                          painter: MockMapPainter(),
                                        ),
                                      ),
                                      // Styled locator pin marker
                                      Center(
                                        child: Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryColor,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white, width: 3),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.15),
                                                blurRadius: 8,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.location_on,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              // Contact phone & email
                              Row(
                                children: [
                                  const Icon(Icons.phone_outlined, size: 16, color: AppTheme.primaryColor),
                                  const SizedBox(width: 10),
                                  const Text(
                                    "+1 (555) 234-9000",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.onSurfaceColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Icon(Icons.mail_outline_rounded, size: 16, color: AppTheme.primaryColor),
                                  const SizedBox(width: 10),
                                  Text(
                                    "contact@${org["name"].toLowerCase().replaceAll(" ", "").replaceAll("&", "")}.com",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.onSurfaceColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 100), // spacing for sticky bottom button
                      ],
                    ),
                  ),
                ]),
              ),
            ],
          ),

          // Sticky bottom book button
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Book the first service by default
                  final firstService = (org["services"] as List)[0];
                  _bookService(context, appState, firstService);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.calendar_month_outlined, color: Colors.white, size: 18),
                label: const Text("Book Appointment", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MockMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Draw River (blue curved path)
    paint.color = const Color(0xFFBFDBFE);
    final riverPath = Path()
      ..moveTo(0, size.height * 0.25)
      ..quadraticBezierTo(size.width * 0.35, size.height * 0.15, size.width * 0.5, size.height * 0.5)
      ..quadraticBezierTo(size.width * 0.65, size.height * 0.85, size.width, size.height * 0.75);
    
    final riverStrokePaint = Paint()
      ..color = const Color(0xFFBFDBFE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(riverPath, riverStrokePaint);

    // Draw a Green Park (soft green)
    paint.color = const Color(0xFFDCFCE7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.08, size.height * 0.55, size.width * 0.3, size.height * 0.35),
        const Radius.circular(12),
      ),
      paint,
    );
    
    // Draw another Green Park
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.68, size.height * 0.08, size.width * 0.25, size.height * 0.32),
        const Radius.circular(12),
      ),
      paint,
    );
    
    // Draw Roads (white paths)
    final roadPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    
    // Road 1 (Horizontal-ish)
    final roadPath1 = Path()
      ..moveTo(0, size.height * 0.35)
      ..lineTo(size.width, size.height * 0.45);
    canvas.drawPath(roadPath1, roadPaint);
    
    // Road 2 (Vertical-ish)
    final roadPath2 = Path()
      ..moveTo(size.width * 0.45, 0)
      ..lineTo(size.width * 0.48, size.height);
    canvas.drawPath(roadPath2, roadPaint);

    // Road 3 (Diagonal)
    final roadPath3 = Path()
      ..moveTo(size.width * 0.15, 0)
      ..lineTo(size.width * 0.85, size.height);
    canvas.drawPath(roadPath3, roadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
