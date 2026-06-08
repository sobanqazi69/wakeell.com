import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../auth/presentation/cubits/auth_state.dart';

class LawyerDashboardScreen extends StatelessWidget {
  const LawyerDashboardScreen({super.key});

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
            body: SafeArea(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // ── Navy hero header ─────────────────────────────────────
                  Container(
                    color: AppColors.navy,
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Text('WAKEELL PRO',
                          style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.5), letterSpacing: 2)),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => context.read<AuthCubit>().logout(),
                          child: Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                            ),
                            child: const Icon(Icons.logout_rounded, size: 17, color: Colors.white),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 20),
                      Text('Welcome back,', style: GoogleFonts.outfit(fontSize: 13, color: Colors.white.withValues(alpha: 0.6))),
                      Text(user?.name ?? '', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
                      const SizedBox(height: 14),
                      // Stats row
                      Row(children: [
                        _HeroStat(label: 'Clients', value: '0'),
                        _HeroDivider(),
                        _HeroStat(label: 'Sessions', value: '0'),
                        _HeroDivider(),
                        _HeroStat(label: 'Rating', value: '—'),
                      ]),
                    ]),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      // ── Quick actions ──────────────────────────────────────
                      Text('Dashboard', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      const SizedBox(height: 14),
                      Row(children: [
                        Expanded(child: _DashCard(icon: Icons.calendar_month_outlined, label: 'Bookings', color: AppColors.navy, onTap: () {})),
                        const SizedBox(width: 12),
                        Expanded(child: _DashCard(icon: Icons.video_call_outlined, label: 'Sessions', color: const Color(0xFF0D9488), onTap: () {})),
                        const SizedBox(width: 12),
                        Expanded(child: _DashCard(icon: Icons.star_border_rounded, label: 'Reviews', color: const Color(0xFFD97706), onTap: () {})),
                      ]),
                      const SizedBox(height: 28),

                      // ── Quick links ────────────────────────────────────────
                      Text('Manage', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      const SizedBox(height: 14),
                      _LinkTile(icon: Icons.person_outline_rounded, title: 'My Profile', subtitle: 'Update bio, photo and specializations', onTap: () {}),
                      const SizedBox(height: 10),
                      _LinkTile(icon: Icons.schedule_outlined, title: 'Availability', subtitle: 'Set your working hours and slots', onTap: () {}),
                      const SizedBox(height: 10),
                      _LinkTile(icon: Icons.attach_money_rounded, title: 'Pricing', subtitle: 'Set your hourly consultation rate', onTap: () {}),
                      const SizedBox(height: 28),

                      // ── Account info ───────────────────────────────────────
                      Text('Account', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [AppColors.cardShadow(opacity: 0.05, blur: 16)],
                        ),
                        child: Column(children: [
                          _InfoRow(icon: Icons.alternate_email, label: user?.email ?? ''),
                          if (user?.phone != null) ...[
                            const Divider(color: AppColors.divider, height: 20),
                            _InfoRow(icon: Icons.phone_outlined, label: user!.phone!),
                          ],
                        ]),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;
  const _HeroStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
      Text(label, style: GoogleFonts.outfit(fontSize: 11, color: Colors.white.withValues(alpha: 0.6))),
    ]);
  }
}

class _HeroDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 32, color: Colors.white.withValues(alpha: 0.15), margin: const EdgeInsets.symmetric(horizontal: 20));
  }
}

class _DashCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _DashCard({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), boxShadow: [AppColors.cardShadow(opacity: 0.05, blur: 12)]),
        child: Column(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 8),
          Text(label, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ]),
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _LinkTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), boxShadow: [AppColors.cardShadow(opacity: 0.05, blur: 12)]),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: AppColors.navy.withValues(alpha: 0.07), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 19, color: AppColors.navy),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            Text(subtitle, style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary)),
          ])),
          const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textSecondary),
        ]),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 16, color: AppColors.textSecondary),
      const SizedBox(width: 10),
      Text(label, style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textPrimary)),
    ]);
  }
}
