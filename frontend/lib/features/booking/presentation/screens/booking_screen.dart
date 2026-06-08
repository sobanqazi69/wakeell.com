import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/theme/app_colors.dart';
import '../cubits/client_booking_cubit.dart';
import '../cubits/client_booking_state.dart';

const _kBookingCategories = [
  'General', 'Corporate', 'Criminal', 'Family',
  'Property', 'Immigration', 'Tax', 'Labour', 'Civil',
];

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  bool _initialized = false;
  final _caseBriefCtrl = TextEditingController();
  late int _lawyerId;
  late String _lawyerName;
  ClientBookingReady? _lastReady;

  @override
  void initState() {
    super.initState();
    _caseBriefCtrl.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      _lawyerId = args['lawyerId'] as int;
      _lawyerName = args['lawyerName'] as String;
      context.read<ClientBookingCubit>().loadAvailability(_lawyerId);
    }
  }

  @override
  void dispose() {
    _caseBriefCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ClientBookingCubit, ClientBookingState>(
      listener: (context, state) {
        if (state is ClientBookingSuccess) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Booking submitted! Awaiting lawyer confirmation.',
                style: GoogleFonts.outfit(color: Colors.white)),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ));
        }
        if (state is ClientBookingError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message, style: GoogleFonts.outfit(color: Colors.white)),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ));
        }
      },
      builder: (context, state) {
        if (state is ClientBookingReady) _lastReady = state;
        return Scaffold(
          backgroundColor: AppColors.bg,
          body: Column(children: [
            _Header(lawyerName: _lawyerName),
            Expanded(child: _buildContent(context, state)),
          ]),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, ClientBookingState state) {
    if (state is ClientBookingLoading || state is ClientBookingInitial) {
      return const Center(child: CircularProgressIndicator(color: AppColors.navy, strokeWidth: 2));
    }
    if (state is ClientBookingNoSlots) {
      return _NoSlotsView(
        onBack: () => Navigator.pop(context),
        onRetry: () => context.read<ClientBookingCubit>().loadAvailability(_lawyerId),
      );
    }
    if (state is ClientBookingError && _lastReady == null) {
      return _RetryView(
        message: state.message,
        onRetry: () => context.read<ClientBookingCubit>().loadAvailability(_lawyerId),
      );
    }
    final ready = (state is ClientBookingReady ? state : _lastReady);
    if (ready == null) return const SizedBox.shrink();
    return _BookingForm(
      state: ready,
      lawyerId: _lawyerId,
      caseBriefCtrl: _caseBriefCtrl,
      isSubmitting: state is ClientBookingSubmitting,
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final String lawyerName;
  const _Header({required this.lawyerName});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text('Book Consultation', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
          Text(lawyerName, style: GoogleFonts.outfit(fontSize: 12, color: Colors.white60), overflow: TextOverflow.ellipsis),
        ])),
      ]),
    );
  }
}

// ─── Booking Form ─────────────────────────────────────────────────────────────

class _BookingForm extends StatelessWidget {
  final ClientBookingReady state;
  final int lawyerId;
  final TextEditingController caseBriefCtrl;
  final bool isSubmitting;

  const _BookingForm({
    required this.state,
    required this.lawyerId,
    required this.caseBriefCtrl,
    required this.isSubmitting,
  });

