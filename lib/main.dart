import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/theme.dart';
import 'state/app_state.dart';
import 'screens/user/user_navigation_shell.dart';
import 'screens/staff/staff_navigation_shell.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: const ZuruniApp(),
    ),
  );
}

class ZuruniApp extends StatelessWidget {
  const ZuruniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return MaterialApp(
          key: ValueKey('${appState.isLoggedIn}_${appState.isGuest}_${appState.currentRole}'),
          title: 'Zuruni Mobile',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: (appState.isLoggedIn || appState.isGuest)
              ? (appState.currentRole == UserRole.staff
                  ? const StaffNavigationShell()
                  : const UserNavigationShell())
              : const SplashScreen(),
        );
      },
    );
  }
}
