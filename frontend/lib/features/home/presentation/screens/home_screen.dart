import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../auth/presentation/cubits/auth_state.dart';
import '../../../admin/presentation/screens/admin_dashboard_screen.dart';
import '../../../client/presentation/screens/client_main_screen.dart';
import '../../../lawyer/presentation/screens/lawyer_main_screen.dart';
import '../../../notifications/presentation/cubits/notifications_cubit.dart';

/// Role-based router — the single `/home` route that delegates
/// to the correct dashboard based on user.role.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load notifications once we know the user is authenticated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<NotificationsCubit>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final user = state is AuthAuthenticated
            ? state.user
            : context.read<AuthCubit>().currentUser;

        switch (user?.role) {
          case 'admin':
            return const AdminDashboardScreen();
          case 'lawyer':
            return const LawyerMainScreen();
          default:
            return const ClientMainScreen();
        }
      },
    );
  }
}
