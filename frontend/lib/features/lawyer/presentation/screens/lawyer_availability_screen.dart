import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/theme/app_colors.dart';
import '../cubits/lawyer_availability_cubit.dart';
import '../cubits/lawyer_availability_state.dart';

const _kDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _kFullDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
const _kSlots = [
  '08:00', '09:00', '10:00', '11:00', '12:00',
  '13:00', '14:00', '15:00', '16:00', '17:00', '18:00',
];

class LawyerAvailabilityScreen extends StatefulWidget {
  const LawyerAvailabilityScreen({super.key});

  @override
  State<LawyerAvailabilityScreen> createState() => _LawyerAvailabilityScreenState();
}

class _LawyerAvailabilityScreenState extends State<LawyerAvailabilityScreen> {
  int _selectedDay = 0;

  @override
  void initState() {
    super.initState();
    context.read<LawyerAvailabilityCubit>().startEdit();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LawyerAvailabilityCubit, LawyerAvailabilityState>(
      listener: (context, state) {
        if (state is LawyerAvailabilitySaved) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Availability saved for the next 4 weeks!', style: GoogleFonts.outfit(color: Colors.white)),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ));
        }
        if (state is LawyerAvailabilityError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message, style: GoogleFonts.outfit(color: Colors.white)),
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

        return Scaffold(
          backgroundColor: AppColors.bg,
          body: Column(children: [
            // Header
            Container(
              color: AppColors.navy,
              padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 12, 20, 20),
              child: Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(width: 36, height: 36, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), shape: BoxShape.circle), child: const Icon(Icons.arrow_back, color: Colors.white, size: 18)),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Availability', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                  Text('Set your weekly schedule', style: GoogleFonts.outfit(fontSize: 12, color: Colors.white60)),
                ])),
                if (state is LawyerAvailabilityLoaded)
                  GestureDetector(
                    onTap: isSaving ? null : () => context.read<LawyerAvailabilityCubit>().save(schedule),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                      decoration: BoxDecoration(color: isSaving ? Colors.white24 : Colors.white, borderRadius: BorderRadius.circular(20)),
                      child: isSaving
                          ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.navy))
                          : Text('Save', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.navy)),
                    ),
                  ),
              ]),
            ),

            if (state is LawyerAvailabilityInitial || state is LawyerAvailabilitySaving)
              const Expanded(child: Center(child: CircularProgressIndicator(color: AppColors.navy, strokeWidth: 2)))
            else if (state is LawyerAvailabilityLoaded || state is LawyerAvailabilitySaved) ...[
              // Day selector
              const SizedBox(height: 16),
              SizedBox(
                height: 56,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  scrollDirection: Axis.horizontal,
                  itemCount: _kDays.length,
                  separatorBuilder: (_, i) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final isSelected = i == _selectedDay;
                    final daySlots = schedule[i] ?? [];
                    final hasSlots = daySlots.isNotEmpty;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedDay = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        width: 52,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.navy : AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isSelected ? AppColors.navy : AppColors.fieldBorder),
                        ),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text(_kDays[i], style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : AppColors.textPrimary)),
                          const SizedBox(height: 4),
                          Container(
                            width: 6, height: 6,
                            decoration: BoxDecoration(
                              color: hasSlots ? (isSelected ? Colors.white : AppColors.success) : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ]),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Day label + clear
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(children: [
                  Text(_kFullDays[_selectedDay], style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => context.read<LawyerAvailabilityCubit>().clearDay(_selectedDay),
                    child: Text('Clear', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.error)),
                  ),
                ]),
              ),
              const SizedBox(height: 12),

              // Slots grid
              Expanded(child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 2.8, crossAxisSpacing: 10, mainAxisSpacing: 10),
                  itemCount: _kSlots.length,
                  itemBuilder: (_, i) {
                    final slot = _kSlots[i];
                    final isOn = (schedule[_selectedDay] ?? []).contains(slot);
                    return GestureDetector(
                      onTap: () => context.read<LawyerAvailabilityCubit>().toggleSlot(_selectedDay, slot),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        decoration: BoxDecoration(
                          color: isOn ? AppColors.navy : AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: isOn ? AppColors.navy : AppColors.fieldBorder),
                        ),
                        child: Center(child: Text(
                          _formatSlot(slot),
                          style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: isOn ? Colors.white : AppColors.textSecondary),
                        )),
                      ),
                    );
                  },
                ),
              )),
              const SizedBox(height: 16),

              // Info
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.navy.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(10)),
                  child: Row(children: [
                    const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.navy),
                    const SizedBox(width: 8),
                    Expanded(child: Text(
                      'Saving will apply this schedule for the next 4 weeks.',
                      style: GoogleFonts.outfit(fontSize: 12, color: AppColors.navy),
                    )),
                  ]),
                ),
              ),
            ],
          ]),
        );
      },
    );
  }

  String _formatSlot(String slot) {
    final parts = slot.split(':');
    final hour = int.parse(parts[0]);
    return hour < 12 ? '${hour == 0 ? 12 : hour}:00 AM' : '${hour == 12 ? 12 : hour - 12}:00 PM';
  }
}
