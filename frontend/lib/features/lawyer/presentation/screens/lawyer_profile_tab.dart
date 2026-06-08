import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../auth/presentation/cubits/auth_state.dart';

class LawyerProfileTab extends StatelessWidget {
  const LawyerProfileTab({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Log Out', style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        content: Text('Are you sure you want to log out?', style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: AppColors.textSecondary))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Log Out', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: AppColors.error))),
        ],
      ),
    );
    if (confirmed == true && context.mounted) await context.read<AuthCubit>().logout();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final user = context.read<AuthCubit>().currentUser;

        return ListView(
          padding: EdgeInsets.zero,
          children: [
            // ── Profile hero ───────────────────────────────────────────
            Container(
              color: AppColors.navy,
              padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 20, 24, 28),
              child: Column(children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                  ),
                  child: Center(child: Text(
                    _initials(user?.name ?? ''),
                    style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white),
                  )),
                ),
                const SizedBox(height: 12),
                Text(user?.name ?? '', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 4),
                Text(user?.email ?? '', style: GoogleFonts.outfit(fontSize: 13, color: Colors.white60)),
                const SizedBox(height: 8),
                if (user?.isVerified == true)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(color: const Color(0xFF16A34A).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF4ADE80).withValues(alpha: 0.4))),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.verified_outlined, size: 13, color: Color(0xFF4ADE80)),
                      const SizedBox(width: 5),
                      Text('Verified Lawyer', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF4ADE80))),
                    ]),
                  ),
              ]),
            ),

            // ── Options ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _GroupLabel('Account Settings'),
                const SizedBox(height: 12),
                _OptionTile(icon: Icons.person_outline_rounded, color: AppColors.navy, title: 'Edit Profile', subtitle: 'Bio, specializations, hourly rate', onTap: () => Navigator.pushNamed(context, AppRoutes.lawyerProfileEdit)),
                const SizedBox(height: 8),
                _OptionTile(icon: Icons.schedule_outlined, color: const Color(0xFF0D9488), title: 'Availability', subtitle: 'Set your working hours & slots', onTap: () => Navigator.pushNamed(context, AppRoutes.lawyerAvailability)),
                const SizedBox(height: 8),
                _OptionTile(icon: Icons.notifications_outlined, color: const Color(0xFF7C3AED), title: 'Notifications', subtitle: 'View all your notifications', onTap: () => Navigator.pushNamed(context, AppRoutes.lawyerNotifications)),
                const SizedBox(height: 24),

                _GroupLabel('Information'),
                const SizedBox(height: 12),
                _OptionTile(icon: Icons.info_outline_rounded, color: AppColors.textSecondary, title: 'About Wakeell', subtitle: 'Version 1.0.0', onTap: () {}),
                const SizedBox(height: 8),
                _OptionTile(icon: Icons.privacy_tip_outlined, color: AppColors.textSecondary, title: 'Privacy Policy', subtitle: 'How we handle your data', onTap: () {}),
                const SizedBox(height: 24),

                _GroupLabel('Session'),
                const SizedBox(height: 12),
                _OptionTile(icon: Icons.logout_rounded, color: AppColors.error, title: 'Log Out', subtitle: 'Sign out of your account', titleColor: AppColors.error, onTap: () => _confirmLogout(context)),
              ]),
            ),
          ],
        );
      },
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts.isNotEmpty && parts[0].isNotEmpty) return parts[0][0].toUpperCase();
    return '?';
  }
}

class _GroupLabel extends StatelessWidget {
  final String text;
  const _GroupLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textHint, letterSpacing: 0.5));
}

class _OptionTile extends StatelessWidget {
  final IconData icon; final Color color; final String title; final String subtitle;
  final Color? titleColor; final VoidCallback onTap;
  const _OptionTile({required this.icon, required this.color, required this.title, required this.subtitle, this.titleColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), boxShadow: [AppColors.cardShadow(opacity: 0.04, blur: 10)]),
        child: Row(children: [
          Container(width: 38, height: 38, decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 18, color: color)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: titleColor ?? AppColors.textPrimary)),
            Text(subtitle, style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary)),
          ])),
          const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textHint),
        ]),
      ),
    );
  }
}
