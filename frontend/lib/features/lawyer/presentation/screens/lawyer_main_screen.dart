import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/network/socket_service.dart';
import '../../../../core/services/service_locator.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../booking/data/repositories/booking_repository.dart';
import '../../../booking/presentation/cubits/lawyer_bookings_cubit.dart';
import '../../../chat/presentation/cubits/chat_unread_cubit.dart';
import 'lawyer_home_tab.dart';
import 'lawyer_bookings_tab.dart';
import 'lawyer_chat_tab.dart';
import 'lawyer_profile_tab.dart';

class LawyerMainScreen extends StatefulWidget {
  const LawyerMainScreen({super.key});

  @override
  State<LawyerMainScreen> createState() => _LawyerMainScreenState();
}

class _LawyerMainScreenState extends State<LawyerMainScreen> {
  int _index = 0;

  void _switchTab(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LawyerBookingsCubit(getIt<BookingRepository>())..load()),
        BlocProvider(create: (ctx) => ChatUnreadCubit(
          getIt<SocketService>(),
          ctx.read<AuthCubit>().currentUser?.id ?? 0,
        )),
      ],
      child: Scaffold(
          backgroundColor: AppColors.bg,
          body: IndexedStack(
            index: _index,
            children: [
              LawyerHomeTab(onNavigate: _switchTab),
              const LawyerBookingsTab(),
              const LawyerChatTab(),
              const LawyerProfileTab(),
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
                  _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home', index: 0, currentIndex: _index, onTap: _switchTab),
                  _NavItem(icon: Icons.calendar_month_outlined, activeIcon: Icons.calendar_month_rounded, label: 'Bookings', index: 1, currentIndex: _index, onTap: _switchTab),
                  _NavItem(icon: Icons.chat_bubble_outline_rounded, activeIcon: Icons.chat_bubble_rounded, label: 'Chat', index: 2, currentIndex: _index, onTap: _switchTab),
                  _NavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profile', index: 3, currentIndex: _index, onTap: _switchTab),
                ]),
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
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon, required this.activeIcon, required this.label,
    required this.index, required this.currentIndex, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = index == currentIndex;
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
