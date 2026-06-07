import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/routes/app_routes.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Diamond logo mark
              _DiamondLogo(),
              const SizedBox(height: 20),

              // Brand name
              Text(
                'WAKEELL',
                style: GoogleFonts.outfit(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'THE LEGAL STANDARD',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                  letterSpacing: 3,
                ),
              ),

              const Spacer(flex: 2),

              // CTA cards
              _CtaCard(
                icon: Icons.search_outlined,
                title: 'I need a Lawyer',
                subtitle: 'Find expert legal counsel instantly',
                onTap: () => Navigator.pushNamed(context, AppRoutes.login),
              ),
              const SizedBox(height: 12),
              _CtaCard(
                icon: Icons.balance_outlined,
                title: 'I am a Lawyer',
                subtitle: 'Grow your practice with Wakeell Pro',
                onTap: () => Navigator.pushNamed(context, AppRoutes.registerLawyer),
              ),

              const SizedBox(height: 28),

              // Footer badges
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _FooterBadge(icon: Icons.shield_outlined, label: 'Secure Payment'),
                  Container(
                    width: 1,
                    height: 12,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    color: AppColors.fieldBorder,
                  ),
                  _FooterBadge(icon: Icons.lock_outline, label: 'Data Encrypted'),
                ],
              ),
              const SizedBox(height: 12),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textHint, height: 1.6),
                  children: const [
                    TextSpan(text: 'By entering, you agree to our '),
                    TextSpan(
                      text: 'Terms of Service',
                      style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                    ),
                    TextSpan(text: '\nand '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                    ),
                    TextSpan(text: '.'),
                  ],
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

class _DiamondLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: CustomPaint(painter: _DiamondLogoPainter()),
    );
  }
}

class _DiamondLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    const s = 28.0;

    // Shadow
    final shadowPath = Path()
      ..moveTo(cx, cy - s)
      ..lineTo(cx + s, cy)
      ..lineTo(cx, cy + s)
      ..lineTo(cx - s, cy)
      ..close();
    canvas.drawShadow(shadowPath, const Color(0xFF1A1D3A).withValues(alpha: 0.1), 6, false);

    // Fill
    canvas.drawPath(
      shadowPath,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );

    // Border
    canvas.drawPath(
      shadowPath,
      Paint()
        ..color = const Color(0xFF1A1D3A).withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // Double slash marks inside
    final linePaint = Paint()
      ..color = const Color(0xFF1A1D3A)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(cx - 7, cy + 9), Offset(cx + 1, cy - 9), linePaint);
    canvas.drawLine(Offset(cx + 1, cy + 9), Offset(cx + 9, cy - 9), linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CtaCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _CtaCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            AppColors.cardShadow(opacity: 0.06, blur: 16, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.navy, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
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
        Icon(icon, size: 13, color: AppColors.textSecondary),
        const SizedBox(width: 5),
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
