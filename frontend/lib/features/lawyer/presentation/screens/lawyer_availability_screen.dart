import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/theme/app_colors.dart';
import '../cubits/lawyer_availability_cubit.dart';
import '../cubits/lawyer_availability_state.dart';

// ─── Constants ────────────────────────────────────────────────────────────────

const _kDays     = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _kFullDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

const _kSlots = [
  '00:00', '00:30', '01:00', '01:30', '02:00', '02:30',
  '03:00', '03:30', '04:00', '04:30', '05:00', '05:30',
  '06:00', '06:30', '07:00', '07:30', '08:00', '08:30',
  '09:00', '09:30', '10:00', '10:30', '11:00', '11:30',
  '12:00', '12:30', '13:00', '13:30', '14:00', '14:30',
  '15:00', '15:30', '16:00', '16:30', '17:00', '17:30',
  '18:00', '18:30', '19:00', '19:30', '20:00', '20:30',
  '21:00', '21:30', '22:00', '22:30', '23:00', '23:30',
];

const _kBg      = Color(0xFF0A0818);
const _kCard    = Color(0xFF13102A);
const _kBorder  = Color(0xFF1E1B38);

// ─── Day range model (local UI state) ────────────────────────────────────────

class _DayRange {
  final bool enabled;
  final String from; // e.g. '09:00'
  final String to;   // e.g. '17:00'
  const _DayRange({this.enabled = false, this.from = '09:00', this.to = '17:00'});

  _DayRange copyWith({bool? enabled, String? from, String? to}) => _DayRange(
    enabled: enabled ?? this.enabled,
    from: from ?? this.from,
    to: to ?? this.to,
  );

  List<String> get slots {
    final si = _kSlots.indexOf(from);
    final ei = _kSlots.indexOf(to);
    if (!enabled || si < 0 || ei < 0 || ei <= si) return [];
    return _kSlots.sublist(si, ei + 1);
  }

  int get slotCount => slots.length;
}

_DayRange _rangeFromSlots(List<String> savedSlots) {
  if (savedSlots.isEmpty) return const _DayRange();
  final sorted = [...savedSlots]
    ..sort((a, b) => _kSlots.indexOf(a).compareTo(_kSlots.indexOf(b)));
  return _DayRange(enabled: true, from: sorted.first, to: sorted.last);
}

