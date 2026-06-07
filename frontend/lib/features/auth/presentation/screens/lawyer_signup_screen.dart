import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/theme/app_colors.dart';

class LawyerSignupScreen extends StatefulWidget {
  const LawyerSignupScreen({super.key});

  @override
  State<LawyerSignupScreen> createState() => _LawyerSignupScreenState();
}

class _LawyerSignupScreenState extends State<LawyerSignupScreen> {
  final _fullNameCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _summaryCtrl = TextEditingController();
  final int _currentStep = 0;

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _titleCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _summaryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'WAKEELL',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: 2.5,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.fieldBorder),
                      ),
                      child: const Icon(Icons.close, size: 16, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Step dots
                    Row(
                      children: List.generate(3, (i) => _StepDot(index: i, active: _currentStep)),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    Text(
                      'Create your\nProfessional Profile',
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Join an elite network of legal professionals and redefine your practice with fintech-grade efficiency.',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Avatar
                    Center(
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 88,
                                height: 88,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.navy.withValues(alpha: 0.08),
                                  border: Border.all(color: AppColors.fieldBorder, width: 2),
                                ),
                                child: const Icon(Icons.person_outline, size: 40, color: AppColors.textSecondary),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 26,
                                  height: 26,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.navy,
                                  ),
                                  child: const Icon(Icons.camera_alt_outlined, size: 14, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Professional Avatar',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Upload a professional headshot (square format,\nmin 400×400px) for your JD Pro personal',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Form fields
                    const _FieldLabel(label: 'FULL LEGAL TITLE'),
                    const SizedBox(height: 6),
                    _InputField(controller: _fullNameCtrl, hint: 'E.g. Julian Tate', prefixIcon: Icons.person_outline),
                    const SizedBox(height: 18),

                    const _FieldLabel(label: 'PROFESSIONAL TITLE'),
                    const SizedBox(height: 6),
                    _InputField(controller: _titleCtrl, hint: 'E.g. Senior Corporate Counsel', prefixIcon: Icons.work_outline),
                    const SizedBox(height: 18),

                    const _FieldLabel(label: 'BUSINESS EMAIL ADDRESS'),
                    const SizedBox(height: 6),
                    _InputField(
                      controller: _emailCtrl,
                      hint: 'email.corp@firm.com',
                      prefixIcon: Icons.alternate_email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 18),

                    const _FieldLabel(label: 'MOBILE CONTACT'),
                    const SizedBox(height: 6),
                    _InputField(
                      controller: _phoneCtrl,
                      hint: '(000) 000-0000',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 18),

                    const _FieldLabel(label: 'PROFESSIONAL SUMMARY'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _summaryCtrl,
                      maxLines: 4,
                      style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Briefly describe your expertise and legal philosophy...',
                        hintStyle: GoogleFonts.outfit(color: AppColors.textHint, fontSize: 14),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.fieldBorder),
                              ),
                              child: Center(
                                child: Text(
                                  'Back',
                                  style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: GestureDetector(
                            onTap: () {},
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: AppColors.navy,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Save & Continue',
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Security badges
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        _SecurityBadge(icon: Icons.account_balance_outlined, label: 'BANK-GRADE\nSECURITY'),
                        _SecurityBadge(icon: Icons.layers_outlined, label: 'MULTI-LAYER\nVERIFICATION'),
                        _SecurityBadge(icon: Icons.fingerprint, label: 'ID\nENCRYPTION'),
                      ],
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final int index;
  final int active;

  const _StepDot({required this.index, required this.active});

  @override
  Widget build(BuildContext context) {
    final isActive = index == active;
    final isPast = index < active;
    return Container(
      width: isActive ? 24 : 8,
      height: 8,
      margin: const EdgeInsets.only(right: 6),
      decoration: BoxDecoration(
        color: isActive || isPast ? AppColors.navy : AppColors.fieldBorder,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;

  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.outfit(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData prefixIcon;
  final TextInputType? keyboardType;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.prefixIcon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(prefixIcon, size: 18),
      ),
    );
  }
}

class _SecurityBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SecurityBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.fieldBorder),
          ),
          child: Icon(icon, size: 18, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: AppColors.textHint,
            letterSpacing: 0.3,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
