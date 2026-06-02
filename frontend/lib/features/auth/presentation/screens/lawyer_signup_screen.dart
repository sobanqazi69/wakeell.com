import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/theme/app_colors.dart';
class LawyerSignupScreen extends StatefulWidget {
  const LawyerSignupScreen({super.key});

  @override
  State<LawyerSignupScreen> createState() => _LawyerSignupScreenState();
}

class _LawyerSignupScreenState extends State<LawyerSignupScreen> {
  int _currentStep = 0;

  final _steps = ['Personal Info', 'Spec & Rate', 'Uploads'];
  final _stepIcons = [Icons.person_outline, Icons.assignment_outlined, Icons.cloud_upload_outlined];

  // Step 1
  final _nameCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();

  // Step 2
  final _licenseCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  final _expCtrl = TextEditingController();
  final List<String> _allSpecs = [
    'Family Law', 'Business', 'Criminal', 'Civil', 'Real Estate', 'Immigration', 'Labor', 'Tax'
  ];
  final Set<String> _selectedSpecs = {};
  final List<String> _allLangs = ['English', 'Arabic', 'French', 'Spanish', 'Urdu'];
  final Set<String> _selectedLangs = {};

  @override
  void dispose() {
    _nameCtrl.dispose();
    _titleCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _bioCtrl.dispose();
    _licenseCtrl.dispose();
    _rateCtrl.dispose();
    _expCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.gavel, color: AppColors.cyan, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'WAKEELL',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: 3,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.outlineVariant),
                        ),
                        child: const Icon(Icons.close, color: AppColors.onSurfaceVariant, size: 18),
                      ),
                    ),
                  ],
                ),
              ),

              // Step tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: List.generate(_steps.length, (i) {
                    final isActive = i == _currentStep;
                    final isDone = i < _currentStep;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _currentStep = i),
                        child: Container(
                          margin: EdgeInsets.only(right: i < _steps.length - 1 ? 8 : 0),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.cyan.withOpacity(0.1)
                                : AppColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isActive ? AppColors.cyan : AppColors.outlineVariant,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                isDone ? Icons.check_circle : _stepIcons[i],
                                color: isActive
                                    ? AppColors.cyan
                                    : isDone
                                        ? AppColors.success
                                        : AppColors.onSurfaceVariant,
                                size: 20,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _steps[i],
                                style: GoogleFonts.outfit(
                                  fontSize: 10,
                                  color: isActive
                                      ? AppColors.cyan
                                      : isDone
                                          ? AppColors.success
                                          : AppColors.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 4),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create your Professional Profile',
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Join an elite network of legal professionals and redefine your practice with fintech-grade efficiency.',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: AppColors.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      if (_currentStep == 0) _buildStep1(),
                      if (_currentStep == 1) _buildStep2(),
                      if (_currentStep == 2) _buildStep3(),

                      const SizedBox(height: 28),

                      // Navigation buttons
                      Row(
                        children: [
                          if (_currentStep > 0)
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => setState(() => _currentStep--),
                                icon: const Icon(Icons.arrow_back, size: 16),
                                label: Text(_currentStep == 1 ? 'Back' : 'Previous',
                                    style: GoogleFonts.outfit()),
                              ),
                            ),
                          if (_currentStep > 0) const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: GestureDetector(
                              onTap: () {
                                if (_currentStep < 2) {
                                  setState(() => _currentStep++);
                                }
                              },
                              child: Container(
                                height: 52,
                                decoration: BoxDecoration(
                                  gradient: AppColors.cyanButtonGradient,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [AppColors.cyanGlow(opacity: 0.3, blur: 16)],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _currentStep < 2 ? 'Save & Continue' : 'Submit Application',
                                      style: GoogleFonts.outfit(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF00363D),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(Icons.arrow_forward,
                                        color: Color(0xFF00363D), size: 16),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      // Security badges
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _BadgeChip(icon: Icons.verified_user_outlined, label: 'Bank-Grade Security'),
                          const SizedBox(width: 12),
                          _BadgeChip(icon: Icons.gavel_outlined, label: 'Regulatory Compliant'),
                          const SizedBox(width: 12),
                          _BadgeChip(icon: Icons.enhanced_encryption_outlined, label: '256-bit AES'),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar upload
        Center(
          child: Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.cyan.withOpacity(0.4), width: 2),
                  boxShadow: [AppColors.cyanGlow(opacity: 0.2, blur: 16)],
                ),
                child: const Icon(Icons.person_outline, color: AppColors.onSurfaceVariant, size: 48),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.cyan,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.darkBg, width: 2),
                  ),
                  child: const Icon(Icons.add_a_photo, color: Color(0xFF00363D), size: 16),
                ),
              ),
            ],
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 20),
            child: Column(
              children: [
                Text(
                  'Professional Avatar',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'High-resolution headshots increase client trust by 40%',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(fontSize: 11, color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),

        _LField(controller: _nameCtrl, label: 'Full Legal Name', icon: Icons.person_outline),
        const SizedBox(height: 14),
        _LField(controller: _titleCtrl, label: 'Professional Title', icon: Icons.badge_outlined),
        const SizedBox(height: 14),
        _LField(
          controller: _emailCtrl,
          label: 'Business Email Address',
          icon: Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 14),
        _PhoneField(controller: _phoneCtrl),
        const SizedBox(height: 14),
        _BioField(controller: _bioCtrl),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LField(controller: _licenseCtrl, label: 'Bar License Number', icon: Icons.numbers_outlined),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _LField(
                controller: _rateCtrl,
                label: 'Hourly Rate (\$)',
                icon: Icons.attach_money,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _LField(
                controller: _expCtrl,
                label: 'Years Experience',
                icon: Icons.workspace_premium_outlined,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Specializations
        Text(
          'Specializations',
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurfaceVariant,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _allSpecs.map((s) {
            final selected = _selectedSpecs.contains(s);
            return GestureDetector(
              onTap: () => setState(() {
                selected ? _selectedSpecs.remove(s) : _selectedSpecs.add(s);
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? AppColors.cyan.withOpacity(0.15) : AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected ? AppColors.cyan : AppColors.outlineVariant,
                  ),
                ),
                child: Text(
                  s,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: selected ? AppColors.cyan : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        // Languages
        Text(
          'Languages',
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurfaceVariant,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _allLangs.map((l) {
            final selected = _selectedLangs.contains(l);
            return GestureDetector(
              onTap: () => setState(() {
                selected ? _selectedLangs.remove(l) : _selectedLangs.add(l);
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? AppColors.purple.withOpacity(0.2) : AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected ? AppColors.purple : AppColors.outlineVariant,
                  ),
                ),
                child: Text(
                  l,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: selected ? AppColors.onSurface : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _UploadBox(
          title: 'Bar License Document',
          subtitle: 'Upload your official bar license (PDF or Image)',
          icon: Icons.description_outlined,
        ),
        const SizedBox(height: 16),
        _UploadBox(
          title: 'Government ID',
          subtitle: 'Upload a valid government-issued photo ID',
          icon: Icons.badge_outlined,
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cyan.withOpacity(0.07),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cyan.withOpacity(0.25)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline, color: AppColors.cyan, size: 18),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Your credentials will be reviewed by our admin team within 24–48 hours before your profile goes live.',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;

  const _LField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 19),
      ),
    );
  }
}

class _PhoneField extends StatelessWidget {
  final TextEditingController controller;

  const _PhoneField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.phone,
      style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: 'Mobile Contact',
        prefixIcon: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('+1', style: GoogleFonts.outfit(color: AppColors.onSurface, fontSize: 14)),
              const SizedBox(width: 4),
              const Icon(Icons.expand_more, color: AppColors.onSurfaceVariant, size: 16),
              const SizedBox(width: 4),
              Container(width: 1, height: 20, color: AppColors.outlineVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _BioField extends StatefulWidget {
  final TextEditingController controller;

  const _BioField({required this.controller});

  @override
  State<_BioField> createState() => _BioFieldState();
}

class _BioFieldState extends State<_BioField> {
  int _chars = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() => setState(() => _chars = widget.controller.text.length));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextField(
          controller: widget.controller,
          maxLines: 4,
          maxLength: 500,
          style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 14),
          decoration: const InputDecoration(
            labelText: 'Professional Summary',
            prefixIcon: Padding(
              padding: EdgeInsets.only(bottom: 60),
              child: Icon(Icons.notes_outlined, size: 19),
            ),
            counterText: '',
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4, right: 4),
          child: Text(
            '$_chars/500',
            style: GoogleFonts.outfit(fontSize: 11, color: AppColors.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

class _UploadBox extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _UploadBox({required this.title, required this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.outlineVariant,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.cyan.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.cyan, size: 26),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_upload_outlined, color: AppColors.cyan, size: 18),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _BadgeChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.cyanDim),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 10, color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }
}
