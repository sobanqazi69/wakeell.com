import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/theme/app_colors.dart';
import '../cubits/lawyer_availability_cubit.dart';
import '../cubits/lawyer_availability_state.dart';

const _kDays     = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _kFullDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

// Slots shown in the grid: 6 AM – 10 PM (32 × 30-min blocks)
const _kGridSlots = [
  '06:00', '06:30', '07:00', '07:30', '08:00', '08:30',
  '09:00', '09:30', '10:00', '10:30', '11:00', '11:30',
  '12:00', '12:30', '13:00', '13:30', '14:00', '14:30',
  '15:00', '15:30', '16:00', '16:30', '17:00', '17:30',
  '18:00', '18:30', '19:00', '19:30', '20:00', '20:30',
  '21:00', '21:30',
];

String _fmt(String slot) {
  final parts = slot.split(':');
  final h  = int.parse(parts[0]);
  final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
  return '$h12:${parts[1]}${h < 12 ? 'am' : 'pm'}';
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class LawyerAvailabilityScreen extends StatefulWidget {
  const LawyerAvailabilityScreen({super.key});

  @override
  State<LawyerAvailabilityScreen> createState() => _LawyerAvailabilityScreenState();
}

class _LawyerAvailabilityScreenState extends State<LawyerAvailabilityScreen> {
  int _day = 0;
  Map<int, List<String>> _lastSchedule = {};

  @override
  void initState() {
    super.initState();
    context.read<LawyerAvailabilityCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LawyerAvailabilityCubit, LawyerAvailabilityState>(
      listener: (ctx, state) {
        if (state is LawyerAvailabilitySaved) {
          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
            content: Text('Availability saved', style: GoogleFonts.outfit(color: Colors.white)),
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
        final isSaving  = state is LawyerAvailabilitySaving;
        final isLoading = state is LawyerAvailabilityLoading || state is LawyerAvailabilityInitial;
        if (state is LawyerAvailabilityLoaded) _lastSchedule = state.schedule;
        final schedule  = _lastSchedule;
        final cubit    = ctx.read<LawyerAvailabilityCubit>();
        final daySlots = List<String>.from(schedule[_day] ?? []);

        return Scaffold(
          backgroundColor: AppColors.bg,
          body: SafeArea(
            child: Column(children: [

              // ── Header ─────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Row(children: [
                  _CircleBtn(icon: Icons.arrow_back, onTap: () => Navigator.pop(context)),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Availability',
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    Text('Tap to toggle slots · gaps = breaks',
                      style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textHint)),
                  ])),
                  if (!isLoading)
                    GestureDetector(
                      onTap: isSaving ? null : () => cubit.save(schedule),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
                        decoration: BoxDecoration(
                          color: isSaving ? AppColors.fieldBorder : AppColors.navy,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: isSaving
                            ? const SizedBox(width: 16, height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54))
                            : Text('Save',
                                style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                      ),
                    ),
                ]),
              ),

              // ── Day picker ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Row(
                  children: List.generate(7, (i) {
                    final active   = i == _day;
                    final hasSlots = (schedule[i] ?? []).isNotEmpty;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _day = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: EdgeInsets.only(right: i < 6 ? 6 : 0),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: active ? AppColors.navy : AppColors.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: active
                                  ? AppColors.navy
                                  : (hasSlots
                                      ? AppColors.navy.withValues(alpha: 0.3)
                                      : AppColors.fieldBorder),
                            ),
                          ),
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            Text(_kDays[i], style: GoogleFonts.outfit(
                              fontSize: 11, fontWeight: FontWeight.w700,
                              color: active ? Colors.white : AppColors.textHint,
                            )),
                            const SizedBox(height: 4),
                            Container(
                              width: 4, height: 4,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: hasSlots
                                    ? (active
                                        ? Colors.white.withValues(alpha: 0.7)
                                        : AppColors.navy.withValues(alpha: 0.4))
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

              // ── Loading ────────────────────────────────────────────────
              if (isLoading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator(color: AppColors.navy, strokeWidth: 2)),
                ),

              // ── Slot grid ──────────────────────────────────────────────
              if (!isLoading)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                      // Day sub-header
                      Row(children: [
                        Text(_kFullDays[_day], style: GoogleFonts.outfit(
                          fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        const SizedBox(width: 8),
                        if (daySlots.isNotEmpty)
                          _SlotCountBadge(count: daySlots.length),
                        const Spacer(),
                        if (daySlots.isNotEmpty)
                          GestureDetector(
                            onTap: () => cubit.clearDay(_day),
                            child: Text('Clear all', style: GoogleFonts.outfit(
                              fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.error)),
                          ),
                      ]),
                      const SizedBox(height: 10),

                      // Quick-fill chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(children: [
                          _QuickFill(label: 'Morning',   start: 9,  end: 12, daySlots: daySlots, day: _day, cubit: cubit),
                          const SizedBox(width: 8),
                          _QuickFill(label: 'Afternoon', start: 12, end: 17, daySlots: daySlots, day: _day, cubit: cubit),
                          const SizedBox(width: 8),
                          _QuickFill(label: 'Evening',   start: 17, end: 21, daySlots: daySlots, day: _day, cubit: cubit),
                        ]),
                      ),
                      const SizedBox(height: 14),

                      // Slot chips
                      Expanded(
                        child: SingleChildScrollView(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _kGridSlots.map((slot) {
                              final on = daySlots.contains(slot);
                              return GestureDetector(
                                onTap: () => cubit.toggleSlot(_day, slot),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 120),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                                  decoration: BoxDecoration(
                                    color: on ? AppColors.navy : AppColors.surface,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: on ? AppColors.navy : AppColors.fieldBorder,
                                    ),
                                  ),
                                  child: Text(_fmt(slot), style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    fontWeight: on ? FontWeight.w700 : FontWeight.w400,
                                    color: on ? Colors.white : AppColors.textSecondary,
                                  )),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Week summary
                      _WeekSummary(schedule: schedule),
                      const SizedBox(height: 20),
                    ]),
                  ),
                ),
            ]),
          ),
        );
      },
    );
  }
}

