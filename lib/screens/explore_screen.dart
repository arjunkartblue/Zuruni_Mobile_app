import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';
import '../state/app_state.dart';
import 'explore/org_profile_screen.dart';
import 'visitor_access/operational_dashboard_screen.dart';
import 'auth/login_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String _selectedCategory = "Healthcare";

  final List<String> _categories = [
    "Healthcare",
    "Legal",
    "Consulting",
    "Beauty",
    "Fitness",
    "Education",
  ];

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

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);

    // Filter organizations by category
    final filteredOrgs = _organizations
        .where((org) => org["category"] == _selectedCategory)
        .toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                boxShadow: AppTheme.ambientShadow,
              ),
              child: TextFormField(
                decoration: const InputDecoration(
                  hintText: "Search services, professionals, or locations...",
                  prefixIcon: Icon(Icons.search, color: AppTheme.outlineColor),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
          ),

          // Guest Sign In Prompt Card
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

          // Upcoming Appointments (If logged in)
          if (appState.isLoggedIn) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Upcoming Appointments",
                    style: theme.textTheme.headlineSmall,
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
              height: 140,
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
                                builder: (context) => OperationalDashboardScreen(appointment: appointment),
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
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
                                      ),
                                    ],
                                  ),
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
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    size: 14,
                                    color: isVerified ? Colors.white70 : AppTheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "${appointment.date.month}/${appointment.date.day}/${appointment.date.year}",
                                    style: TextStyle(
                                      color: isVerified ? Colors.white70 : AppTheme.onSurfaceVariant,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
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
                              )
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
                Text(
                  "Recommended Near You",
                  style: theme.textTheme.headlineSmall,
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {},
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
    );
  }
}
