import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/utils/debug_logger.dart';
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

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _saving = false;
  bool _uploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthCubit>().currentUser;
    if (user != null) {
      _nameCtrl.text = user.name;
      _phoneCtrl.text = user.phone ?? '';
      _locationCtrl.text = user.location ?? '';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadAvatar() async {
    try {
      final picker = ImagePicker();
      final photo = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 512,
      );
      if (photo == null || !mounted) return;

      setState(() => _uploadingAvatar = true);
      await context.read<AuthCubit>().uploadAvatar(photo);
      if (!mounted) return;
      setState(() => _uploadingAvatar = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Profile photo updated',
            style: GoogleFonts.outfit(color: Colors.white)),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ));
    } catch (e) {
      DebugLogger.error(_tag, 'uploadAvatar: $e');
      if (mounted) {
        setState(() => _uploadingAvatar = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to upload photo',
              style: GoogleFonts.outfit(color: Colors.white)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      setState(() => _saving = true);
      final updated = await getIt<AuthRepository>().updateMe(
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        location: _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim(),
      );
      if (!mounted) return;
      context.read<AuthCubit>().updateUser(updated);
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Profile saved',
            style: GoogleFonts.outfit(color: Colors.white)),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ));
    } catch (e) {
      DebugLogger.error(_tag, 'save: $e');
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to save profile',
              style: GoogleFonts.outfit(color: Colors.white)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  String _resolveAvatar(String? relative) {
    if (relative == null || relative.isEmpty) return '';
    if (relative.startsWith('http')) return relative;
    return '${ApiClient.baseUrl.replaceAll('/api', '')}$relative';
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
            // Header
            Container(
              color: AppColors.navy,
              padding: EdgeInsets.fromLTRB(
                  20, MediaQuery.of(context).padding.top + 12, 20, 24),
              child: Column(children: [
                Row(children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back,
                          color: Colors.white, size: 18),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('My Profile',
                              style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                          Text('Update your information',
                              style: GoogleFonts.outfit(
                                  fontSize: 12, color: Colors.white60)),
                        ]),
                  ),
                  if (_saving)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  else
                    GestureDetector(
                      onTap: _save,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 9),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20)),
                        child: Text('Save',
                            style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.navy)),
                      ),
                    ),
                ]),
                const SizedBox(height: 24),

                // Avatar
                GestureDetector(
                  onTap: _uploadingAvatar ? null : _pickAndUploadAvatar,
                  child: Stack(children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 2),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _uploadingAvatar
                          ? const Center(
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : avatarUrl.isNotEmpty
                              ? Image.network(avatarUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Center(
                                      child: Text(
                                          _initials(user.name),
                                          style: GoogleFonts.outfit(
                                              fontSize: 30,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white))))
                              : Center(
                                  child: Text(
                                    _initials(user.name),
                                    style: GoogleFonts.outfit(
                                        fontSize: 30,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white),
                                  ),
                                ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                            color: AppColors.cyan, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt_rounded,
                            size: 14, color: Colors.black87),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 8),
                Text(user.name,
                    style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                Text(user.email,
                    style: GoogleFonts.outfit(
                        fontSize: 12, color: Colors.white60)),
              ]),
            ),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(children: [
                    _FieldCard(
                      label: 'Full Name',
                      icon: Icons.person_outline_rounded,
                      child: TextFormField(
                        controller: _nameCtrl,
                        style: GoogleFonts.outfit(
                            color: AppColors.textPrimary, fontSize: 14),
                        decoration: _inputDec('Enter your name'),
                        validator: (v) =>
                            (v?.trim().isEmpty ?? true) ? 'Name is required' : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _FieldCard(
                      label: 'Phone Number',
                      icon: Icons.phone_outlined,
                      child: TextFormField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        style: GoogleFonts.outfit(
                            color: AppColors.textPrimary, fontSize: 14),
                        decoration: _inputDec('e.g. +92 300 0000000'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _FieldCard(
                      label: 'City / Location',
                      icon: Icons.location_on_outlined,
                      child: TextFormField(
                        controller: _locationCtrl,
                        style: GoogleFonts.outfit(
                            color: AppColors.textPrimary, fontSize: 14),
                        decoration: _inputDec('e.g. Lahore'),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Email (read-only)
                    _FieldCard(
                      label: 'Email Address',
                      icon: Icons.email_outlined,
                      child: TextFormField(
                        initialValue: user.email,
                        readOnly: true,
                        style: GoogleFonts.outfit(
                            color: AppColors.textHint, fontSize: 14),
                        decoration: _inputDec(''),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ]);
        },
      ),
    );
  }

  InputDecoration _inputDec(String hint) => InputDecoration(
        hintText: hint,
        hintStyle:
            GoogleFonts.outfit(color: AppColors.textHint, fontSize: 13),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        isDense: true,
      );

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }
}

class _FieldCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Widget child;
  const _FieldCard(
      {required this.label, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.fieldBorder),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(label,
              style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary)),
        ]),
        child,
      ]),
    );
  }
}

