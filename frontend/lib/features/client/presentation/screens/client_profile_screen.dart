import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/utils/debug_logger.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/city_picker.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../auth/presentation/cubits/auth_state.dart';

class ClientProfileScreen extends StatefulWidget {
  const ClientProfileScreen({super.key});

  @override
  State<ClientProfileScreen> createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen> {
  static const _tag = 'ClientProfileScreen';

  final _nameCtrl     = TextEditingController();
  final _phoneCtrl    = TextEditingController();
  final _formKey      = GlobalKey<FormState>();

  String _location    = '';
  bool _saving        = false;
  bool _uploadingAvatar = false;

  List<String> _cities      = [];
  bool _citiesLoading       = true;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthCubit>().currentUser;
    if (user != null) {
      _nameCtrl.text  = user.name;
      _phoneCtrl.text = user.phone ?? '';
      _location       = user.location ?? '';
    }
    _fetchCities();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchCities() async {
    try {
      final res = await Dio().get<Map<String, dynamic>>(
        'https://wakeell.microdesk.tech/api/cities',
        queryParameters: {'country': 'Pakistan'},
        options: Options(
          receiveTimeout: const Duration(seconds: 12),
          sendTimeout: const Duration(seconds: 8),
        ),
      );
      final data = res.data;
      if (data != null && data['success'] == true && data['data'] is List) {
        final raw = (data['data'] as List).cast<String>();
        if (mounted) setState(() { _cities = [...raw, 'Other']; _citiesLoading = false; });
      } else {
        throw Exception('bad format');
      }
    } catch (e) {
      DebugLogger.error(_tag, 'fetchCities: $e');
      if (mounted) {
        setState(() {
          _cities = ['Islamabad', 'Lahore', 'Karachi', 'Rawalpindi', 'Faisalabad', 'Multan', 'Peshawar', 'Quetta', 'Other'];
          _citiesLoading = false;
        });
      }
    }
  }

  void _showAvatarOptions(String? currentAvatar) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 36, height: 4, margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(color: AppColors.fieldBorder, borderRadius: BorderRadius.circular(2)),
        ),
        Text('Profile Photo', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        _SheetOption(icon: Icons.camera_alt_outlined, label: 'Take Photo',
          onTap: () { Navigator.pop(context); _pickAvatar(ImageSource.camera); }),
        _SheetOption(icon: Icons.photo_library_outlined, label: 'Choose from Gallery',
          onTap: () { Navigator.pop(context); _pickAvatar(ImageSource.gallery); }),
        if (currentAvatar != null && currentAvatar.isNotEmpty)
          _SheetOption(icon: Icons.delete_outline, label: 'Remove Photo', isDestructive: true,
            onTap: () { Navigator.pop(context); _removeAvatar(); }),
        const SizedBox(height: 8),
      ])),
    );
  }

  Future<void> _pickAvatar(ImageSource source) async {
    try {
      final photo = await ImagePicker().pickImage(source: source, imageQuality: 85, maxWidth: 512);
      if (photo == null || !mounted) return;
      setState(() => _uploadingAvatar = true);
      await context.read<AuthCubit>().uploadAvatar(photo);
      if (mounted) setState(() => _uploadingAvatar = false);
    } catch (e) {
      DebugLogger.error(_tag, 'pickAvatar: $e');
      if (mounted) {
        setState(() => _uploadingAvatar = false);
        AppSnackbar.error(context, 'Failed to upload photo');
      }
    }
  }

  Future<void> _removeAvatar() async {
    try {
      setState(() => _uploadingAvatar = true);
      final repo = getIt<AuthRepository>();
      final updated = await repo.removeAvatar();
      if (!mounted) return;
      context.read<AuthCubit>().updateUser(updated);
      setState(() => _uploadingAvatar = false);
    } catch (e) {
      DebugLogger.error(_tag, 'removeAvatar: $e');
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      setState(() => _saving = true);
      final updated = await getIt<AuthRepository>().updateMe(
        name:     _nameCtrl.text.trim(),
        phone:    _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        location: _location.isEmpty ? null : _location,
      );
      if (!mounted) return;
      context.read<AuthCubit>().updateUser(updated);
      setState(() => _saving = false);
      AppSnackbar.success(context, 'Profile saved');
    } catch (e) {
      DebugLogger.error(_tag, 'save: $e');
      if (mounted) {
        setState(() => _saving = false);
        AppSnackbar.error(context, 'Failed to save profile');
      }
    }
  }

  String _resolveAvatar(String? p) {
    if (p == null || p.isEmpty) return '';
    if (p.startsWith('http')) return p;
    return ApiClient.baseUrl.replaceAll('/api', '') + p;
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts.isNotEmpty && parts[0].isNotEmpty) return parts[0][0].toUpperCase();
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final user = state is AuthAuthenticated
              ? state.user
              : context.read<AuthCubit>().currentUser;
          if (user == null) return const SizedBox.shrink();

          final avatarUrl = _resolveAvatar(user.avatar);

          return Column(children: [
            // ── Header ──────────────────────────────────────────────────
            Container(
              color: AppColors.navy,
              padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 12, 20, 28),
              child: Column(children: [
                Row(children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('My Profile', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                    Text('Update your information', style: GoogleFonts.outfit(fontSize: 12, color: Colors.white60)),
                  ])),
                  GestureDetector(
                    onTap: _saving ? null : _save,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                      decoration: BoxDecoration(
                        color: _saving ? Colors.white24 : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: _saving
                          ? const SizedBox(width: 16, height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.navy))
                          : Text('Save', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.navy)),
                    ),
                  ),
                ]),
                const SizedBox(height: 24),

                // Avatar
                GestureDetector(
                  onTap: _uploadingAvatar ? null : () => _showAvatarOptions(user.avatar),
                  child: Stack(clipBehavior: Clip.none, children: [
                    Container(
                      width: 88, height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _uploadingAvatar
                          ? Container(color: AppColors.navyMid,
                              child: const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))
                          : avatarUrl.isNotEmpty
                              ? Image.network(avatarUrl, fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _InitialsBg(initials: _initials(user.name)))
                              : _InitialsBg(initials: _initials(user.name)),
                    ),
                    Positioned(
                      bottom: 0, right: 0,
                      child: Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.cyan, shape: BoxShape.circle,
                          border: Border.all(color: AppColors.navy, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.black87),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 8),
                Text(user.name, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                Text(user.email, style: GoogleFonts.outfit(fontSize: 12, color: Colors.white60)),
              ]),
            ),

            // ── Form ────────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 48),
                child: Form(
                  key: _formKey,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                    _SectionLabel('Personal'),
                    const SizedBox(height: 12),

                    _Field(
                      label: 'Full Name',
                      controller: _nameCtrl,
                      icon: Icons.person_outline_rounded,
                      validator: (v) => (v?.trim().isEmpty ?? true) ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 12),

                    _Field(
                      label: 'Phone Number',
                      controller: _phoneCtrl,
                      icon: Icons.phone_outlined,
                      hint: 'e.g. +92 300 0000000',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),

                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('City / Location',
                        style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      const SizedBox(height: 6),
                      CityPickerField(
                        value: _location.isEmpty ? null : _location,
                        cities: _cities,
                        isLoading: _citiesLoading,
                        onSelected: (c) => setState(() => _location = c),
                      ),
                    ]),
                    const SizedBox(height: 24),

                    _SectionLabel('Account'),
                    const SizedBox(height: 12),

                    // Email read-only
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Email Address',
                        style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      const SizedBox(height: 6),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: TextEditingController(text: user.email),
                          readOnly: true,
                          style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textHint),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.email_outlined, size: 18, color: AppColors.textSecondary),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ]),
                  ]),
                ),
              ),
            ),
          ]);
        },
      ),
    );
  }
}

