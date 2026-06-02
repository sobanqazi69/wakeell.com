import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/routes/app_routes.dart';

class ClientSignupScreen extends StatefulWidget {
  const ClientSignupScreen({super.key});

  @override
  State<ClientSignupScreen> createState() => _ClientSignupScreenState();
}

class _ClientSignupScreenState extends State<ClientSignupScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _agreed = false;
  String? _selectedLocation;
  String? _selectedJurisdiction;

  final _locations = ['London, UK', 'New York, USA', 'Dubai, UAE', 'Singapore'];
  final _jurisdictions = ['Common Law', 'Civil Law', 'Sharia Law', 'International'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
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
                      onTap: () => Navigator.pushNamed(context, AppRoutes.login),
                      child: Text(
                        'Sign In',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: AppColors.cyan,
                          fontWeight: FontWeight.w500,
                        ),
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
                      // Step indicator
                      Row(
                        children: [
                          _StepDot(number: '01', isActive: true),
                          _StepLine(isActive: false),
                          _StepDot(number: '02', isActive: false),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Hero section
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.white.withOpacity(0.06),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Elite Legal Governance.\nAutomated.',
                              style: GoogleFonts.outfit(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _FeaturePill(
                              icon: Icons.lock_outline,
                              label: 'End-to-end encryption protocols',
                            ),
                            const SizedBox(height: 8),
                            _FeaturePill(
                              icon: Icons.account_balance_outlined,
                              label: 'Jurisdiction-aware legal logic',
                            ),
                            const SizedBox(height: 8),
                            _FeaturePill(
                              icon: Icons.account_balance_wallet_outlined,
                              label: 'Integrated fintech treasury',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Form
                      _SignupInputField(
                        controller: _nameCtrl,
                        label: 'Full Name',
                        prefixIcon: Icons.person_outline,
                      ),
                      const SizedBox(height: 14),
                      _SignupInputField(
                        controller: _emailCtrl,
                        label: 'Work Email',
                        prefixIcon: Icons.mail_outline,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 14),
                      _SignupInputField(
                        controller: _passwordCtrl,
                        label: 'Secure Password',
                        prefixIcon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        suffixIcon: GestureDetector(
                          onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                          child: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: AppColors.onSurfaceVariant,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _DropdownField(
                        value: _selectedLocation,
                        label: 'Primary Location',
                        icon: Icons.location_on_outlined,
                        items: _locations,
                        onChanged: (v) => setState(() => _selectedLocation = v),
                      ),
                      const SizedBox(height: 14),
                      _DropdownField(
                        value: _selectedJurisdiction,
                        label: 'Jurisdiction',
                        icon: Icons.account_balance_outlined,
                        items: _jurisdictions,
                        onChanged: (v) => setState(() => _selectedJurisdiction = v),
                      ),
                      const SizedBox(height: 20),

                      // Checkbox
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _agreed,
                              onChanged: (v) => setState(() => _agreed = v ?? false),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'I acknowledge the Legal Service Agreements and consent to Bio-metric Data Processing protocols',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: AppColors.onSurfaceVariant,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Create account button
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: double.infinity,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: AppColors.cyanButtonGradient,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [AppColors.cyanGlow(opacity: 0.3, blur: 16)],
                          ),
                          child: Center(
                            child: Text(
                              'Create Account',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF00363D),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Footer
                      Center(
                        child: Text(
                          'ISO 27001 Certified  •  SOC2 Type II Compliant  •  256-bit AES Encryption',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            color: AppColors.outline,
                            height: 1.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
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
}

class _StepDot extends StatelessWidget {
  final String number;
  final bool isActive;

  const _StepDot({required this.number, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? AppColors.cyan : AppColors.surfaceContainer,
        border: isActive ? null : Border.all(color: AppColors.outlineVariant),
        boxShadow: isActive ? [AppColors.cyanGlow(opacity: 0.4, blur: 12)] : null,
      ),
      child: Center(
        child: Text(
          number,
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isActive ? const Color(0xFF00363D) : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _StepLine extends StatelessWidget {
  final bool isActive;

  const _StepLine({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          gradient: isActive ? AppColors.cyanButtonGradient : null,
          color: isActive ? null : AppColors.outlineVariant,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeaturePill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.cyan.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: AppColors.cyan, size: 16),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 13,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _SignupInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;

  const _SignupInputField({
    required this.controller,
    required this.label,
    required this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(prefixIcon, size: 19),
        suffixIcon: suffixIcon,
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String? value;
  final String label;
  final IconData icon;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.value,
    required this.label,
    required this.icon,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: onChanged,
        dropdownColor: AppColors.surfaceContainerHigh,
        style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 19),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        icon: const Icon(Icons.expand_more, color: AppColors.onSurfaceVariant),
        items: items
            .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 14)),
                ))
            .toList(),
      ),
    );
  }
}