String _fmtSlot(String slot) {
  final parts = slot.split(':');
  final h = int.parse(parts[0]);
  final m = parts[1];
  final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
  return '$h12:$m ${h < 12 ? 'AM' : 'PM'}';
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class LawyerAvailabilityScreen extends StatefulWidget {
  const LawyerAvailabilityScreen({super.key});

  @override
  State<LawyerAvailabilityScreen> createState() => _LawyerAvailabilityScreenState();
}

class _LawyerAvailabilityScreenState extends State<LawyerAvailabilityScreen> {
  int _day = 0;
  final _ranges = List<_DayRange>.filled(7, const _DayRange(), growable: false);
  bool _hydrated = false;

  void _hydrate(Map<int, List<String>> schedule) {
    if (_hydrated) return;
    _hydrated = true;
    for (var i = 0; i < 7; i++) {
      _ranges[i] = _rangeFromSlots(schedule[i] ?? []);
    }
  }

  Map<int, List<String>> get _schedule {
    final map = <int, List<String>>{};
    for (var i = 0; i < 7; i++) {
      final s = _ranges[i].slots;
      if (s.isNotEmpty) map[i] = s;
    }
    return map;
  }

  Future<void> _pickTime(bool isFrom) async {
    final current = isFrom ? _ranges[_day].from : _ranges[_day].to;
    final initial = _kSlots.indexOf(current).clamp(0, _kSlots.length - 1);
    final picked = await _showTimePicker(context, initial);
    if (picked == null || !mounted) return;

    setState(() {
      final r = _ranges[_day];
      if (isFrom) {
        final toIdx   = _kSlots.indexOf(r.to);
        final fromIdx = _kSlots.indexOf(picked);
        _ranges[_day] = r.copyWith(
          from: picked,
          to: (toIdx <= fromIdx) ? _kSlots[(fromIdx + 2).clamp(0, _kSlots.length - 1)] : null,
        );
      } else {
        final fromIdx = _kSlots.indexOf(r.from);
        final toIdx   = _kSlots.indexOf(picked);
        _ranges[_day] = r.copyWith(
          to: (toIdx <= fromIdx) ? _kSlots[(fromIdx + 2).clamp(0, _kSlots.length - 1)] : picked,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LawyerAvailabilityCubit, LawyerAvailabilityState>(
      listener: (ctx, state) {
        if (state is LawyerAvailabilityLoaded && !_hydrated) {
          setState(() => _hydrate(state.schedule));
        }
        if (state is LawyerAvailabilitySaved) {
          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
            content: Text('Saved for 4 weeks', style: GoogleFonts.outfit(color: Colors.white)),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ));
        }
        if (state is LawyerAvailabilityError) {
          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
            content: Text(state.message, style: GoogleFonts.outfit(color: Colors.white)),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ));
        }
      },
      builder: (ctx, state) {
        final isSaving = state is LawyerAvailabilitySaving;
        final isLoaded = state is LawyerAvailabilityLoaded || state is LawyerAvailabilitySaved;

        if (isLoaded && !_hydrated) {
          final schedule = state is LawyerAvailabilityLoaded ? state.schedule : <int, List<String>>{};
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _hydrate(schedule));
          });
        }

        final r = _ranges[_day];

        return Scaffold(
          backgroundColor: _kBg,
          body: SafeArea(
            child: Column(children: [

              // ── Top bar ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Row(children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: _kCard,
                        shape: BoxShape.circle,
                        border: Border.all(color: _kBorder),
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white54, size: 18),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text('Availability',
                        style: GoogleFonts.outfit(
                            fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                  if (isLoaded)
                    GestureDetector(
                      onTap: isSaving ? null : () =>
                          context.read<LawyerAvailabilityCubit>().save(_schedule),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSaving ? _kCard : Colors.white,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: isSaving
                            ? const SizedBox(width: 16, height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black38))
                            : Text('Save',
                                style: GoogleFonts.outfit(
                                    fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black87)),
                      ),
                    ),
                ]),
              ),

              // ── Day picker ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                child: Row(
                  children: List.generate(7, (i) {
                    final isOn     = i == _day;
                    final hasSlots = _ranges[i].enabled;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _day = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          margin: EdgeInsets.only(right: i < 6 ? 6 : 0),
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          decoration: BoxDecoration(
                            color: isOn ? Colors.white : _kCard,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: isOn ? Colors.white : _kBorder),
                          ),
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            Text(_kDays[i],
                                style: GoogleFonts.outfit(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: isOn ? Colors.black87 : Colors.white30)),
                            const SizedBox(height: 5),
                            Container(
                              width: 4, height: 4,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: hasSlots
                                    ? (isOn ? const Color(0xFF6B46C1) : Colors.white30)
                                    : Colors.transparent,
                              ),
                            ),
                          ]),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // ── Loading ─────────────────────────────────────────────
              if (!isLoaded)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white24, strokeWidth: 2),
                  ),
                ),

              // ── Day config card ─────────────────────────────────────
              if (isLoaded) ...[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                      // Day name + toggle
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: _kCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _kBorder),
                        ),
                        child: Row(children: [
                          Text(_kFullDays[_day],
                              style: GoogleFonts.outfit(
                                  fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                          const Spacer(),
                          _MinimalSwitch(
                            value: r.enabled,
                            onChanged: (v) => setState(() =>
                                _ranges[_day] = _ranges[_day].copyWith(enabled: v)),
                          ),
                        ]),
                      ),
                      const SizedBox(height: 12),

                      // From / To pickers
                      AnimatedOpacity(
                        opacity: r.enabled ? 1.0 : 0.3,
                        duration: const Duration(milliseconds: 200),
                        child: IgnorePointer(
                          ignoring: !r.enabled,
                          child: Row(children: [
                            Expanded(child: _TimePill(
                              label: 'From',
                              value: _fmtSlot(r.from),
                              onTap: () => _pickTime(true),
                            )),
                            const SizedBox(width: 12),
                            // Arrow
                            Icon(Icons.arrow_forward_rounded,
                                color: Colors.white.withValues(alpha: 0.16), size: 18),
                            const SizedBox(width: 12),
                            Expanded(child: _TimePill(
                              label: 'To',
                              value: _fmtSlot(r.to),
                              onTap: () => _pickTime(false),
                            )),
                          ]),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Slot count hint
                      if (r.enabled && r.slotCount > 0)
                        Text(
                          '${r.slotCount} slot${r.slotCount == 1 ? '' : 's'} · every 30 min',
                          style: GoogleFonts.outfit(
                              fontSize: 12, color: Colors.white24),
                        ),

                      const Spacer(),

                      // Week summary
                      _WeekSummary(ranges: _ranges),
                    ]),
                  ),
                ),
              ],
            ]),
          ),
        );
      },
    );
  }
}

