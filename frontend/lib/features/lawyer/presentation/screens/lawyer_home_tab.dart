import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../auth/presentation/cubits/auth_state.dart';
import '../../../notifications/presentation/cubits/notifications_cubit.dart';
import '../../../notifications/presentation/cubits/notifications_state.dart';
import '../../../booking/presentation/cubits/lawyer_bookings_cubit.dart';
import '../../../booking/presentation/cubits/lawyer_bookings_state.dart';
import '../../../booking/data/models/booking_model.dart';

class LawyerHomeTab extends StatelessWidget {
  final void Function(int) onNavigate;
  const LawyerHomeTab({super.key, required this.onNavigate});

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts.isNotEmpty && parts[0].isNotEmpty) return parts[0][0].toUpperCase();
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final user = context.read<AuthCubit>().currentUser;

        return CustomScrollView(
          slivers: [
            // ── Hero ────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.navy, Color(0xFF2C3063)],
                  ),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
                ),
                padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 16, 24, 28),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                      ),
                      child: Text('WAKEELL PRO',
                        style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white60, letterSpacing: 1.5)),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, AppRoutes.lawyerNotifications),
                      child: BlocBuilder<NotificationsCubit, NotificationsState>(
                        builder: (ctx, state) {
                          final unread = state is NotificationsLoaded ? state.unreadCount : 0;
                          return Stack(clipBehavior: Clip.none, children: [
                            Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), shape: BoxShape.circle),
                              child: const Icon(Icons.notifications_outlined, size: 18, color: Colors.white),
                            ),
                            if (unread > 0)
                              Positioned(
                                top: -3, right: -3,
                                child: Container(
                                  width: 16, height: 16,
                                  decoration: const BoxDecoration(color: Color(0xFFFF3B30), shape: BoxShape.circle),
                                  child: Center(child: Text(
                                    unread > 9 ? '9+' : '$unread',
                                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white),
                                  )),
                                ),
                              ),
                          ]);
                        },
                      ),
                    ),
                  ]),
                  const SizedBox(height: 22),
                  Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 2),
                      ),
                      child: Center(child: Text(_initials(user?.name ?? ''),
                        style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white))),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Welcome back,', style: GoogleFonts.outfit(fontSize: 12, color: Colors.white54)),
                      Text(user?.name ?? '', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                      if (user?.location != null)
                        Row(children: [
                          const Icon(Icons.location_on_outlined, size: 12, color: Colors.white54),
                          const SizedBox(width: 3),
                          Text(user!.location!, style: GoogleFonts.outfit(fontSize: 12, color: Colors.white54)),
                        ]),
                    ])),
                    if (user?.isVerified == true)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF16A34A).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF16A34A).withValues(alpha: 0.4)),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.verified_outlined, size: 12, color: Color(0xFF4ADE80)),
                          const SizedBox(width: 4),
                          Text('Verified', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF4ADE80))),
                        ]),
                      ),
                  ]),
                  const SizedBox(height: 22),
                  Row(children: [
                    _HeroStat(icon: Icons.people_outline_rounded, label: 'Clients', value: '0'),
                    const SizedBox(width: 10),
                    _HeroStat(icon: Icons.video_call_outlined, label: 'Sessions', value: '0'),
                    const SizedBox(width: 10),
                    _HeroStat(icon: Icons.star_rounded, label: 'Rating', value: '—'),
                  ]),
                ]),
              ),
            ),

            // ── Body ────────────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              sliver: SliverList(delegate: SliverChildListDelegate([

                // ── Quick actions (compact) ──────────────────────────────
                Row(children: [
                  _QuickAction(icon: Icons.schedule_outlined, label: 'Availability', color: const Color(0xFF0D9488), onTap: () => Navigator.pushNamed(context, AppRoutes.lawyerAvailability)),
                  const SizedBox(width: 12),
                  _QuickAction(icon: Icons.person_outline_rounded, label: 'Edit Profile', color: AppColors.navy, onTap: () => Navigator.pushNamed(context, AppRoutes.lawyerProfileEdit)),
                  const SizedBox(width: 12),
                  _QuickAction(icon: Icons.bar_chart_rounded, label: 'Analytics', color: const Color(0xFF7C3AED), onTap: () {}),
                  const SizedBox(width: 12),
                  _QuickAction(icon: Icons.star_border_rounded, label: 'Reviews', color: const Color(0xFFD97706), onTap: () {}),
                ]),
                const SizedBox(height: 24),

                // ── Earnings card ────────────────────────────────────────
                _EarningsCard(),
                const SizedBox(height: 16),

                // ── Today's schedule ─────────────────────────────────────
                _TodayCard(onViewAll: () => onNavigate(1)),
                const SizedBox(height: 16),

                // ── Performance strip ─────────────────────────────────────
                _SectionTitle('This Month'),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _MiniStat(label: 'Bookings', value: '0', icon: Icons.calendar_month_outlined, color: AppColors.navy)),
                  const SizedBox(width: 10),
                  Expanded(child: _MiniStat(label: 'Completed', value: '0', icon: Icons.check_circle_outline_rounded, color: const Color(0xFF16A34A))),
                  const SizedBox(width: 10),
                  Expanded(child: _MiniStat(label: 'Pending', value: '0', icon: Icons.hourglass_bottom_outlined, color: const Color(0xFFD97706))),
                ]),
                const SizedBox(height: 16),

                // ── Profile completion ────────────────────────────────────
                _ProfileCompletionCard(user: user, onTap: () => Navigator.pushNamed(context, AppRoutes.lawyerProfileEdit)),

              ])),
            ),
          ],
        );
      },
    );
  }
}

