import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/theme.dart';
import 'state/app_state.dart';
import 'screens/main_navigation_shell.dart';
import 'screens/auth/login_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: const BookWellApp(),
    ),
  );
}

class BookWellApp extends StatelessWidget {
  const BookWellApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return MaterialApp(
          key: ValueKey(appState.isLoggedIn),
          title: 'BookWell Mobile',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: appState.isLoggedIn ? const MainNavigationShell() : const LoginScreen(),
        );
      },
    );
  }
}
