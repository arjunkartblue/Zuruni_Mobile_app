import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/theme.dart';
import '../../state/app_state.dart';
import 'staff_dashboard_screen.dart';
import 'live_queue_screen.dart';
import 'staff_booking_screen.dart';
import 'staff_profile_screen.dart';
import 'staff_edit_profile_screen.dart';
import 'audit_log_screen.dart';

class StaffNavigationShell extends StatefulWidget {
  const StaffNavigationShell({Key? key}) : super(key: key);

  @override
  State<StaffNavigationShell> createState() => _StaffNavigationShellState();
}

class _StaffNavigationShellState extends State<StaffNavigationShell> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      StaffDashboardScreen(onViewAllApprovals: (index) {
        setState(() {
          _currentIndex = index;
        });
      }),
      const StaffBookingScreen(),
      const LiveQueueScreen(),
      const StaffProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);

    // Custom App Bar for Staff Portal
    final AppBar customAppBar = AppBar(
      title: SvgPicture.asset(
        'assets/images/zuruni_logo.svg',
        height: 24,
      ),
      elevation: 0.5,
      backgroundColor: AppTheme.surfaceColor,
      surfaceTintColor: Colors.transparent,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: AppTheme.onSurfaceColor),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
      actions: _currentIndex == 3
          ? [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const StaffEditProfileScreen()),
                  );
                },
                child: const Text(
                  "Edit",
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ]
          : [
              IconButton(
                icon: const Icon(Icons.notifications_none_outlined, color: AppTheme.onSurfaceColor),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("No new staff notifications")),
                  );
                },
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _currentIndex = 3; // Navigate to Profile tab
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0, left: 8.0),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: AppTheme.surfaceContainerColor,
                    backgroundImage: const NetworkImage(
                      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=240',
                    ),
                  ),
                ),
              ),
            ],
    );

    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      appBar: customAppBar,
      drawer: _buildStaffDrawer(context, appState),
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        height: 76,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.outlineVariant.withOpacity(0.5),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: _buildNavItem(0, Icons.dashboard_outlined, Icons.dashboard, "Dashboard")),
            Expanded(child: _buildNavItem(1, Icons.book_online_outlined, Icons.book_online, "Booking")),
            Expanded(child: _buildNavItem(2, Icons.calendar_month_outlined, Icons.calendar_month, "Scheduling")),
            Expanded(child: _buildNavItem(3, Icons.person_outline, Icons.person, "Profile")),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData outlineIcon, IconData solidIcon, String label) {
    final isSelected = _currentIndex == index;
    final activeBgColor = const Color(0xFF290A45); // Dark Amethyst primary container
    final activeTextColor = const Color(0xFFFAF1F9); // Light text color inside dark background

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? activeBgColor : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? solidIcon : outlineIcon,
              color: isSelected ? Colors.white : AppTheme.onSurfaceVariant.withOpacity(0.6),
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? activeTextColor : AppTheme.onSurfaceVariant.withOpacity(0.6),
                letterSpacing: -0.1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffDrawer(BuildContext context, AppState appState) {
    return Drawer(
      backgroundColor: AppTheme.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 24,
              bottom: 24,
              left: 24,
              right: 24,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryColor,
                  Color(0xFF290A45),
                ],
              ),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(32),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=240',
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1FAE5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "STAFF",
                        style: TextStyle(
                          color: Color(0xFF059669),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  appState.userName,
                  style: GoogleFonts.hankenGrotesk(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  appState.userEmail,
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          
          // Drawer Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              children: [
                _buildDrawerItem(
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard,
                  title: 'Dashboard',
                  isSelected: _currentIndex == 0,
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _currentIndex = 0;
                    });
                  },
                ),
                const SizedBox(height: 8),
                _buildDrawerItem(
                  icon: Icons.book_online_outlined,
                  activeIcon: Icons.book_online,
                  title: 'Booking',
                  isSelected: _currentIndex == 1,
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _currentIndex = 1;
                    });
                  },
                ),
                const SizedBox(height: 8),
                _buildDrawerItem(
                  icon: Icons.calendar_month_outlined,
                  activeIcon: Icons.calendar_month,
                  title: 'Scheduling',
                  isSelected: _currentIndex == 2,
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _currentIndex = 2;
                    });
                  },
                ),
                const SizedBox(height: 8),
                _buildDrawerItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  title: 'Profile',
                  isSelected: _currentIndex == 3,
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _currentIndex = 3;
                    });
                  },
                ),
                const SizedBox(height: 8),
                _buildDrawerItem(
                  icon: Icons.history_toggle_off_outlined,
                  activeIcon: Icons.history_toggle_off,
                  title: 'Audit Log',
                  isSelected: false,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AuditLogScreen()),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  child: Divider(color: AppTheme.outlineVariantColor.withOpacity(0.3)),
                ),
                _buildDrawerItem(
                  icon: Icons.swap_horiz_outlined,
                  activeIcon: Icons.swap_horiz,
                  title: 'Switch to Visitor Portal',
                  isSelected: false,
                  onTap: () {
                    Navigator.pop(context);
                    appState.setRole(UserRole.visitor);
                  },
                ),
              ],
            ),
          ),

          // Log Out
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 20,
              left: 20,
              right: 20,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  appState.logout();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.errorColor,
                  side: const BorderSide(color: AppTheme.errorColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.logout, size: 18),
                label: const Text(
                  'Log Out',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required IconData activeIcon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.surfaceContainerColor : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          isSelected ? activeIcon : icon,
          color: isSelected ? AppTheme.primaryColor : AppTheme.onSurfaceVariant,
        ),
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? AppTheme.primaryColor : AppTheme.onSurfaceColor,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: onTap,
      ),
    );
  }
}
