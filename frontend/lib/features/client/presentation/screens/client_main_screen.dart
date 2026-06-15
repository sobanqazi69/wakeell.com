import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/services/service_locator.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../auth/presentation/cubits/auth_state.dart';
import '../../../booking/data/repositories/booking_repository.dart';
import '../../../booking/presentation/cubits/client_bookings_cubit.dart';
import '../../../booking/presentation/screens/client_bookings_screen.dart';
import 'client_dashboard_screen.dart';
import 'client_chat_tab.dart';

class ClientMainScreen extends StatefulWidget {
  const ClientMainScreen({super.key});

  @override
  State<ClientMainScreen> createState() => _ClientMainScreenState();
}

class _ClientMainScreenState extends State<ClientMainScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.splash, (_) => false);
        }
      },
      child: BlocProvider(
        create: (_) => ClientBookingsCubit(getIt<BookingRepository>())..load(),
        child: Scaffold(
          backgroundColor: AppColors.bg,
          body: IndexedStack(
            index: _index,
            children: const [
              ClientDashboardScreen(),
              ClientChatTab(),
              ClientBookingsScreen(),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.fieldBorder, width: 0.8)),
              boxShadow: [BoxShadow(color: AppColors.navy.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, -4))],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 64,
                child: Row(children: [
                  _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home', index: 0, current: _index, onTap: (i) => setState(() => _index = i)),
                  _NavItem(icon: Icons.chat_bubble_outline_rounded, activeIcon: Icons.chat_bubble_rounded, label: 'Chat', index: 1, current: _index, onTap: (i) => setState(() => _index = i)),
                  _NavItem(icon: Icons.calendar_month_outlined, activeIcon: Icons.calendar_month_rounded, label: 'Bookings', index: 2, current: _index, onTap: (i) => setState(() => _index = i)),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int current;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon, required this.activeIcon, required this.label,
    required this.index, required this.current, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = index == current;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(index),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              active ? activeIcon : icon,
              key: ValueKey(active),
              size: 22,
              color: active ? AppColors.navy : AppColors.textHint,
            ),
          ),
          const SizedBox(height: 3),
          Text(label, style: GoogleFonts.outfit(
            fontSize: 10,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            color: active ? AppColors.navy : AppColors.textHint,
          )),
          const SizedBox(height: 2),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: active ? 16 : 0,
            height: 2,
            decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(1)),
          ),
        ]),
      ),
    );
  }
}
