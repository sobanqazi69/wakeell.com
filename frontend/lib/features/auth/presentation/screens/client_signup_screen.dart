import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/utils/debug_logger.dart';
import '../cubits/auth_cubit.dart';
import '../cubits/auth_state.dart';

class ClientSignupScreen extends StatefulWidget {
  const ClientSignupScreen({super.key});

  @override
  State<ClientSignupScreen> createState() => _ClientSignupScreenState();
}

class _ClientSignupScreenState extends State<ClientSignupScreen> {
  static const _tag = 'ClientSignupScreen';

  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _agreed = false;
  String? _selectedLocation;
  String? _selectedJurisdiction;

  List<String> _cities = [];
  bool _citiesLoading = true;
  String? _citiesError;

  final _jurisdictions = ['Common Law', 'Civil Law', 'Sharia Law', 'International'];

  @override
  void initState() {
    super.initState();
    _fetchCities();
  }

  Future<void> _fetchCities() async {
    try {
      final response = await Dio().post<Map<String, dynamic>>(
        'https://countriesnow.space/api/v0.1/countries/cities',
        data: {'country': 'Pakistan'},
        options: Options(
          headers: {'Content-Type': 'application/json'},
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
      );

      final data = response.data;
      if (data != null && data['error'] == false && data['data'] is List) {
        final raw = (data['data'] as List).cast<String>();
        raw.sort();
        if (mounted) {
          setState(() {
            _cities = [...raw, 'Other'];
            _citiesLoading = false;
          });
        }
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      DebugLogger.error(_tag, 'Failed to fetch cities: $e');
      if (mounted) {
        setState(() {
          _cities = _fallbackCities;
          _citiesLoading = false;
          _citiesError = 'Using offline city list';
        });
      }
    }
  }

  static const _fallbackCities = [
    'Bahawalpur', 'Faisalabad', 'Gujranwala', 'Hyderabad', 'Islamabad',
    'Karachi', 'Lahore', 'Multan', 'Peshawar', 'Quetta', 'Rawalpindi',
    'Sialkot', 'Sukkur', 'Other',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreed) {
      AppSnackbar.error(context, 'Please accept the legal service agreements to continue.');
      return;
    }
    context.read<AuthCubit>().registerClient(
          name: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          location: _selectedLocation,
          jurisdiction: _selectedJurisdiction,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false);
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
                    Text('STEP 01/02', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 1)),
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
                        const SizedBox(height: 8),
                        Text('Create Client\nAccount',
                          style: GoogleFonts.outfit(fontSize: 30, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.2)),
                        const SizedBox(height: 10),
                        Text('Secure your identity in the legal marketplace.',
                          style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
                        const SizedBox(height: 28),

                        // Full Name
                        const _FieldLabel(label: 'FULL NAME'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _nameCtrl,
                          textInputAction: TextInputAction.next,
                          style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 14),
                          decoration: const InputDecoration(hintText: 'Jonathan Sterling', prefixIcon: Icon(Icons.person_outline, size: 18)),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Full name is required' : null,
                        ),
                        const SizedBox(height: 18),

                        // Email
                        const _FieldLabel(label: 'WORK EMAIL'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 14),
                          decoration: const InputDecoration(hintText: 'j.sterling@firm.com', prefixIcon: Icon(Icons.alternate_email, size: 18)),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Email is required';
                            if (!v.contains('@')) return 'Enter a valid email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        // Password
                        const _FieldLabel(label: 'SECURE PASSWORD'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _passwordCtrl,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: '••••••••••••',
                            prefixIcon: const Icon(Icons.lock_outline, size: 18),
                            suffixIcon: GestureDetector(
                              onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                              child: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.textSecondary, size: 20),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Password is required';
                            if (v.length < 6) return 'Password must be at least 6 characters';
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        // Primary Location
                        const _FieldLabel(label: 'PRIMARY LOCATION'),
                        const SizedBox(height: 6),
                        if (_citiesError != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(_citiesError!, style: GoogleFonts.outfit(fontSize: 10, color: AppColors.textHint)),
                          ),
                        _CityDropdown(
                          value: _selectedLocation,
                          cities: _cities,
                          isLoading: _citiesLoading,
                          onChanged: (v) => setState(() => _selectedLocation = v),
                        ),
                        const SizedBox(height: 18),

                        // Jurisdiction
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

                        // Agreement checkbox
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 20, height: 20,
                              child: Checkbox(
                                value: _agreed,
                                onChanged: (v) => setState(() => _agreed = v ?? false),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'I acknowledge the Legal Service Agreements and consent to Bi-ometric Data Processing protocols',
                                style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary, height: 1.5),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // Submit button
                        BlocBuilder<AuthCubit, AuthState>(
                          builder: (context, state) {
                            final isLoading = state is AuthLoading;
                            return GestureDetector(
                              onTap: isLoading ? null : _submit,
                              child: Container(
                                width: double.infinity,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: isLoading ? AppColors.navy.withValues(alpha: 0.6) : AppColors.navy,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: isLoading
                                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                      : Text('Create Account', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        // Sign in link
                        Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Already have an account? ', style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary)),
                              GestureDetector(
                                onTap: () => Navigator.pushNamed(context, AppRoutes.login),
                                child: Text('Sign In', style: GoogleFonts.outfit(fontSize: 13, color: AppColors.navy, fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        Center(
                          child: Text(
                            'ISO 27001 Certified  •  SOC2 Type II Compliant  •  256-bit AES Encryption',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(fontSize: 10, color: AppColors.textHint, height: 1.6),
                          ),
                        ),
                        const SizedBox(height: 24),
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
}

// ---------- City dropdown with loading state ----------

class _CityDropdown extends StatelessWidget {
  final String? value;
  final List<String> cities;
  final bool isLoading;
  final ValueChanged<String?> onChanged;

  const _CityDropdown({required this.value, required this.cities, required this.isLoading, required this.onChanged});

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
          const Icon(Icons.location_on_outlined, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: isLoading
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 14, height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.navy),
                        ),
                        const SizedBox(width: 10),
                        Text('Loading cities...', style: GoogleFonts.outfit(color: AppColors.textHint, fontSize: 14)),
                      ],
                    ),
                  )
                : DropdownButton<String>(
                    value: value,
                    onChanged: onChanged,
                    hint: Text('Select City, Pakistan', style: GoogleFonts.outfit(color: AppColors.textHint, fontSize: 14)),
                    isExpanded: true,
                    underline: const SizedBox.shrink(),
                    dropdownColor: AppColors.surface,
                    menuMaxHeight: 300,
                    style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 14),
                    icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary, size: 20),
                    items: cities.map((city) {
                      final isOther = city == 'Other';
                      return DropdownMenuItem<String>(
                        value: city,
                        child: Text(
                          city,
                          style: GoogleFonts.outfit(
                            color: isOther ? AppColors.navyMid : AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: isOther ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

// ---------- Generic dropdown ----------

class _DropdownField extends StatelessWidget {
  final String? value;
  final String hint;
  final IconData icon;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField({required this.value, required this.hint, required this.icon, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.fieldBorder)),
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
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 14)))).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Shared label ----------

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) => Text(
        label,
        style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 0.8),
      );
}
