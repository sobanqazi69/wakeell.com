import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/routes/app_routes.dart';

class LawyerGatewayScreen extends StatelessWidget {
  const LawyerGatewayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // Back button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.fieldBorder),
                  ),
                  child: const Icon(Icons.arrow_back, size: 18, color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(height: 32),

              // Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.navy.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.navy.withValues(alpha: 0.12)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6, height: 6,
                      decoration: const BoxDecoration(color: AppColors.navy, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'LEGAL PROFESSIONALS',
                      style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.navy, letterSpacing: 1.2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Headline
              Text(
                'Welcome,\nCounselor.',
                style: GoogleFonts.outfit(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Access your dashboard or join an elite network of legal professionals on Wakeell.',
                style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textSecondary, height: 1.6),
              ),

              const Spacer(),

              // Sign In card (prominent — existing lawyers)
              _GatewayCard(
                tag: 'RETURNING MEMBER',
                title: 'Sign In to Your Account',
                subtitle: 'Access your client bookings, sessions\nand earnings dashboard.',
                iconData: Icons.login_rounded,
                isPrimary: true,
                onTap: () => Navigator.pushNamed(context, AppRoutes.login),
              ),
              const SizedBox(height: 16),

              // Apply card (secondary — new lawyers)
              _GatewayCard(
                tag: 'NEW TO WAKEELL',
                title: 'Apply as a Lawyer',
                subtitle: 'Create your professional profile and\nstart accepting client consultations.',
                iconData: Icons.balance_outlined,
                isPrimary: false,
                onTap: () => Navigator.pushNamed(context, AppRoutes.registerLawyer),
              ),

              const SizedBox(height: 32),

              // Footer
              Center(
                child: Text(
                  'All lawyer profiles are verified by the Wakeell compliance team.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textHint, height: 1.6),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _GatewayCard extends StatelessWidget {
  final String tag;
  final String title;
  final String subtitle;
  final IconData iconData;
  final bool isPrimary;
  final VoidCallback onTap;

  const _GatewayCard({
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.iconData,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.navy : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPrimary ? AppColors.navy : AppColors.fieldBorder,
          ),
          boxShadow: [
            isPrimary
                ? BoxShadow(color: AppColors.navy.withValues(alpha: 0.22), blurRadius: 24, offset: const Offset(0, 8))
                : AppColors.cardShadow(opacity: 0.06, blur: 16, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            // Icon circle
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: isPrimary
                    ? Colors.white.withValues(alpha: 0.12)
                    : AppColors.navy.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                iconData,
                size: 24,
                color: isPrimary ? Colors.white : AppColors.navy,
              ),
            ),
            const SizedBox(width: 18),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tag,
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: isPrimary
                          ? Colors.white.withValues(alpha: 0.6)
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isPrimary ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: isPrimary
                          ? Colors.white.withValues(alpha: 0.65)
                          : AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Arrow
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: isPrimary ? Colors.white.withValues(alpha: 0.7) : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