// ─── Avatar initials background ───────────────────────────────────────────────

class _InitialsBg extends StatelessWidget {
  final String initials;
  const _InitialsBg({required this.initials});

  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.navyMid,
    child: Center(child: Text(initials,
      style: GoogleFonts.outfit(fontSize: 30, fontWeight: FontWeight.w700, color: Colors.white))),
  );
}

// ─── Section label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 3, height: 16,
      decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 8),
    Text(text, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: 0.3)),
  ]);
}

// ─── Field ────────────────────────────────────────────────────────────────────

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final String? hint;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _Field({
    required this.label,
    required this.controller,
    required this.icon,
    this.hint,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
      const SizedBox(height: 6),
      Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [AppColors.cardShadow(opacity: 0.04, blur: 8, offset: const Offset(0, 2))],
        ),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint ?? label,
            hintStyle: GoogleFonts.outfit(fontSize: 13, color: AppColors.textHint),
            prefixIcon: Icon(icon, size: 18, color: AppColors.textSecondary),
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    ]);
  }
}

// ─── Bottom sheet option ──────────────────────────────────────────────────────

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;
  const _SheetOption({required this.icon, required this.label, required this.onTap, this.isDestructive = false});

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.error : AppColors.textPrimary;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(width: 16),
          Text(label, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
        ]),
      ),
    );
  }
}
