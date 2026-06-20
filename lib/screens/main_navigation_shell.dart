import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';
import '../state/app_state.dart';
import 'explore_screen.dart';
import 'my_appointments_screen.dart';
import 'profile_screen.dart';
import 'auth/login_screen.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({Key? key}) : super(key: key);

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
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
      title: Text(
        'BookWell',
        style: GoogleFonts.hankenGrotesk(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
      elevation: 0.5,
      backgroundColor: AppTheme.surfaceColor,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: AppTheme.onSurfaceColor),
        onPressed: () {
          // Open menu drawer
          Scaffold.of(context).openDrawer();
        },
      ),
      actions: [
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
                  ? const NetworkImage('https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=120')
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
        height: AppTheme.bottomNavHeight,
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.surfaceVariant,
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          elevation: 0,
          backgroundColor: Colors.transparent,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: AppTheme.onSurfaceVariant,
          selectedLabelStyle: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
          unselectedLabelStyle: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined),
              activeIcon: Icon(Icons.search),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              label: 'Bookings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
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
    return Drawer(
      backgroundColor: AppTheme.backgroundColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: AppTheme.primaryColor,
            ),
            accountName: Text(
              appState.isLoggedIn ? appState.userName : "Guest Visitor",
              style: GoogleFonts.hankenGrotesk(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            accountEmail: Text(
              appState.isLoggedIn ? appState.userEmail : "Login to access full features",
              style: GoogleFonts.inter(
                fontSize: 14,
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: AppTheme.surfaceContainerColor,
              backgroundImage: appState.isLoggedIn
                  ? const NetworkImage('https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=120')
                  : null,
              child: !appState.isLoggedIn
                  ? const Icon(Icons.person_outline, size: 36, color: AppTheme.primaryColor)
                  : null,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.search, color: AppTheme.primaryColor),
            title: const Text('Explore & Search'),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _currentIndex = 0;
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today, color: AppTheme.primaryColor),
            title: const Text('My Bookings'),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _currentIndex = 1;
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.badge_outlined, color: AppTheme.primaryColor),
            title: const Text('Identity Pass'),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _currentIndex = 2;
              });
            },
          ),
          const Divider(),
          if (appState.isLoggedIn)
            ListTile(
              leading: const Icon(Icons.logout, color: AppTheme.errorColor),
              title: const Text('Log Out', style: TextStyle(color: AppTheme.errorColor)),
              onTap: () {
                Navigator.pop(context);
                appState.logout();
                setState(() {
                  _currentIndex = 0;
                });
              },
            )
          else
            ListTile(
              leading: const Icon(Icons.login, color: AppTheme.primaryColor),
              title: const Text('Log In'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            ),
        ],
      ),
    );
  }
}