// ─── Widgets ─────────────────────────────────────────────────────────────────

class _HeroStat extends StatelessWidget {
  final IconData icon; final String label; final String value;
  const _HeroStat({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
    child: Row(children: [
      Icon(icon, size: 16, color: Colors.white60),
      const SizedBox(width: 8),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
        Text(label, style: GoogleFonts.outfit(fontSize: 10, color: Colors.white54)),
      ]),
    ]),
  ));
}

class _QuickAction extends StatelessWidget {
  final IconData icon; final String label; final Color color; final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => Expanded(child: GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), boxShadow: [AppColors.cardShadow(opacity: 0.04, blur: 12)]),
      child: Column(children: [
        Container(width: 36, height: 36, decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(icon, size: 18, color: color)),
        const SizedBox(height: 6),
        Text(label, style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textSecondary), textAlign: TextAlign.center),
      ]),
    ),
  ));
}

class _EarningsCard extends StatelessWidget {
  const _EarningsCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.navy, Color(0xFF2C3063)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Total Earnings', style: GoogleFonts.outfit(fontSize: 12, color: Colors.white60)),
          const SizedBox(height: 4),
          Text('PKR 0', style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 6),
          Row(children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: const Color(0xFF16A34A).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
              child: Text('This month', style: GoogleFonts.outfit(fontSize: 10, color: const Color(0xFF4ADE80), fontWeight: FontWeight.w600))),
          ]),
        ])),
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: const Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 24),
        ),
      ]),
    );
  }
}

class _TodayCard extends StatelessWidget {
  final VoidCallback onViewAll;
  const _TodayCard({required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LawyerBookingsCubit, LawyerBookingsState>(
      builder: (context, state) {
        final todayStr = _todayStr();
        List<BookingModel> todaysBookings = [];

        if (state is LawyerBookingsLoaded) {
          todaysBookings = state.bookings.where((b) => b.date == todayStr).toList();
        }

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), boxShadow: [AppColors.cardShadow(opacity: 0.05, blur: 14)]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text("Today's Schedule", style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const Spacer(),
              GestureDetector(
                onTap: onViewAll,
                child: Text('View all', style: GoogleFonts.outfit(fontSize: 12, color: AppColors.navy, fontWeight: FontWeight.w600)),
              ),
            ]),
            const SizedBox(height: 14),
            if (todaysBookings.isEmpty)
              _EmptyToday()
            else
              ...todaysBookings.take(2).map((b) => _TodayBookingRow(booking: b)),
          ]),
        );
      },
    );
  }

  String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}

class _EmptyToday extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(child: Column(children: [
        Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.bg, shape: BoxShape.circle), child: const Icon(Icons.event_available_outlined, size: 22, color: AppColors.textHint)),
        const SizedBox(height: 10),
        Text('No consultations today', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        Text('Set your availability to get bookings', style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary)),
      ])),
    );
  }
}

class _TodayBookingRow extends StatelessWidget {
  final BookingModel booking;
  const _TodayBookingRow({required this.booking});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(color: AppColors.navy.withValues(alpha: 0.08), shape: BoxShape.circle),
          child: Center(child: Text((booking.clientName?.isNotEmpty == true ? booking.clientName![0] : '?').toUpperCase(),
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.navy))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(booking.clientName ?? 'Client', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          Text('${booking.timeSlot} · ${booking.category}', style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: booking.statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Text(booking.status, style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w700, color: booking.statusColor)),
        ),
      ]),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Text(text, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary));
}

class _MiniStat extends StatelessWidget {
  final String label; final String value; final IconData icon; final Color color;
  const _MiniStat({required this.label, required this.value, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), boxShadow: [AppColors.cardShadow(opacity: 0.04, blur: 12)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 30, height: 30, decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 15, color: color)),
        const SizedBox(height: 10),
        Text(value, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        Text(label, style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary)),
      ]),
    );
  }
}

class _ProfileCompletionCard extends StatelessWidget {
  final dynamic user;
  final VoidCallback onTap;
  const _ProfileCompletionCard({required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Simple completeness check based on available user fields
    final checks = [
      user?.name?.isNotEmpty == true,
      user?.phone != null,
      user?.location != null,
    ];
    final done = checks.where((c) => c == true).length;
    final total = checks.length;
    final pct = done / total;

    if (pct >= 1.0) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.navy.withValues(alpha: 0.12)),
          boxShadow: [AppColors.cardShadow(opacity: 0.04, blur: 12)],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.person_add_outlined, size: 18, color: AppColors.navy),
            const SizedBox(width: 8),
            Expanded(child: Text('Complete Your Profile', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: AppColors.navy.withValues(alpha: 0.07), borderRadius: BorderRadius.circular(10)),
              child: Text('${(pct * 100).toInt()}%', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.navy)),
            ),
          ]),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 6,
              backgroundColor: AppColors.bg,
              valueColor: const AlwaysStoppedAnimation(AppColors.navy),
            ),
          ),
          const SizedBox(height: 8),
          Text('Add your phone and location to get discovered by more clients.',
            style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary)),
        ]),
      ),
    );
  }
}
