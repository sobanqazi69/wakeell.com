import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/theme/app_colors.dart';
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

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  final _expCtrl = TextEditingController();

  String _location = '';
  List<String> _specializations = [];
  List<String> _languages = [];
  bool _initialized = false;

  List<String> _cities = [];
  bool _citiesLoading = true;

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
      _nameCtrl.text = l.name;
      _phoneCtrl.text = l.phone ?? '';
      _bioCtrl.text = l.bio;
      _rateCtrl.text = l.hourlyRate > 0 ? l.hourlyRate.toStringAsFixed(0) : '';
      _expCtrl.text = l.experience > 0 ? '${l.experience}' : '';
      _location = l.location ?? '';
      _specializations = List.from(l.specializations);
      _languages = List.from(l.languages);
    }
  }

  void _save() {
    final rate = double.tryParse(_rateCtrl.text.trim()) ?? 0;
    final exp = int.tryParse(_expCtrl.text.trim()) ?? 0;
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
        final isSaving = state is LawyerProfileSaving;
        final isLoading = state is LawyerProfileLoading || state is LawyerProfileInitial;

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
                          ? SizedBox(
                              width: 16, height: 16,
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
                  // ── Personal ─────────────────────────────────────────────
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
                fontSize: 12,
                fontWeight: FontWeight.w600,
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
