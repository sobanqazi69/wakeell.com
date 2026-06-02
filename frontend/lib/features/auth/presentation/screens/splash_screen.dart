import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/routes/app_routes.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.darkBg, AppColors.surfaceContainerLow],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Logo section
              Expanded(
                flex: 5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surfaceContainer,
                        boxShadow: [AppColors.cyanGlow(opacity: 0.35, blur: 32)],
                      ),
                      child: const Icon(Icons.gavel, color: AppColors.cyan, size: 44),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'WAKEELL',
                      style: GoogleFonts.outfit(
                        fontSize: 38,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: 5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'The Legal Standard',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.onSurfaceVariant,
                        letterSpacing: 3,
                      ),
                    ),
                  ],
                ),
              ),

              // CTA Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _CtaCard(
                      icon: Icons.person_search_outlined,
                      title: 'I need a Lawyer',
                      subtitle: 'Find expert legal counsel instantly',
                      isPrimary: true,
                      onTap: () => Navigator.pushNamed(context, AppRoutes.login),
                    ),
                    const SizedBox(height: 12),
                    _CtaCard(
                      icon: Icons.balance_outlined,
                      title: 'I am a Lawyer',
                      subtitle: 'Grow your practice with Wakeell Pro',
                      isPrimary: false,
                      onTap: () => Navigator.pushNamed(context, AppRoutes.registerLawyer),
                    ),
                  ],
                ),
              ),

              // Footer badges
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _FooterBadge(icon: Icons.shield_outlined, label: 'Secure Payment'),
                  Container(
                    width: 1,
                    height: 14,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    color: AppColors.outlineVariant,
                  ),
                  _FooterBadge(icon: Icons.lock_outline, label: 'Data Encrypted'),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    child: Text(
                      'Terms of Service',
                      style: GoogleFonts.outfit(fontSize: 11, color: AppColors.outline),
                    ),
                  ),
                  const SizedBox(width: 20),
                  GestureDetector(
                    child: Text(
                      'Privacy Policy',
                      style: GoogleFonts.outfit(fontSize: 11, color: AppColors.outline),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _CtaCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isPrimary;
  final VoidCallback onTap;

  const _CtaCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          gradient: isPrimary ? AppColors.cyanButtonGradient : null,
          color: isPrimary ? null : AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: isPrimary
              ? null
              : Border.all(color: AppColors.purple.withOpacity(0.6), width: 1),
          boxShadow: isPrimary
              ? [AppColors.cyanGlow(opacity: 0.25, blur: 20)]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isPrimary
                    ? const Color(0xFF00363D).withOpacity(0.3)
                    : AppColors.purple.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isPrimary ? const Color(0xFF001F24) : AppColors.cyan,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isPrimary ? const Color(0xFF001F24) : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: isPrimary
                          ? const Color(0xFF004F58)
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isPrimary ? const Color(0xFF00363D) : AppColors.cyan,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FooterBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.outline),
        const SizedBox(width: 5),
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 11, color: AppColors.outline),
        ),
      ],
    );
  }
}