  @override
  Widget build(BuildContext context) {
    final canSubmit = state.canSubmit && caseBriefCtrl.text.trim().isNotEmpty && !isSubmitting;

    return Column(children: [
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // ── Select Date ───────────────────────────────────────────────
            _SectionLabel('Select Date'),
            const SizedBox(height: 10),
            SizedBox(
              height: 70,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: state.availableDates.length,
                separatorBuilder: (_, i) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final date = state.availableDates[i];
                  final isSelected = date == state.selectedDate;
                  final parsed = DateTime.tryParse(date);
                  return GestureDetector(
                    onTap: () => context.read<ClientBookingCubit>().onDateSelected(date),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 56,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.navy : AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isSelected ? AppColors.navy : AppColors.fieldBorder),
                      ),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text(
                          parsed != null ? _dayShort(parsed) : '',
                          style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w500, color: isSelected ? Colors.white70 : AppColors.textSecondary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          parsed != null ? '${parsed.day}' : '',
                          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : AppColors.textPrimary),
                        ),
                        Text(
                          parsed != null ? _monthShort(parsed) : '',
                          style: GoogleFonts.outfit(fontSize: 10, color: isSelected ? Colors.white60 : AppColors.textSecondary),
                        ),
                      ]),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 22),

            // ── Select Time ────────────────────────────────────────────────
            _SectionLabel('Select Time'),
            const SizedBox(height: 10),
            if (state.slotsForDate.isEmpty)
              Text('No slots available for this date.',
                style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary))
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: state.slotsForDate.map((slot) {
                  final isSelected = slot == state.selectedSlot;
                  final isPast     = _isSlotPast(slot, state.selectedDate ?? '');
                  return GestureDetector(
                    onTap: isPast ? null : () => context.read<ClientBookingCubit>().onSlotSelected(slot),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                      decoration: BoxDecoration(
                        color: isPast
                            ? AppColors.bg
                            : isSelected ? AppColors.navy : AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isPast
                              ? AppColors.fieldBorder.withValues(alpha: 0.4)
                              : isSelected ? AppColors.navy : AppColors.fieldBorder,
                        ),
                      ),
                      child: Text(_formatSlot(slot),
                        style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600,
                          color: isPast
                              ? AppColors.textSecondary.withValues(alpha: 0.35)
                              : isSelected ? Colors.white : AppColors.textSecondary)),
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 22),

            // ── Session Type ───────────────────────────────────────────────
            _SectionLabel('Session Type'),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _TypeTile(
                icon: Icons.videocam_outlined,
                label: 'Video Call',
                isSelected: state.sessionType == 'video',
                onTap: () => context.read<ClientBookingCubit>().onSessionTypeChanged('video'),
              )),
              const SizedBox(width: 10),
              Expanded(child: _TypeTile(
                icon: Icons.phone_outlined,
                label: 'Phone Call',
                isSelected: state.sessionType == 'audio',
                onTap: () => context.read<ClientBookingCubit>().onSessionTypeChanged('audio'),
              )),
            ]),
            const SizedBox(height: 22),

            // ── Practice Area ──────────────────────────────────────────────
            _SectionLabel('Practice Area'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _kBookingCategories.map((cat) {
                final isSelected = cat == state.category;
                return GestureDetector(
                  onTap: () => context.read<ClientBookingCubit>().onCategoryChanged(cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.navy : AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isSelected ? AppColors.navy : AppColors.fieldBorder),
                    ),
                    child: Text(cat,
                      style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.textSecondary)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 22),

            // ── Case Brief ─────────────────────────────────────────────────
            _SectionLabel('Case Brief'),
            const SizedBox(height: 4),
            Text('Briefly describe your legal matter so the lawyer can prepare.',
              style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.fieldBorder),
              ),
              child: TextField(
                controller: caseBriefCtrl,
                maxLines: 5,
                maxLength: 500,
                style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textPrimary, height: 1.5),
                decoration: InputDecoration(
                  hintText: 'e.g., I need assistance with a property dispute involving…',
                  hintStyle: GoogleFonts.outfit(fontSize: 13, color: AppColors.textHint),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(14),
                  counterStyle: GoogleFonts.outfit(fontSize: 11, color: AppColors.textHint),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ]),
        ),
      ),

      // ── Confirm button ─────────────────────────────────────────────────────
      Container(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + MediaQuery.of(context).padding.bottom),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: GestureDetector(
          onTap: canSubmit
              ? () => context.read<ClientBookingCubit>().submit(lawyerId, caseBriefCtrl.text.trim())
              : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 52,
            decoration: BoxDecoration(
              color: canSubmit ? AppColors.navy : AppColors.navy.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: isSubmitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text('Confirm Booking',
                      style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ),
        ),
      ),
    ]);
  }

  static String _formatSlot(String slot) {
    final parts = slot.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    return hour < 12
        ? '${hour == 0 ? 12 : hour}:00 AM'
        : '${hour == 12 ? 12 : hour - 12}:00 PM';
  }

  static bool _isSlotPast(String slot, String date) {
    try {
      final now = DateTime.now();
      final dateParts = date.split('-');
      final timeParts = slot.split(':');
      if (dateParts.length < 3 || timeParts.length < 2) return false;
      final slotDt = DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );
      return slotDt.isBefore(now);
    } catch (_) {
      return false;
    }
  }

  static String _dayShort(DateTime d) =>
      const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d.weekday - 1];
  static String _monthShort(DateTime d) =>
      const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][d.month - 1];
}

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
    style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary));
}

class _TypeTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _TypeTile({required this.icon, required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.navy : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.navy : AppColors.fieldBorder),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 22, color: isSelected ? Colors.white : AppColors.textSecondary),
          const SizedBox(height: 6),
          Text(label, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary)),
        ]),
      ),
    );
  }
}

class _NoSlotsView extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onRetry;
  const _NoSlotsView({required this.onBack, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(child: Padding(
    padding: const EdgeInsets.all(32),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 72, height: 72,
        decoration: BoxDecoration(color: AppColors.navy.withValues(alpha: 0.06), shape: BoxShape.circle),
        child: const Icon(Icons.calendar_month_outlined, size: 32, color: AppColors.textHint),
      ),
      const SizedBox(height: 18),
      Text('No Available Slots',
        style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      const SizedBox(height: 8),
      Text('This lawyer has not set their availability yet.\nCheck back later.',
        textAlign: TextAlign.center,
        style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
      const SizedBox(height: 24),
      Row(mainAxisSize: MainAxisSize.min, children: [
        GestureDetector(
          onTap: onBack,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.fieldBorder),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('Go Back', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: onRetry,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(10)),
            child: Text('Try Again', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ),
      ]),
    ]),
  ));
}

class _RetryView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _RetryView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(child: Padding(
    padding: const EdgeInsets.all(32),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.error_outline_rounded, size: 44, color: AppColors.textHint),
      const SizedBox(height: 12),
      Text(message, textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary)),
      const SizedBox(height: 16),
      GestureDetector(onTap: onRetry, child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(8)),
        child: Text('Retry', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
      )),
    ]),
  ));
}
