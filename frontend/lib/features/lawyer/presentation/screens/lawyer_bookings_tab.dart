import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../booking/data/models/booking_model.dart';
import '../../../booking/presentation/cubits/lawyer_bookings_cubit.dart';
import '../../../booking/presentation/cubits/lawyer_bookings_state.dart';

const _kFilters = ['all', 'pending', 'confirmed', 'cancelled'];
const _kFilterLabels = {'all': 'All', 'pending': 'Pending', 'confirmed': 'Confirmed', 'cancelled': 'Cancelled'};

class LawyerBookingsTab extends StatelessWidget {
  const LawyerBookingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Bookings', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            Text('Manage incoming consultations', style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary)),
          ]),
        ),
        const SizedBox(height: 16),

        // Filter chips
        BlocBuilder<LawyerBookingsCubit, LawyerBookingsState>(
          builder: (context, state) {
            final active = state is LawyerBookingsLoaded ? state.filter : 'all';
            return SizedBox(
              height: 34,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                scrollDirection: Axis.horizontal,
                itemCount: _kFilters.length,
                separatorBuilder: (_, i) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final f = _kFilters[i];
                  final isOn = f == active;
                  return GestureDetector(
                    onTap: () => context.read<LawyerBookingsCubit>().onFilterChanged(f),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: isOn ? AppColors.navy : AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isOn ? AppColors.navy : AppColors.fieldBorder),
                      ),
                      child: Center(child: Text(_kFilterLabels[f]!,
                        style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: isOn ? Colors.white : AppColors.textSecondary))),
                    ),
                  );
                },
              ),
            );
          },
        ),
        const SizedBox(height: 16),

        // List
        Expanded(
          child: BlocBuilder<LawyerBookingsCubit, LawyerBookingsState>(
            builder: (context, state) {
              if (state is LawyerBookingsLoading || state is LawyerBookingsInitial) {
                return const Center(child: CircularProgressIndicator(color: AppColors.navy, strokeWidth: 2));
              }
              if (state is LawyerBookingsError) {
                return _ErrorView(state.message, onRetry: () => context.read<LawyerBookingsCubit>().load());
              }
              if (state is LawyerBookingsLoaded) {
                if (state.bookings.isEmpty) return _EmptyView(filter: state.filter);
                return RefreshIndicator(
                  color: AppColors.navy,
                  onRefresh: () => context.read<LawyerBookingsCubit>().refresh(),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    itemCount: state.bookings.length,
                    separatorBuilder: (_, i) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _BookingCard(
                      booking: state.bookings[i],
                      onConfirm: () => context.read<LawyerBookingsCubit>().respond(state.bookings[i].id, 'confirmed'),
                      onCancel: () => context.read<LawyerBookingsCubit>().respond(state.bookings[i].id, 'cancelled'),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ]),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  const _BookingCard({required this.booking, required this.onConfirm, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [AppColors.cardShadow(opacity: 0.05, blur: 14)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          // Client avatar
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: AppColors.navy.withValues(alpha: 0.08), shape: BoxShape.circle),
            child: Center(child: Text(
              (booking.clientName?.isNotEmpty == true ? booking.clientName![0] : '?').toUpperCase(),
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.navy),
            )),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(booking.clientName ?? 'Client', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            Text(booking.category, style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: booking.statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
            child: Text(booking.status.toUpperCase(),
              style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w700, color: booking.statusColor)),
          ),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          _InfoBadge(icon: Icons.calendar_today_outlined, label: booking.date),
          const SizedBox(width: 10),
          _InfoBadge(icon: Icons.access_time_outlined, label: booking.timeSlot),
          const SizedBox(width: 10),
          _InfoBadge(icon: Icons.video_call_outlined, label: booking.sessionType),
        ]),
        if (booking.status == 'pending') ...[
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _Btn(label: 'Confirm', color: AppColors.success, onTap: onConfirm)),
            const SizedBox(width: 10),
            Expanded(child: _Btn(label: 'Decline', color: AppColors.error, filled: false, onTap: onCancel)),
          ]),
        ],
      ]),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon; final String label;
  const _InfoBadge({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 13, color: AppColors.textSecondary),
    const SizedBox(width: 4),
    Text(label, style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary)),
  ]);
}

class _Btn extends StatelessWidget {
  final String label; final Color color; final bool filled; final VoidCallback onTap;
  const _Btn({required this.label, required this.color, this.filled = true, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: filled ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: filled ? null : Border.all(color: color),
        ),
        child: Center(child: Text(label, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: filled ? Colors.white : color))),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final String filter;
  const _EmptyView({required this.filter});
  @override
  Widget build(BuildContext context) => Center(child: Padding(
    padding: const EdgeInsets.all(32),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.calendar_month_outlined, size: 48, color: AppColors.textHint),
      const SizedBox(height: 14),
      Text(filter == 'all' ? 'No bookings yet' : 'No $filter bookings',
        style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      const SizedBox(height: 6),
      Text('Bookings from clients will appear here', style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary)),
    ]),
  ));
}

class _ErrorView extends StatelessWidget {
  final String message; final VoidCallback onRetry;
  const _ErrorView(this.message, {required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    const Icon(Icons.error_outline, size: 44, color: AppColors.textHint),
    const SizedBox(height: 12),
    Text(message, textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary)),
    const SizedBox(height: 16),
    GestureDetector(onTap: onRetry, child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(8)),
      child: Text('Retry', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
    )),
  ]));
}
