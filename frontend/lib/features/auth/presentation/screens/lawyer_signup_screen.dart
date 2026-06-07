import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
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
  final _pageCtrl = PageController();
  int _step = 0; // 0, 1, 2

  // ── Step 1 fields ─────────────────────────────────────────────────────────
  final _step1Key = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _barLicenseCtrl = TextEditingController();
  final _summaryCtrl = TextEditingController();

  // ── Step 2 ─────────────────────────────────────────────────────────────────
  XFile? _profilePhoto;

  // ── Step 3 ─────────────────────────────────────────────────────────────────
  XFile? _idFront;
  XFile? _idBack;
  XFile? _barFront;
  XFile? _barBack;

  final _picker = ImagePicker();

  @override
  void dispose() {
    _pageCtrl.dispose();
    _nameCtrl.dispose();
    _titleCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _barLicenseCtrl.dispose();
    _summaryCtrl.dispose();
    super.dispose();
  }

  // ── Navigation ──────────────────────────────────────────────────────────────

  void _next() {
    if (_step == 0) {
      if (!_step1Key.currentState!.validate()) return;
    } else if (_step == 1) {
      if (_profilePhoto == null) {
        AppSnackbar.error(context, 'Please upload your profile photo to continue.');
        return;
      }
    }
    setState(() => _step++);
    _pageCtrl.animateToPage(_step, duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
  }

  void _back() {
    if (_step == 0) {
      Navigator.pop(context);
      return;
    }
    setState(() => _step--);
    _pageCtrl.animateToPage(_step, duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
  }

  // ── Image picking ───────────────────────────────────────────────────────────

  Future<void> _pickImage({required void Function(XFile) onPicked}) async {
    final source = await _showSourceDialog();
    if (source == null) return;
    final file = await _picker.pickImage(source: source, imageQuality: 85);
    if (file != null && mounted) {
      setState(() => onPicked(file));
    }
  }

  Future<ImageSource?> _showSourceDialog() {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Choose Source', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 20),
            _SourceOption(
              icon: Icons.camera_alt_outlined,
              label: 'Take Photo',
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            const SizedBox(height: 12),
            _SourceOption(
              icon: Icons.photo_library_outlined,
              label: 'Choose from Gallery',
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  // ── Submit ──────────────────────────────────────────────────────────────────

  void _submit() {
    if (_idFront == null || _idBack == null || _barFront == null || _barBack == null) {
      AppSnackbar.error(context, 'All four documents are required to submit your application.');
      return;
    }
    context.read<AuthCubit>().registerLawyer(
          name: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: '${_nameCtrl.text.trim().split(' ').first}@123',
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
              _Header(step: _step, onBack: _back),
              _StepIndicator(currentStep: _step),
              const SizedBox(height: 8),
              Expanded(
                child: PageView(
                  controller: _pageCtrl,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _Step1PersonalInfo(
                      formKey: _step1Key,
                      nameCtrl: _nameCtrl,
                      titleCtrl: _titleCtrl,
                      emailCtrl: _emailCtrl,
                      phoneCtrl: _phoneCtrl,
                      barLicenseCtrl: _barLicenseCtrl,
                      summaryCtrl: _summaryCtrl,
                      onNext: _next,
                    ),
                    _Step2ProfilePhoto(
                      photo: _profilePhoto,
                      onPick: () => _pickImage(onPicked: (f) => _profilePhoto = f),
                      onNext: _next,
                    ),
                    _Step3Documents(
                      idFront: _idFront,
                      idBack: _idBack,
                      barFront: _barFront,
                      barBack: _barBack,
                      onPickIdFront: () => _pickImage(onPicked: (f) => _idFront = f),
                      onPickIdBack: () => _pickImage(onPicked: (f) => _idBack = f),
                      onPickBarFront: () => _pickImage(onPicked: (f) => _barFront = f),
                      onPickBarBack: () => _pickImage(onPicked: (f) => _barBack = f),
                      onSubmit: _submit,
                    ),
                  ],
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(color: AppColors.navy.withValues(alpha: 0.08), shape: BoxShape.circle),
              child: const Icon(Icons.check_circle_outline_rounded, color: AppColors.navy, size: 36),
            ),
            const SizedBox(height: 20),
            Text('Application Submitted!',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            Text(
              'Our compliance team will verify your credentials and documents within 24–48 hours.',
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
                decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(10)),
                child: Center(child: Text('Go to Login',
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shared header ────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final int step;
  final VoidCallback onBack;
  const _Header({required this.step, required this.onBack});

  static const _titles = ['Personal Info', 'Profile Photo', 'Documents'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: AppColors.surface, shape: BoxShape.circle,
                border: Border.all(color: AppColors.fieldBorder),
              ),
              child: const Icon(Icons.arrow_back, size: 18, color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(width: 16),
          Text('WAKEELL', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: 2.5)),
          const Spacer(),
          Text(_titles[step], style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

// ─── Step indicator ───────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: List.generate(3, (i) {
          final done = i < currentStep;
          final active = i == currentStep;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: done || active ? AppColors.navy : AppColors.fieldBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (i < 2) const SizedBox(width: 6),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ─── Step 1: Personal Info ────────────────────────────────────────────────────

class _Step1PersonalInfo extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl, titleCtrl, emailCtrl, phoneCtrl, barLicenseCtrl, summaryCtrl;
  final VoidCallback onNext;

  const _Step1PersonalInfo({
    required this.formKey, required this.nameCtrl, required this.titleCtrl,
    required this.emailCtrl, required this.phoneCtrl, required this.barLicenseCtrl,
    required this.summaryCtrl, required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Create your\nProfessional Profile',
              style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.2)),
            const SizedBox(height: 6),
            Text('Join an elite network of legal professionals.',
              style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
            const SizedBox(height: 24),

            _label('FULL LEGAL NAME *'),
            const SizedBox(height: 6),
            _field(ctrl: nameCtrl, hint: 'e.g. Julian Tate', icon: Icons.person_outline,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Full name is required' : null),
            const SizedBox(height: 16),

            _label('PROFESSIONAL TITLE'),
            const SizedBox(height: 6),
            _field(ctrl: titleCtrl, hint: 'e.g. Senior Corporate Counsel', icon: Icons.work_outline),
            const SizedBox(height: 16),

            _label('BUSINESS EMAIL *'),
            const SizedBox(height: 6),
            _field(ctrl: emailCtrl, hint: 'email@firm.com', icon: Icons.alternate_email,
              type: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email is required';
                if (!v.contains('@')) return 'Enter a valid email';
                return null;
              }),
            const SizedBox(height: 16),

            _label('BAR LICENSE NUMBER *'),
            const SizedBox(height: 6),
            _field(ctrl: barLicenseCtrl, hint: 'e.g. NY-BAR-12345', icon: Icons.badge_outlined,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Bar license number is required' : null),
            const SizedBox(height: 16),

            _label('MOBILE CONTACT'),
            const SizedBox(height: 6),
            _field(ctrl: phoneCtrl, hint: '(000) 000-0000', icon: Icons.phone_outlined, type: TextInputType.phone),
            const SizedBox(height: 16),

            _label('PROFESSIONAL SUMMARY'),
            const SizedBox(height: 6),
            TextFormField(
              controller: summaryCtrl,
              maxLines: 4,
              style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Briefly describe your expertise and legal philosophy...',
                hintStyle: GoogleFonts.outfit(color: AppColors.textHint, fontSize: 13),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 28),

            _NavButton(label: 'Continue', icon: Icons.arrow_forward, onTap: onNext),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  static Widget _label(String text) => Text(text,
    style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.8));

  static Widget _field({
    required TextEditingController ctrl,
    required String hint,
    required IconData icon,
    TextInputType type = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      textInputAction: TextInputAction.next,
      style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon, size: 18)),
      validator: validator,
    );
  }
}

// ─── Step 2: Profile Photo ────────────────────────────────────────────────────

class _Step2ProfilePhoto extends StatelessWidget {
  final XFile? photo;
  final VoidCallback onPick;
  final VoidCallback onNext;

  const _Step2ProfilePhoto({required this.photo, required this.onPick, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Profile Photo',
            style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Text('A professional headshot is mandatory. This is the first thing clients see.',
            style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
          const SizedBox(height: 36),

          Center(
            child: GestureDetector(
              onTap: onPick,
              child: Column(
                children: [
                  Container(
                    width: 160, height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.navy.withValues(alpha: 0.05),
                      border: Border.all(
                        color: photo != null ? AppColors.navy : AppColors.fieldBorder,
                        width: photo != null ? 2.5 : 1.5,
                      ),
                      boxShadow: photo != null
                          ? [AppColors.cardShadow(opacity: 0.12, blur: 24, offset: const Offset(0, 8))]
                          : [],
                    ),
                    child: photo != null
                        ? ClipOval(child: Image.file(File(photo!.path), fit: BoxFit.cover))
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add_a_photo_outlined, size: 36, color: AppColors.textSecondary),
                              const SizedBox(height: 8),
                              Text('Tap to add photo',
                                style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary)),
                            ],
                          ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.fieldBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.camera_alt_outlined, size: 18, color: AppColors.navy),
                        const SizedBox(width: 8),
                        Text(photo != null ? 'Change Photo' : 'Upload Photo',
                          style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.navy)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          _InfoCard(
            icon: Icons.info_outline,
            text: 'Use a clear, professional headshot in square format (min 400×400px). '
                'Blurry or non-professional photos will be rejected.',
          ),
          const SizedBox(height: 28),

          _NavButton(
            label: 'Continue',
            icon: Icons.arrow_forward,
            onTap: onNext,
            enabled: photo != null,
          ),
        ],
      ),
    );
  }
}

// ─── Step 3: Documents ────────────────────────────────────────────────────────

class _Step3Documents extends StatelessWidget {
  final XFile? idFront, idBack, barFront, barBack;
  final VoidCallback onPickIdFront, onPickIdBack, onPickBarFront, onPickBarBack, onSubmit;

  const _Step3Documents({
    required this.idFront, required this.idBack,
    required this.barFront, required this.barBack,
    required this.onPickIdFront, required this.onPickIdBack,
    required this.onPickBarFront, required this.onPickBarBack,
    required this.onSubmit,
  });

  bool get _allDone => idFront != null && idBack != null && barFront != null && barBack != null;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Identity & License\nVerification',
            style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.2)),
          const SizedBox(height: 6),
          Text('All four documents are mandatory for compliance verification.',
            style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
          const SizedBox(height: 24),

          _SectionLabel(label: 'NATIONAL ID CARD', icon: Icons.credit_card_outlined),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _DocumentCard(
                  label: 'Front Side',
                  file: idFront,
                  onTap: onPickIdFront,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DocumentCard(
                  label: 'Back Side',
                  file: idBack,
                  onTap: onPickIdBack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          _SectionLabel(label: 'BAR LICENSE CERTIFICATE', icon: Icons.workspace_premium_outlined),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _DocumentCard(
                  label: 'Front Side',
                  file: barFront,
                  onTap: onPickBarFront,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DocumentCard(
                  label: 'Back Side',
                  file: barBack,
                  onTap: onPickBarBack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _InfoCard(
            icon: Icons.lock_outline,
            text: 'Your documents are encrypted and used solely for identity verification. '
                'They are never shared with clients.',
          ),
          const SizedBox(height: 28),

          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              final isLoading = state is AuthLoading;
              return _NavButton(
                label: isLoading ? 'Submitting…' : 'Submit Application',
                icon: Icons.check_circle_outline,
                onTap: isLoading ? null : onSubmit,
                enabled: _allDone,
                isLoading: isLoading,
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── Document photo card ──────────────────────────────────────────────────────

class _DocumentCard extends StatelessWidget {
  final String label;
  final XFile? file;
  final VoidCallback onTap;

  const _DocumentCard({required this.label, required this.file, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          color: file != null ? Colors.transparent : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: file != null ? AppColors.navy : AppColors.fieldBorder,
            width: file != null ? 2 : 1,
          ),
        ),
        child: file != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: Image.file(File(file!.path), fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 6, right: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: AppColors.navy, shape: BoxShape.circle),
                      child: const Icon(Icons.check, size: 12, color: Colors.white),
                    ),
                  ),
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
                      ),
                      child: Text(label,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.add_photo_alternate_outlined, size: 22, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Text(label,
                    style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text('Tap to upload',
                    style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textHint)),
                ],
              ),
      ),
    );
  }
}

// ─── Shared widgets ───────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final IconData icon;
  const _SectionLabel({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(color: AppColors.navy.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(6)),
          child: Icon(icon, size: 14, color: AppColors.navy),
        ),
        const SizedBox(width: 10),
        Text(label, style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: 0.8)),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoCard({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.navy.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.navy.withValues(alpha: 0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.navy),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: GoogleFonts.outfit(fontSize: 12, color: AppColors.navyMid, height: 1.6)),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool enabled;
  final bool isLoading;

  const _NavButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.enabled = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final active = enabled && onTap != null && !isLoading;
    return GestureDetector(
      onTap: active ? onTap : null,
      child: Container(
        width: double.infinity, height: 52,
        decoration: BoxDecoration(
          color: active ? AppColors.navy : AppColors.navy.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(10),
          boxShadow: active
              ? [BoxShadow(color: AppColors.navy.withValues(alpha: 0.25), blurRadius: 16, offset: const Offset(0, 6))]
              : [],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(label, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                    const SizedBox(width: 8),
                    Icon(icon, color: Colors.white, size: 17),
                  ],
                ),
        ),
      ),
    );
  }
}

class _SourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SourceOption({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.fieldBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: AppColors.navy.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 18, color: AppColors.navy),
            ),
            const SizedBox(width: 14),
            Text(label, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
            const Spacer(),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}