// ─── Slot count badge ─────────────────────────────────────────────────────────

class _SlotCountBadge extends StatelessWidget {
  final int count;
  const _SlotCountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.navy.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text('$count slots', style: GoogleFonts.outfit(
        fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.navy)),
    );
  }
}

// ─── Quick-fill chip ──────────────────────────────────────────────────────────

class _QuickFill extends StatelessWidget {
  final String label;
  final int start;   // hour (inclusive)
  final int end;     // hour (exclusive)
  final List<String> daySlots;
  final int day;
  final LawyerAvailabilityCubit cubit;

  const _QuickFill({
    required this.label, required this.start, required this.end,
    required this.daySlots, required this.day, required this.cubit,
  });

  List<String> get _slots => _kGridSlots.where((s) {
    final h = int.parse(s.split(':')[0]);
    return h >= start && h < end;
  }).toList();

  bool get _allOn => _slots.every(daySlots.contains);

  @override
  Widget build(BuildContext context) {
    final allOn = _allOn;
    return GestureDetector(
      onTap: () {
        for (final slot in _slots) {
          final has = daySlots.contains(slot);
          if (!allOn && !has) cubit.toggleSlot(day, slot);
          if (allOn  &&  has) cubit.toggleSlot(day, slot);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: allOn ? AppColors.navy.withValues(alpha: 0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: allOn ? AppColors.navy.withValues(alpha: 0.4) : AppColors.fieldBorder,
          ),
        ),
        child: Text(label, style: GoogleFonts.outfit(
          fontSize: 12, fontWeight: FontWeight.w600,
          color: allOn ? AppColors.navy : AppColors.textSecondary,
        )),
      ),
    );
  }
}

// ─── Circle button ────────────────────────────────────────────────────────────

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.fieldBorder),
        ),
        child: Icon(icon, color: AppColors.textSecondary, size: 18),
      ),
    );
  }
}

// ─── Week summary ─────────────────────────────────────────────────────────────

class _WeekSummary extends StatelessWidget {
  final Map<int, List<String>> schedule;
  const _WeekSummary({required this.schedule});

  @override
  Widget build(BuildContext context) {
    final activeDays  = schedule.entries.where((e) => e.value.isNotEmpty).map((e) => _kDays[e.key]).toList();
    final totalSlots  = schedule.values.fold<int>(0, (s, v) => s + v.length);

    if (activeDays.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.navy.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.navy.withValues(alpha: 0.12)),
      ),
      child: Row(children: [
        const Icon(Icons.calendar_month_outlined, size: 15, color: AppColors.navy),
        const SizedBox(width: 10),
        Expanded(child: Text(activeDays.join(' · '), style: GoogleFonts.outfit(
          fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary))),
        Text('$totalSlots slots total', style: GoogleFonts.outfit(
          fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.navy)),
      ]),
    );
  }
}
