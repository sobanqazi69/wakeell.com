import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/debug_logger.dart';
import '../../../../core/widgets/city_picker.dart';
import '../../data/models/lawyer_model.dart';
import '../cubits/lawyer_profile_cubit.dart';
import '../cubits/lawyer_profile_state.dart';

const _kSpecializations = [
  'Corporate', 'Criminal', 'Family', 'Property', 'Immigration',
  'Tax', 'Labour', 'Civil', 'Intellectual Property', 'Banking',
  'Constitutional', 'Environmental', 'Insurance', 'Medical',
];

const _kLanguages = [
  'Urdu', 'English', 'Punjabi', 'Sindhi', 'Pashto',
  'Balochi', 'Saraiki', 'Arabic', 'Persian',
];

class LawyerProfileEditScreen extends StatefulWidget {
  const LawyerProfileEditScreen({super.key});

  @override
  State<LawyerProfileEditScreen> createState() => _LawyerProfileEditScreenState();
}

class _LawyerProfileEditScreenState extends State<LawyerProfileEditScreen> {
  static const _tag = 'LawyerProfileEditScreen';

  final _nameCtrl  = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _bioCtrl   = TextEditingController();
  final _rateCtrl  = TextEditingController();
  final _expCtrl   = TextEditingController();

  String _location = '';
  List<String> _specializations = [];
  List<String> _languages = [];
  bool _initialized = false;

