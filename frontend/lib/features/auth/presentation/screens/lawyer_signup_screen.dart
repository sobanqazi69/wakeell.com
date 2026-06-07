import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../cubits/auth_cubit.dart';
import '../cubits/auth_state.dart';

class LawyerSignupScreen extends StatefulWidget {
  const LawyerSignupScreen({super.key});

  @override
  State<LawyerSignupScreen> createState() => _LawyerSignupScreenState();
}

class _LawyerSignupScreenState extends State<LawyerSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _barLicenseCtrl = TextEditingController();
  final _summaryCtrl = TextEditingController();
  final int _currentStep = 0;

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _titleCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _barLicenseCtrl.dispose();
    _summaryCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().registerLawyer(
          name: _fullNameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: '${_fullNameCtrl.text.trim()}@123',
          barLicense: _barLicenseCtrl.text.trim(),
          phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
          bio: _summaryCtrl.text.trim().isEmpty ? null : _summaryCtrl.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthLawyerPending) {
          _showPendingDialog();
        } else if (state is AuthError) {
          AppSnackbar.error(context, state.message);
        }
      },
      child: Scaffold(
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
                    Text('WAKEELL', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: 2.5)),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(color: AppColors.surface, shape: BoxShape.circle, border: Border.all(color: AppColors.fieldBorder)),
                        child: const Icon(Icons.close, size: 16, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Step dots
                        Row(children: List.generate(3, (i) => _StepDot(index: i, active: _currentStep))),
                        const SizedBox(height: 24),

                        Text('Create your\nProfessional Profile',
                          style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.2)),
                        const SizedBox(height: 10),
                        Text('Join an elite network of legal professionals and redefine your practice with fintech-grade efficiency.',
                          style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary, height: 1.6)),
                        const SizedBox(height: 28),

                        // Avatar placeholder
                        Center(
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    width: 88, height: 88,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.navy.withValues(alpha: 0.08),
                                      border: Border.all(color: AppColors.fieldBorder, width: 2),
                                    ),
                                    child: const Icon(Icons.person_outline, size: 40, color: AppColors.textSecondary),
                                  ),
                                  Positioned(
                                    bottom: 0, right: 0,
                                    child: Container(
                                      width: 26, height: 26,
                                      decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.navy),
                                      child: const Icon(Icons.camera_alt_outlined, size: 14, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text('Professional Avatar', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                              const SizedBox(height: 4),
                              Text('Upload a professional headshot (square format,\nmin 400×400px)',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary, height: 1.5)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Full Legal Name
                        const _FieldLabel(label: 'FULL LEGAL NAME'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _fullNameCtrl,
                          textInputAction: TextInputAction.next,
                          style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 14),
                          decoration: const InputDecoration(hintText: 'E.g. Julian Tate', prefixIcon: Icon(Icons.person_outline, size: 18)),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Full name is required' : null,
                        ),
                        const SizedBox(height: 18),

                        // Professional Title
                        const _FieldLabel(label: 'PROFESSIONAL TITLE'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _titleCtrl,
                          textInputAction: TextInputAction.next,
                          style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 14),
                          decoration: const InputDecoration(hintText: 'E.g. Senior Corporate Counsel', prefixIcon: Icon(Icons.work_outline, size: 18)),
                        ),
                        const SizedBox(height: 18),

                        // Business Email
                        const _FieldLabel(label: 'BUSINESS EMAIL ADDRESS'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 14),
                          decoration: const InputDecoration(hintText: 'email.corp@firm.com', prefixIcon: Icon(Icons.alternate_email, size: 18)),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Email is required';
                            if (!v.contains('@')) return 'Enter a valid email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        // Bar License
                        const _FieldLabel(label: 'BAR LICENSE NUMBER'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _barLicenseCtrl,
                          textInputAction: TextInputAction.next,
                          style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 14),
                          decoration: const InputDecoration(hintText: 'E.g. NY-BAR-12345', prefixIcon: Icon(Icons.badge_outlined, size: 18)),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Bar license is required' : null,
                        ),
                        const SizedBox(height: 18),

                        // Mobile
                        const _FieldLabel(label: 'MOBILE CONTACT'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 14),
                          decoration: const InputDecoration(hintText: '(000) 000-0000', prefixIcon: Icon(Icons.phone_outlined, size: 18)),
                        ),
                        const SizedBox(height: 18),

                        // Professional Summary
                        const _FieldLabel(label: 'PROFESSIONAL SUMMARY'),
                        const SizedBox(height: 6),
                        TextFormField(
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
                                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.fieldBorder)),
                                  child: Center(child: Text('Back', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary))),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: BlocBuilder<AuthCubit, AuthState>(
                                builder: (context, state) {
                                  final isLoading = state is AuthLoading;
                                  return GestureDetector(
                                    onTap: isLoading ? null : _submit,
                                    child: Container(
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: isLoading ? AppColors.navy.withValues(alpha: 0.6) : AppColors.navy,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: isLoading
                                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                            : Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text('Save & Continue', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                                                  const SizedBox(width: 6),
                                                  const Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                                                ],
                                              ),
                                      ),
                                    ),
                                  );
                                },
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPendingDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(color: AppColors.navy.withValues(alpha: 0.08), shape: BoxShape.circle),
              child: const Icon(Icons.hourglass_top_rounded, color: AppColors.navy, size: 32),
            ),
            const SizedBox(height: 20),
            Text('Application Submitted!', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            Text(
              'Your lawyer profile is under review. Our team will verify your credentials within 24–48 hours.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary, height: 1.6),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
              },
              child: Container(
                width: double.infinity, height: 48,
                decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(8)),
                child: Center(child: Text('Go to Login', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white))),
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
      width: isActive ? 24 : 8, height: 8,
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
  Widget build(BuildContext context) => Text(
        label,
        style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 0.8),
      );
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
          width: 40, height: 40,
          decoration: BoxDecoration(color: AppColors.surface, shape: BoxShape.circle, border: Border.all(color: AppColors.fieldBorder)),
          child: Icon(icon, size: 18, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 6),
        Text(label, textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.textHint, letterSpacing: 0.3, height: 1.4)),
      ],
    );
  }
}
