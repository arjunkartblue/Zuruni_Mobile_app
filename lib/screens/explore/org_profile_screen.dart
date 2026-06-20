import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/theme.dart';
import '../../state/app_state.dart';
import '../booking_flow/booking_wizard_screen.dart';
import '../auth/login_screen.dart';

class OrgProfileScreen extends StatelessWidget {
  final Map<String, dynamic> org;

  const OrgProfileScreen({Key? key, required this.org}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = Provider.of<AppState>(context, listen: false);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Collapsible Image Header
          SliverAppBar(
            expandedHeight: 220,
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
              background: Image.network(
                org["imageUrl"],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppTheme.primaryColor,
                    child: const Icon(Icons.business, size: 64, color: Colors.white),
                  );
                },
              ),
            ),
          ),
          
          // Org details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + Verified badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          org["name"],
                          style: GoogleFonts.hankenGrotesk(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.onSurfaceColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.successColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.verified, color: AppTheme.successColor, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              "Verified",
                              style: GoogleFonts.inter(
                                color: AppTheme.successColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 6),
                  
                  // Category / Rating / Distance
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainerColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          org["category"],
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        "${org["rating"]} Ratings",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.onSurfaceColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.location_on_outlined, color: AppTheme.outlineColor, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        org["distance"],
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Description
                  Text(
                    "About",
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Zuruni verified facility offering top-tier services. Featuring digital queue pass registration, instant parking bay assignments, and smart gate access integration for visitors.",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppTheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Professionals
                  Text(
                    "Professionals Available",
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 90,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: (org["professionals"] as List).length,
                      itemBuilder: (context, index) {
                        final prof = org["professionals"][index];
                        return Container(
                          width: 220,
                          margin: const EdgeInsets.only(right: 12.0),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                            border: Border.all(color: AppTheme.outlineVariantColor),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: AppTheme.surfaceContainerColor,
                                child: Text(
                                  prof["name"][0] + prof["name"].split(" ")[1][0],
                                  style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      prof["name"],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.onSurfaceColor,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      prof["role"],
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.onSurfaceVariant,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Services List Title
                  Text(
                    "Services Offered",
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          
          // Services List Items
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final service = org["services"][index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                    border: Border.all(color: AppTheme.outlineVariantColor),
                    boxShadow: AppTheme.ambientShadow,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left: details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service["name"],
                                style: GoogleFonts.hankenGrotesk(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.onSurfaceColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.access_time, size: 14, color: AppTheme.outlineColor),
                                  const SizedBox(width: 4),
                                  Text(
                                    service["duration"],
                                    style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant),
                                  ),
                                  const SizedBox(width: 16),
                                  const Icon(Icons.payments_outlined, size: 14, color: AppTheme.outlineColor),
                                  const SizedBox(width: 4),
                                  Text(
                                    "\$${service["price"].toStringAsFixed(2)}",
                                    style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        // Right: Book Button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            minimumSize: Size.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                            ),
                          ),
                          onPressed: () {
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
                          },
                          child: const Text("Book"),
                        ),
                      ],
                    ),
                  ),
                );
              },
              childCount: (org["services"] as List).length,
            ),
          ),
          
          const SliverToBoxAdapter(
            child: SizedBox(height: 40),
          )
        ],
      ),
    );
  }
}
