import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/theme.dart';
import '../../state/app_state.dart';
import 'explore_screen.dart';
import 'my_appointments_screen.dart';
import 'my_prescriptions_screen.dart';
import 'profile_screen.dart';
import 'profile/edit_profile_screen.dart';
import '../auth/login_screen.dart';

class UserNavigationShell extends StatefulWidget {
  const UserNavigationShell({Key? key}) : super(key: key);

  @override
  State<UserNavigationShell> createState() => _UserNavigationShellState();
}

class _UserNavigationShellState extends State<UserNavigationShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const ExploreScreen(),
    const MyAppointmentsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);

    // Custom App Bar
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
            // Open menu drawer
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
      actions: _currentIndex == 2
          ? [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EditProfileScreen()),
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
                    const SnackBar(content: Text("No new notifications")),
                  );
                },
              ),
              GestureDetector(
                onTap: () {
                  if (appState.isLoggedIn) {
                    setState(() {
                      _currentIndex = 2; // Navigate to Profile
                    });
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0, left: 8.0),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: AppTheme.surfaceContainerColor,
                    backgroundImage: appState.isLoggedIn
                        ? const NetworkImage('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=240')
                        : null,
                    child: !appState.isLoggedIn
                        ? const Icon(Icons.person_outline, size: 20, color: AppTheme.onSurfaceColor)
                        : null,
                  ),
                ),
              ),
            ],
    );

    // If visiting a protected tab while logged out, show Login Required page
    Widget activeBody = _screens[_currentIndex];
    if (_currentIndex > 0 && !appState.isLoggedIn) {
      activeBody = _buildLoginRequiredScreen(context);
    }

    return Scaffold(
      appBar: customAppBar,
      body: activeBody,
      drawer: _buildDrawer(context, appState),
      bottomNavigationBar: Container(
        height: 76,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
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
            Expanded(child: _buildNavItem(0, Icons.search_outlined, Icons.search, "Explore")),
            Expanded(child: _buildNavItem(1, Icons.calendar_today_outlined, Icons.calendar_today, "Bookings")),
            Expanded(child: _buildNavItem(2, Icons.person_outline, Icons.person, "Profile")),
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
        margin: const EdgeInsets.symmetric(horizontal: 6),
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

  Widget _buildLoginRequiredScreen(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            boxShadow: AppTheme.ambientShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline,
                  size: 48,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Access Secure Portal",
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                "Manage bookings, facility clearance, digital QR passes, and verify your identity securely.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.onSurfaceVariant,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  child: const Text("LOG IN / REGISTER"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, AppState appState) {
    final isLoggedIn = appState.isLoggedIn;
    final isAccountVerified = appState.verificationStatus == VerificationStatus.verified;

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
          // Custom Header
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
                  Color(0xFF581C87), // Rich purple
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
                    // Profile Avatar (Rounded square)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: isLoggedIn
                            ? Image.network(
                                'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=240',
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 56,
                                height: 56,
                                color: Colors.white.withOpacity(0.2),
                                child: const Icon(
                                  Icons.person_outline,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                      ),
                    ),
                    // Verification / Status Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isLoggedIn
                            ? (isAccountVerified ? const Color(0xFFD1FAE5) : const Color(0xFFFEF3C7))
                            : Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isLoggedIn ? (isAccountVerified ? "VERIFIED" : "PENDING") : "GUEST",
                        style: TextStyle(
                          color: isLoggedIn
                              ? (isAccountVerified ? const Color(0xFF059669) : const Color(0xFFD97706))
                              : Colors.white,
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
                  isLoggedIn ? appState.userName : "Guest Visitor",
                  style: GoogleFonts.hankenGrotesk(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isLoggedIn ? appState.userEmail : "Login to access full features",
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // Drawer items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              children: [
                _buildDrawerItem(
                  context: context,
                  icon: Icons.search_outlined,
                  activeIcon: Icons.search,
                  title: 'Explore',
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
                  context: context,
                  icon: Icons.calendar_today_outlined,
                  activeIcon: Icons.calendar_today,
                  title: 'My Bookings',
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
                  context: context,
                  icon: Icons.description_outlined,
                  activeIcon: Icons.description,
                  title: 'My Prescriptions',
                  isSelected: false,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MyPrescriptionsScreen()),
                    );
                  },
                ),
                const SizedBox(height: 8),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  title: 'Profile',
                  isSelected: _currentIndex == 2,
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _currentIndex = 2;
                    });
                  },
                ),
                if (isLoggedIn) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    child: Divider(color: AppTheme.outlineVariantColor.withOpacity(0.3)),
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.swap_horiz_outlined,
                    activeIcon: Icons.swap_horiz,
                    title: 'Switch to Staff Portal',
                    isSelected: false,
                    onTap: () {
                      Navigator.pop(context);
                      appState.setRole(UserRole.staff);
                    },
                  ),
                ],
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  child: Divider(color: AppTheme.outlineVariantColor.withOpacity(0.3)),
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.help_outline,
                  activeIcon: Icons.help,
                  title: 'Help & FAQ',
                  isSelected: false,
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Help & FAQ center loaded")),
                    );
                  },
                ),
                const SizedBox(height: 8),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.shield_outlined,
                  activeIcon: Icons.shield,
                  title: 'Privacy & Terms',
                  isSelected: false,
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Privacy Policy & Terms loaded")),
                    );
                  },
                ),
              ],
            ),
          ),
          
          // Drawer Footer
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 20,
              left: 20,
              right: 20,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: isLoggedIn
                  ? OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        appState.logout();
                        setState(() {
                          _currentIndex = 0;
                        });
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
                    )
                  : ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.login, size: 18),
                      label: const Text(
                        'Log In',
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
    required BuildContext context,
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