  List<String> _cities = [];
  bool _citiesLoading = true;

  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchCities();
  }

  Future<void> _fetchCities() async {
    try {
      final res = await Dio().get<Map<String, dynamic>>(
        'https://wakeell.microdesk.tech/api/cities',
        queryParameters: {'country': 'Pakistan'},
        options: Options(receiveTimeout: const Duration(seconds: 12), sendTimeout: const Duration(seconds: 8)),
      );
      final data = res.data;
      if (data != null && data['success'] == true && data['data'] is List) {
        final raw = (data['data'] as List).cast<String>();
        if (mounted) setState(() { _cities = [...raw, 'Other']; _citiesLoading = false; });
      } else { throw Exception('bad format'); }
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      context.read<LawyerProfileCubit>().load();
    }
  }

  void _populate(LawyerModel l) {
    if (_nameCtrl.text.isEmpty) {
      _nameCtrl.text  = l.name;
      _phoneCtrl.text = l.phone ?? '';
      _bioCtrl.text   = l.bio;
      _rateCtrl.text  = l.hourlyRate > 0 ? l.hourlyRate.toStringAsFixed(0) : '';
      _expCtrl.text   = l.experience > 0 ? '${l.experience}' : '';
      _location       = l.location ?? '';
      _specializations = List.from(l.specializations);
      _languages       = List.from(l.languages);
    }
  }

  void _save() {
    final rate = double.tryParse(_rateCtrl.text.trim()) ?? 0;
    final exp  = int.tryParse(_expCtrl.text.trim()) ?? 0;
    context.read<LawyerProfileCubit>().save(
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      location: _location,
      bio: _bioCtrl.text.trim(),
      specializations: _specializations,
      languages: _languages,
      hourlyRate: rate,
      experience: exp,
    );
  }

  String _resolveAvatar(String? relative) {
    if (relative == null || relative.isEmpty) return '';
    if (relative.startsWith('http')) return relative;
    return '${ApiClient.baseUrl.replaceAll('/api', '')}$relative';
  }

  Future<void> _pickAndUpload(ImageSource source) async {
    try {
      final photo = await _picker.pickImage(source: source, imageQuality: 85, maxWidth: 800);
      if (photo == null || !mounted) return;
      context.read<LawyerProfileCubit>().uploadAvatar(photo);
    } catch (e) {
      DebugLogger.error(_tag, 'pickAndUpload: $e');
    }
  }

  void _showAvatarOptions(LawyerModel lawyer) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 36, height: 4, margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(color: AppColors.fieldBorder, borderRadius: BorderRadius.circular(2))),
          Text('Profile Photo', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          _SheetOption(icon: Icons.camera_alt_outlined, label: 'Take Photo',
            onTap: () { Navigator.pop(context); _pickAndUpload(ImageSource.camera); }),
          _SheetOption(icon: Icons.photo_library_outlined, label: 'Choose from Gallery',
            onTap: () { Navigator.pop(context); _pickAndUpload(ImageSource.gallery); }),
          if (lawyer.avatar != null && lawyer.avatar!.isNotEmpty)
            _SheetOption(icon: Icons.delete_outline, label: 'Remove Photo', isDestructive: true,
              onTap: () { Navigator.pop(context); context.read<LawyerProfileCubit>().removeAvatar(); }),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _phoneCtrl.dispose(); _bioCtrl.dispose();
    _rateCtrl.dispose(); _expCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LawyerProfileCubit, LawyerProfileState>(
      listener: (context, state) {
        if (state is LawyerProfileLoaded || state is LawyerProfileSaved) {
          final l = state is LawyerProfileLoaded ? state.lawyer : (state as LawyerProfileSaved).lawyer;
          setState(() => _populate(l));
        }
        if (state is LawyerProfileSaved) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Profile saved successfully', style: GoogleFonts.outfit(color: Colors.white)),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ));
          Navigator.pop(context, true);
        }
        if (state is LawyerProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message, style: GoogleFonts.outfit(color: Colors.white)),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ));
        }
      },
      builder: (context, state) {
        final isSaving  = state is LawyerProfileSaving;
        final isLoading = state is LawyerProfileLoading || state is LawyerProfileInitial;
        final isAvatarUpdating = state is LawyerProfileAvatarUpdating;

        final lawyer = switch (state) {
          LawyerProfileLoaded s       => s.lawyer,
          LawyerProfileSaving s       => s.lawyer,
          LawyerProfileAvatarUpdating s => s.lawyer,
          _ => null,
        };

        return Scaffold(
          backgroundColor: AppColors.bg,
          body: Column(children: [

            // ── Header ──────────────────────────────────────────────────
            Container(
              color: AppColors.navy,
              padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 12, 20, 20),
              child: Row(children: [
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
                  Text('Edit Profile', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                  Text('Personal & professional info', style: GoogleFonts.outfit(fontSize: 12, color: Colors.white60)),
                ])),
                if (!isLoading)
                  GestureDetector(
                    onTap: isSaving ? null : _save,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                      decoration: BoxDecoration(
                        color: isSaving ? Colors.white24 : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: isSaving
                          ? SizedBox(width: 16, height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.navy))
                          : Text('Save', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.navy)),
                    ),
                  ),
              ]),
            ),

            if (isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator(color: AppColors.navy, strokeWidth: 2)))
            else
              Expanded(child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
                children: [

                  // ── Avatar Section ──────────────────────────────────────
                  if (lawyer != null) ...[
                    Center(child: GestureDetector(
                      onTap: () => _showAvatarOptions(lawyer),
                      child: Stack(clipBehavior: Clip.none, children: [
                        // Avatar circle
                        Container(
                          width: 90, height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.fieldBorder, width: 2),
                          ),
                          child: ClipOval(child: _buildAvatarContent(lawyer, isAvatarUpdating)),
                        ),
                        // Camera badge
                        Positioned(
                          bottom: 0, right: 0,
                          child: Container(
                            width: 28, height: 28,
                            decoration: BoxDecoration(
                              color: AppColors.navy,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.bg, width: 2),
                            ),
                            child: isAvatarUpdating
                                ? const Padding(
                                    padding: EdgeInsets.all(6),
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                          ),
                        ),
                      ]),
                    )),
                    const SizedBox(height: 6),
                    Center(child: Text(
                      'Tap to change photo',
                      style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
                    )),
                    const SizedBox(height: 24),
                  ],

                  // ── Personal ──────────────────────────────────────────────
                  _SectionLabel('Personal'),
                  const SizedBox(height: 12),
                  _Field(label: 'Full Name', controller: _nameCtrl, icon: Icons.person_outline),
                  const SizedBox(height: 12),
                  _Field(label: 'Phone Number', controller: _phoneCtrl, icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone),
                  const SizedBox(height: 12),
                  CityPickerField(
                    value: _location.isEmpty ? null : _location,
                    cities: _cities,
                    isLoading: _citiesLoading,
                    onSelected: (c) => setState(() => _location = c),
                  ),
                  const SizedBox(height: 28),

                  // ── Professional ──────────────────────────────────────────
                  _SectionLabel('Professional'),
                  const SizedBox(height: 12),
                  _Field(
                    label: 'Bio',
                    controller: _bioCtrl,
                    icon: Icons.notes_rounded,
                    maxLines: 4,
                    hint: 'Describe your background, expertise and approach…',
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: _Field(
                      label: 'Consultation Fee (PKR)',
                      controller: _rateCtrl,
                      icon: Icons.attach_money_rounded,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: _Field(
                      label: 'Experience (yrs)',
                      controller: _expCtrl,
                      icon: Icons.work_outline_rounded,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    )),
                  ]),
                  const SizedBox(height: 20),

                  // ── Specializations ───────────────────────────────────────
                  _MultiSelect(
                    title: 'Practice Areas',
                    subtitle: 'Select all that apply',
                    options: _kSpecializations,
                    selected: _specializations,
                    onChanged: (v) => setState(() => _specializations = v),
                  ),
                  const SizedBox(height: 20),

                  // ── Languages ─────────────────────────────────────────────
                  _MultiSelect(
                    title: 'Languages',
                    subtitle: 'Languages you consult in',
                    options: _kLanguages,
                    selected: _languages,
                    onChanged: (v) => setState(() => _languages = v),
                  ),
                ],
              )),
          ]),
        );
      },
    );
  }

  Widget _buildAvatarContent(LawyerModel lawyer, bool isUpdating) {
    final avatarUrl = _resolveAvatar(lawyer.avatar);
    if (avatarUrl.isNotEmpty) {
      return Image.network(
        avatarUrl,
        width: 90, height: 90, fit: BoxFit.cover,
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return Container(
            color: AppColors.navy,
            child: const Center(child: SizedBox(width: 20, height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54))),
          );
        },
        errorBuilder: (context2, err, stack) => _initialsAvatar(lawyer),
      );
    }
    return _initialsAvatar(lawyer);
  }

  Widget _initialsAvatar(LawyerModel lawyer) {
    return Container(
      color: AppColors.navy,
      child: Center(child: Text(
        lawyer.initials,
        style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white),
      )),
    );
  }
}

