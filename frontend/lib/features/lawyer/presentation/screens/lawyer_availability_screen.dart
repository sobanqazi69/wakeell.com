import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/theme/app_colors.dart';
import '../cubits/lawyer_availability_cubit.dart';
import '../cubits/lawyer_availability_state.dart';

const _kDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _kFullDays = [
  'Monday', 'Tuesday', 'Wednesday', 'Thursday',
  'Friday', 'Saturday', 'Sunday'
];

// 48 half-hour slots
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

// Grouped sections: [label, icon, startIndex, count]
const _kSections = [
  {'label': 'Night', 'icon': Icons.bedtime_outlined, 'start': 0, 'count': 12},
  {'label': 'Morning', 'icon': Icons.wb_sunny_outlined, 'start': 12, 'count': 12},
  {'label': 'Afternoon', 'icon': Icons.wb_twilight_outlined, 'start': 24, 'count': 12},
  {'label': 'Evening', 'icon': Icons.nights_stay_outlined, 'start': 36, 'count': 12},
];

class LawyerAvailabilityScreen extends StatefulWidget {
  const LawyerAvailabilityScreen({super.key});

  @override
  State<LawyerAvailabilityScreen> createState() => _LawyerAvailabilityScreenState();
}

class _LawyerAvailabilityScreenState extends State<LawyerAvailabilityScreen>
    with SingleTickerProviderStateMixin {
  int _selectedDay = 0;
  late AnimationController _saveAnim;
  late Animation<double> _saveScale;

  @override
  void initState() {
    super.initState();
    context.read<LawyerAvailabilityCubit>().startEdit();
    _saveAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _saveScale = Tween(begin: 1.0, end: 0.94).animate(
        CurvedAnimation(parent: _saveAnim, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _saveAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LawyerAvailabilityCubit, LawyerAvailabilityState>(
      listener: (context, state) {
        if (state is LawyerAvailabilitySaved) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Row(children: [
              const Icon(Icons.check_circle_outline_rounded,
                  color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text('Availability saved for 4 weeks!',
                  style: GoogleFonts.outfit(color: Colors.white)),
            ]),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ));
        }
        if (state is LawyerAvailabilityError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message,
                style: GoogleFonts.outfit(color: Colors.white)),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ));
        }
      },
      builder: (context, state) {
        final isSaving = state is LawyerAvailabilitySaving;
        final schedule = state is LawyerAvailabilityLoaded
            ? state.schedule
            : <int, List<String>>{};
        final isLoaded =
            state is LawyerAvailabilityLoaded || state is LawyerAvailabilitySaved;
        final selectedSlots = schedule[_selectedDay] ?? [];
        final totalSelected =
            schedule.values.fold<int>(0, (sum, slots) => sum + slots.length);

        return Scaffold(
          backgroundColor: AppColors.bg,
          body: Column(children: [
            // ── Gradient header ─────────────────────────────────────────
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1A1040), Color(0xFF0D0A1E)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: EdgeInsets.fromLTRB(
                  20, MediaQuery.of(context).padding.top + 14, 20, 20),
              child: Column(children: [
                Row(children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12)),
                      ),
                      child: const Icon(Icons.arrow_back,
                          color: Colors.white, size: 18),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Availability',
                              style: GoogleFonts.outfit(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white)),
                          Text('Set your weekly schedule',
                              style: GoogleFonts.outfit(
                                  fontSize: 12, color: Colors.white38)),
                        ]),
                  ),
                  if (isLoaded) ...[
                    ScaleTransition(
                      scale: _saveScale,
                      child: GestureDetector(
                        onTapDown: (_) => _saveAnim.forward(),
                        onTapUp: (_) async {
                          await _saveAnim.reverse();
                          if (!context.mounted) return;
                          if (!isSaving) {
                            context
                                .read<LawyerAvailabilityCubit>()
                                .save(schedule);
                          }
                        },
                        onTapCancel: () => _saveAnim.reverse(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: isSaving
                                ? null
                                : const LinearGradient(
                                    colors: [
                                      AppColors.cyan,
                                      Color(0xFF00B8D9)
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                            color: isSaving
                                ? Colors.white.withValues(alpha: 0.1)
                                : null,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: isSaving
                                ? null
                                : [
                                    BoxShadow(
                                      color: AppColors.cyan.withValues(alpha: 0.35),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                          ),
                          child: isSaving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.cyan))
                              : Text('Save',
                                  style: GoogleFonts.outfit(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black87)),
                        ),
                      ),
                    ),
                  ],
                ]),

                if (isLoaded) ...[
                  const SizedBox(height: 20),
                  // Stats row
                  Row(children: [
                    _StatPill(
                      icon: Icons.schedule_rounded,
                      label:
                          '$totalSelected slot${totalSelected == 1 ? '' : 's'} total',
                      color: AppColors.cyan,
                    ),
                    const SizedBox(width: 10),
                    _StatPill(
                      icon: Icons.today_rounded,
                      label:
                          '${selectedSlots.length} on ${_kDays[_selectedDay]}',
                      color: const Color(0xFFBB86FC),
                    ),
                  ]),
                ],
              ]),
            ),

            if (state is LawyerAvailabilityInitial ||
                state is LawyerAvailabilitySaving && !isLoaded)
              const Expanded(
                  child: Center(
                      child: CircularProgressIndicator(
                          color: AppColors.cyan, strokeWidth: 2))),

            if (isLoaded) ...[
              // ── Day selector ─────────────────────────────────────────────
              Container(
                color: const Color(0xFF0D0A1E),
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
                child: SizedBox(
                  height: 72,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: _kDays.length,
                    separatorBuilder: (_, i) => const SizedBox(width: 10),
                    itemBuilder: (_, i) {
                      final isSelected = i == _selectedDay;
                      final daySlots = schedule[i] ?? [];
                      final hasSlots = daySlots.isNotEmpty;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedDay = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOutCubic,
                          width: 52,
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xFF7B2FBE),
                                      Color(0xFF5B1FAE)
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            color: isSelected
                                ? null
                                : Colors.white.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF9B4FDE)
                                  : Colors.white.withValues(alpha: 0.08),
                              width: isSelected ? 1.5 : 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF7B2FBE)
                                          .withValues(alpha: 0.4),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    )
                                  ]
                                : null,
                          ),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(_kDays[i],
                                    style: GoogleFonts.outfit(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.white38)),
                                const SizedBox(height: 6),
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: hasSlots
                                        ? (isSelected
                                            ? Colors.white
                                            : AppColors.cyan)
                                        : Colors.transparent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ]),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // ── Day label + clear ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                child: Row(children: [
                  Text(_kFullDays[_selectedDay],
                      style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                  const SizedBox(width: 8),
                  if (selectedSlots.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.cyan.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('${selectedSlots.length}',
                          style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.cyan)),
                    ),
                  const Spacer(),
                  if (selectedSlots.isNotEmpty)
                    GestureDetector(
                      onTap: () => context
                          .read<LawyerAvailabilityCubit>()
                          .clearDay(_selectedDay),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppColors.error.withValues(alpha: 0.25)),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.clear_rounded,
                              size: 13, color: AppColors.error),
                          const SizedBox(width: 4),
                          Text('Clear',
                              style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.error)),
                        ]),
                      ),
                    ),
                ]),
              ),

              // ── Slot sections ──────────────────────────────────────────
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  children: _kSections.map((section) {
                    final start = section['start'] as int;
                    final count = section['count'] as int;
                    final slots = _kSlots.sublist(start, start + count);
                    final icon = section['icon'] as IconData;
                    final label = section['label'] as String;

                    return _TimeSection(
                      icon: icon,
                      label: label,
                      slots: slots,
                      selectedSlots: selectedSlots,
                      onToggle: (slot) => context
                          .read<LawyerAvailabilityCubit>()
                          .toggleSlot(_selectedDay, slot),
                    );
                  }).toList(),
                ),
              ),
            ],
          ]),
        );
      },
    );
  }
}

