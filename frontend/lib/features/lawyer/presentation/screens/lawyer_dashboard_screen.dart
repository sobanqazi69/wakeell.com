import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../auth/presentation/cubits/auth_state.dart';

class LawyerDashboardScreen extends StatelessWidget {
  const LawyerDashboardScreen({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Log Out', style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        content: Text('Are you sure you want to log out?', style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: Text('Cancel', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: Text('Log Out', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<AuthCubit>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.splash, (_) => false);
        }
      },
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final user = context.read<AuthCubit>().currentUser;

          return Scaffold(
            backgroundColor: AppColors.bg,
            body: CustomScrollView(
              slivers: [
                // ── Hero header ────────────────────────────────────────────
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
                      // Top row: badge + notification icon (no logout here)
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
                          onTap: () {},
                          child: Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), shape: BoxShape.circle),
                            child: const Icon(Icons.notifications_outlined, size: 18, color: Colors.white),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 22),

                      // Avatar + name
                      Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                        Container(
                          width: 56, height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 2),
                          ),
                          child: Center(child: Text(
                            _initials(user?.name ?? ''),
                            style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                          )),
                        ),
                        const SizedBox(width: 14),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Welcome back,', style: GoogleFonts.outfit(fontSize: 12, color: Colors.white54)),
                          Text(user?.name ?? '', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                          if (user?.location != null) ...[
                            const SizedBox(height: 2),
                            Row(children: [
                              const Icon(Icons.location_on_outlined, size: 12, color: Colors.white54),
                              const SizedBox(width: 3),
                              Text(user!.location!, style: GoogleFonts.outfit(fontSize: 12, color: Colors.white54)),
                            ]),
                          ],
                        ])),
                        // Verified badge
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

                      // Stats strip
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

                // ── Body ──────────────────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                  sliver: SliverList(delegate: SliverChildListDelegate([

                    // ── Manage section ─────────────────────────────────────
                    _SectionTitle('Manage'),
                    const SizedBox(height: 14),
                    _MenuTile(
                      icon: Icons.person_outline_rounded,
                      color: AppColors.navy,
                      title: 'My Profile',
                      subtitle: 'Bio, specializations, rate',
                      onTap: () => Navigator.pushNamed(context, AppRoutes.lawyerProfileEdit),
                    ),
                    const SizedBox(height: 10),
                    _MenuTile(
                      icon: Icons.schedule_outlined,
                      color: const Color(0xFF0D9488),
                      title: 'Availability',
                      subtitle: 'Set working hours & slots',
                      onTap: () {},
                    ),
                    const SizedBox(height: 10),
                    _MenuTile(
                      icon: Icons.calendar_month_outlined,
                      color: const Color(0xFF7C3AED),
                      title: 'Bookings',
                      subtitle: 'View incoming consultations',
                      onTap: () {},
                    ),
                    const SizedBox(height: 28),

                    // ── Quick stats row ────────────────────────────────────
                    _SectionTitle('Overview'),
                    const SizedBox(height: 14),
                    Row(children: [
                      Expanded(child: _StatCard(icon: Icons.calendar_today_outlined, label: 'Today', value: '0', color: AppColors.navy)),
                      const SizedBox(width: 12),
                      Expanded(child: _StatCard(icon: Icons.hourglass_bottom_outlined, label: 'Pending', value: '0', color: const Color(0xFFD97706))),
                      const SizedBox(width: 12),
                      Expanded(child: _StatCard(icon: Icons.check_circle_outline_rounded, label: 'Done', value: '0', color: const Color(0xFF16A34A))),
                    ]),
                    const SizedBox(height: 28),

                    // ── Account tile ───────────────────────────────────────
                    _SectionTitle('Account'),
                    const SizedBox(height: 14),
                    _MenuTile(
                      icon: Icons.alternate_email_rounded,
                      color: AppColors.textSecondary,
                      title: user?.email ?? '',
                      subtitle: 'Registered email',
                      trailing: null,
                      interactive: false,
                    ),
                    const SizedBox(height: 10),
                    _MenuTile(
                      icon: Icons.logout_rounded,
                      color: AppColors.error,
                      title: 'Log Out',
                      subtitle: 'Sign out of your account',
                      titleColor: AppColors.error,
                      onTap: () => _confirmLogout(context),
                    ),

                  ])),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts.isNotEmpty && parts[0].isNotEmpty) return parts[0][0].toUpperCase();
    return '?';
  }
}

// ─── Subwidgets ───────────────────────────────────────────────────────────────

class _HeroStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _HeroStat({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(children: [
          Icon(icon, size: 16, color: Colors.white60),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            Text(label, style: GoogleFonts.outfit(fontSize: 10, color: Colors.white54)),
          ]),
        ]),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary));
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final Color? titleColor;
  final Widget? trailing;
  final bool interactive;
  final VoidCallback? onTap;

  const _MenuTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    this.titleColor,
    this.trailing,
    this.interactive = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: interactive ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [AppColors.cardShadow(opacity: 0.04, blur: 12)],
        ),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 19, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
              style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600,
                color: titleColor ?? AppColors.textPrimary)),
            Text(subtitle, style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary)),
          ])),
          if (interactive)
            trailing ?? const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textSecondary),
        ]),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [AppColors.cardShadow(opacity: 0.04, blur: 12)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(height: 10),
        Text(value, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        Text(label, style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary)),
      ]),
    );
  }
}
