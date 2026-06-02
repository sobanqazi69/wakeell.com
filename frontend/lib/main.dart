import 'package:flutter/material.dart';
import 'config/theme/app_theme.dart';
import 'config/routes/app_routes.dart';
import 'features/auth/presentation/screens/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WakeellApp());
}

class WakeellApp extends StatelessWidget {
  const WakeellApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wakeell',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      initialRoute: AppRoutes.login,
      routes: {
        AppRoutes.login: (_) => const LoginScreen(),
      },
    );
  }
}
