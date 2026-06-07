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
                  Text(
                    'STEP 01/02',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      letterSpacing: 1,
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
                    const SizedBox(height: 8),

                    // Title
                    Text(
                      'Create Client\nAccount',
                      style: GoogleFonts.outfit(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Secure your identity in the legal marketplace.',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Form fields
                    _FieldLabel(label: 'FULL NAME'),
                    const SizedBox(height: 6),
                    _InputField(
                      controller: _nameCtrl,
                      hint: 'Jonathan Sterling',
                      prefixIcon: Icons.person_outline,
                    ),
                    const SizedBox(height: 18),

                    const _FieldLabel(label: 'WORK EMAIL'),
                    const SizedBox(height: 6),
                    _InputField(
                      controller: _emailCtrl,
                      hint: 'j.sterling@firm.com',
                      prefixIcon: Icons.alternate_email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 18),

                    const _FieldLabel(label: 'SECURE PASSWORD'),
                    const SizedBox(height: 6),
                    _InputField(
                      controller: _passwordCtrl,
                      hint: '••••••••••••',
                      prefixIcon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      suffixIcon: GestureDetector(
                        onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                        child: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    const _FieldLabel(label: 'PRIMARY LOCATION'),
                    const SizedBox(height: 6),
                    _DropdownField(
                      value: _selectedLocation,
                      hint: 'Select City',
                      icon: Icons.location_on_outlined,
                      items: _locations,
                      onChanged: (v) => setState(() => _selectedLocation = v),
                    ),
                    const SizedBox(height: 18),

                    const _FieldLabel(label: 'JURISDICTION'),
                    const SizedBox(height: 6),
                    _DropdownField(
                      value: _selectedJurisdiction,
                      hint: 'Select Law',
                      icon: Icons.account_balance_outlined,
                      items: _jurisdictions,
                      onChanged: (v) => setState(() => _selectedJurisdiction = v),
                    ),
                    const SizedBox(height: 24),

                    // Checkbox
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: Checkbox(
                            value: _agreed,
                            onChanged: (v) => setState(() => _agreed = v ?? false),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'I acknowledge the Legal Service Agreements and consent to Bi-ometric Data Processing protocols',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Create account button
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.navy,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            'Create Account',
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Sign in link
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(context, AppRoutes.login),
                            child: Text(
                              'Sign In',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                color: AppColors.navy,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
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
                          color: AppColors.textHint,
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
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;

  const _InputField({
    required this.controller,
    required this.hint,
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
        hintText: hint,
        prefixIcon: Icon(prefixIcon, size: 18),
        suffixIcon: suffixIcon,
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String? value;
  final String hint;
  final IconData icon;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.value,
    required this.hint,
    required this.icon,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.fieldBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButton<String>(
              value: value,
              onChanged: onChanged,
              hint: Text(hint, style: GoogleFonts.outfit(color: AppColors.textHint, fontSize: 14)),
              isExpanded: true,
              underline: const SizedBox.shrink(),
              dropdownColor: AppColors.surface,
              style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 14),
              icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary, size: 20),
              items: items
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e, style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 14)),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