// ─── Bottom Sheet Option ──────────────────────────────────────────────────────

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SheetOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

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

// ─── Field ────────────────────────────────────────────────────────────────────

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final int maxLines;
  final String? hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const _Field({
    required this.label,
    required this.controller,
    required this.icon,
    this.maxLines = 1,
    this.hint,
    this.keyboardType,
    this.inputFormatters,
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
          border: Border.all(color: AppColors.fieldBorder),
        ),
        child: TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint ?? label,
            hintStyle: GoogleFonts.outfit(fontSize: 13, color: AppColors.textHint),
            prefixIcon: Padding(padding: const EdgeInsets.only(top: 2), child: Icon(icon, size: 18, color: AppColors.textSecondary)),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: maxLines > 1 ? 14 : 0, horizontal: maxLines > 1 ? 14 : 0),
          ),
        ),
      ),
    ]);
  }
}

// ─── MultiSelect ─────────────────────────────────────────────────────────────

class _MultiSelect extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<String> options;
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;

  const _MultiSelect({
    required this.title,
    required this.subtitle,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.fieldBorder),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            Text(subtitle, style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary)),
          ])),
          Text('${selected.length} selected', style: GoogleFonts.outfit(fontSize: 11, color: AppColors.navy, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 14),
        Wrap(spacing: 8, runSpacing: 8, children: options.map((opt) {
          final isOn = selected.contains(opt);
          return GestureDetector(
            onTap: () {
              final updated = List<String>.from(selected);
              isOn ? updated.remove(opt) : updated.add(opt);
              onChanged(updated);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: isOn ? AppColors.navy : AppColors.bg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isOn ? AppColors.navy : AppColors.fieldBorder),
              ),
              child: Text(opt, style: GoogleFonts.outfit(
                fontSize: 12, fontWeight: FontWeight.w600,
                color: isOn ? Colors.white : AppColors.textSecondary,
              )),
            ),
          );
        }).toList()),
      ]),
    );
  }
}

// ─── Section label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 3, height: 16, decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 8),
      Text(text, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: 0.3)),
    ]);
  }
}