// ─── Time section ─────────────────────────────────────────────────────────────

class _TimeSection extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<String> slots;
  final List<String> selectedSlots;
  final void Function(String) onToggle;

  const _TimeSection({
    required this.icon,
    required this.label,
    required this.slots,
    required this.selectedSlots,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final selectedInSection = slots.where(selectedSlots.contains).length;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Section header
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 6, 0, 10),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child:
                Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.5)),
          ),
          const SizedBox(width: 8),
          Text(label,
              style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.45))),
          const SizedBox(width: 6),
          if (selectedInSection > 0)
            Text('($selectedInSection)',
                style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.cyan.withValues(alpha: 0.8))),
          const Spacer(),
          Expanded(
            child: Container(
                height: 1,
                color: Colors.white.withValues(alpha: 0.06)),
          ),
        ]),
      ),

      // 4-column grid
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 2.0,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: slots.length,
        itemBuilder: (_, i) {
          final slot = slots[i];
          final isOn = selectedSlots.contains(slot);
          return GestureDetector(
            onTap: () => onToggle(slot),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                gradient: isOn
                    ? const LinearGradient(
                        colors: [Color(0xFF00B8D9), AppColors.cyan],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isOn ? null : Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isOn
                      ? AppColors.cyan.withValues(alpha: 0.6)
                      : Colors.white.withValues(alpha: 0.07),
                  width: isOn ? 1.5 : 1,
                ),
                boxShadow: isOn
                    ? [
                        BoxShadow(
                          color: AppColors.cyan.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  _fmt(slot),
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: isOn ? FontWeight.w800 : FontWeight.w500,
                    color: isOn
                        ? Colors.black87
                        : Colors.white.withValues(alpha: 0.55),
                  ),
                ),
              ),
            ),
          );
        },
      ),
      const SizedBox(height: 16),
    ]);
  }

  String _fmt(String slot) {
    final parts = slot.split(':');
    final h = int.parse(parts[0]);
    final m = parts[1];
    final period = h < 12 ? 'AM' : 'PM';
    final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$h12:$m\n$period';
  }
}

// ─── Stat pill ────────────────────────────────────────────────────────────────

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _StatPill({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 6),
        Text(label,
            style: GoogleFonts.outfit(
                fontSize: 12, fontWeight: FontWeight.w600, color: color)),
      ]),
    );
  }
}
