import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../auth/presentation/cubits/auth_state.dart';

class ClientDashboardScreen extends StatelessWidget {
  const ClientDashboardScreen({super.key});

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
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                children: [
                  // ── Top bar ─────────────────────────────────────────────
                  Row(children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Good day,', style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary)),
                      Text(user?.name.split(' ').first ?? 'there',
                        style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    ]),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => context.read<AuthCubit>().logout(),
                      child: Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(color: AppColors.surface, shape: BoxShape.circle, border: Border.all(color: AppColors.fieldBorder)),
                        child: const Icon(Icons.logout_rounded, size: 18, color: AppColors.textSecondary),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 24),

                  // ── Search bar (placeholder) ─────────────────────────────
                  Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.fieldBorder),
                      boxShadow: [AppColors.cardShadow(opacity: 0.05, blur: 12)],
                    ),
                    child: Row(children: [
                      const SizedBox(width: 16),
                      const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
                      const SizedBox(width: 10),
                      Text('Search lawyers by name or specialization…',
                        style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textHint)),
                    ]),
                  ),
                  const SizedBox(height: 24),

                  // ── Stats row ────────────────────────────────────────────
                  Row(children: [
                    Expanded(child: _StatCard(label: 'Bookings', value: '0', icon: Icons.calendar_today_outlined, color: AppColors.navy)),
                    const SizedBox(width: 12),
                    Expanded(child: _StatCard(label: 'Sessions', value: '0', icon: Icons.video_call_outlined, color: const Color(0xFF0D9488))),
                    const SizedBox(width: 12),
                    Expanded(child: _StatCard(label: 'Reviews', value: '0', icon: Icons.star_border_rounded, color: const Color(0xFFD97706))),
                  ]),
                  const SizedBox(height: 28),

                  // ── Quick actions ────────────────────────────────────────
                  Text('Quick Actions', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 14),
                  _ActionCard(
                    icon: Icons.balance_outlined,
                    title: 'Find a Lawyer',
                    subtitle: 'Browse verified legal professionals',
                    color: AppColors.navy,
                    onTap: () {},
                  ),
                  const SizedBox(height: 10),
                  _ActionCard(
                    icon: Icons.calendar_month_outlined,
                    title: 'My Bookings',
                    subtitle: 'View upcoming & past consultations',
                    color: const Color(0xFF0D9488),
                    onTap: () {},
                  ),
                  const SizedBox(height: 10),
                  _ActionCard(
                    icon: Icons.person_outline_rounded,
                    title: 'My Profile',
                    subtitle: 'Update your personal information',
                    color: const Color(0xFF7C3AED),
                    onTap: () {},
                  ),
                  const SizedBox(height: 28),

                  // ── Account info ─────────────────────────────────────────
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
                      if (user?.location != null) ...[
                        const Divider(color: AppColors.divider, height: 20),
                        _InfoRow(icon: Icons.location_on_outlined, label: user!.location!),
                      ],
                      if (user?.jurisdiction != null) ...[
                        const Divider(color: AppColors.divider, height: 20),
                        _InfoRow(icon: Icons.account_balance_outlined, label: user!.jurisdiction!),
                      ],
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

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [AppColors.cardShadow(opacity: 0.05, blur: 12)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(height: 10),
        Text(value, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        Text(label, style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary)),
      ]),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  const _ActionCard({required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [AppColors.cardShadow(opacity: 0.05, blur: 12)],
        ),
        child: Row(children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            Text(subtitle, style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary)),
          ])),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 20),
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