// ─── Time picker bottom sheet ─────────────────────────────────────────────────

Future<String?> _showTimePicker(BuildContext context, int initialIndex) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _TimePickerSheet(initialIndex: initialIndex),
  );
}

class _TimePickerSheet extends StatefulWidget {
  final int initialIndex;
  const _TimePickerSheet({required this.initialIndex});

  @override
  State<_TimePickerSheet> createState() => _TimePickerSheetState();
}

class _TimePickerSheetState extends State<_TimePickerSheet> {
  late int _selected;
  late ScrollController _scroll;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialIndex;
    _scroll = ScrollController(
      initialScrollOffset: (_selected * 52.0) - 104,
    );
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.55,
      decoration: const BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(children: [
        // Handle
        const SizedBox(height: 12),
        Container(
          width: 36, height: 4,
          decoration: BoxDecoration(
            color: Colors.white12,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 16),
        Text('Select Time',
            style: GoogleFonts.outfit(
                fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
        const SizedBox(height: 12),
        const Divider(color: _kBorder, height: 1),

        // Time list
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: _kSlots.length,
            itemExtent: 52,
            itemBuilder: (_, i) {
              final isOn = i == _selected;
              return GestureDetector(
                onTap: () {
                  setState(() => _selected = i);
                  Future.delayed(const Duration(milliseconds: 120), () {
                    if (mounted) Navigator.pop(context, _kSlots[i]);
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  margin: const EdgeInsets.fromLTRB(20, 3, 20, 3),
                  decoration: BoxDecoration(
                    color: isOn ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      _fmtSlot(_kSlots[i]),
                      style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: isOn ? FontWeight.w700 : FontWeight.w400,
                          color: isOn ? Colors.black87 : Colors.white38),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}

// ─── Time pill ────────────────────────────────────────────────────────────────

class _TimePill extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _TimePill({required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _kBorder),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: GoogleFonts.outfit(
                  fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white30)),
          const SizedBox(height: 6),
          Row(children: [
            Expanded(
              child: Text(value,
                  style: GoogleFonts.outfit(
                      fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
            const Icon(Icons.expand_more_rounded, color: Colors.white24, size: 18),
          ]),
        ]),
      ),
    );
  }
}

// ─── Minimal switch ───────────────────────────────────────────────────────────

class _MinimalSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _MinimalSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44, height: 24,
        decoration: BoxDecoration(
          color: value ? Colors.white : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 18, height: 18,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: value ? Colors.black87 : Colors.white24,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Week summary ─────────────────────────────────────────────────────────────

class _WeekSummary extends StatelessWidget {
  final List<_DayRange> ranges;
  const _WeekSummary({required this.ranges});

  @override
  Widget build(BuildContext context) {
    final activeDays = ranges
        .asMap()
        .entries
        .where((e) => e.value.enabled)
        .map((e) => _kDays[e.key])
        .toList();

    if (activeDays.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
      ),
      child: Row(children: [
        const Icon(Icons.calendar_month_outlined, size: 15, color: Colors.white24),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            activeDays.join(' · '),
            style: GoogleFonts.outfit(
                fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white38),
          ),
        ),
        Text(
          '${ranges.fold<int>(0, (s, r) => s + r.slotCount)} slots',
          style: GoogleFonts.outfit(
              fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white24),
        ),
      ]),
    );
  }
}
