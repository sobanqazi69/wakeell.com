import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/theme/app_colors.dart';
import '../../data/models/booking_model.dart';
import '../cubits/client_bookings_cubit.dart';
import '../cubits/client_bookings_state.dart';

const _kFilters = ['all', 'pending', 'accepted', 'declined', 'cancelled'];
const _kFilterLabels = {
  'all': 'All',
  'pending': 'Pending',
  'accepted': 'Accepted',
  'declined': 'Declined',
  'cancelled': 'Cancelled',
};

class ClientBookingsScreen extends StatefulWidget {
  const ClientBookingsScreen({super.key});

  @override
  State<ClientBookingsScreen> createState() => _ClientBookingsScreenState();
}

class _ClientBookingsScreenState extends State<ClientBookingsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ClientBookingsCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
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
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('My Bookings', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
              Text('Your consultation history', style: GoogleFonts.outfit(fontSize: 12, color: Colors.white60)),
            ])),
          ]),
        ),

        // Filter chips
        BlocBuilder<ClientBookingsCubit, ClientBookingsState>(
          builder: (context, state) {
            final active = state is ClientBookingsLoaded ? state.filter : 'all';
            return Container(
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: SizedBox(
                height: 34,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _kFilters.length,
                  separatorBuilder: (_, i) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final f = _kFilters[i];
                    final isOn = f == active;
                    return GestureDetector(
                      onTap: () => context.read<ClientBookingsCubit>().onFilterChanged(f),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: isOn ? AppColors.navy : AppColors.bg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isOn ? AppColors.navy : AppColors.fieldBorder),
                        ),
                        child: Center(child: Text(_kFilterLabels[f]!,
                          style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600,
                            color: isOn ? Colors.white : AppColors.textSecondary))),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
        const Divider(height: 1, color: AppColors.divider),

        // Content
        Expanded(
          child: BlocBuilder<ClientBookingsCubit, ClientBookingsState>(
            builder: (context, state) {
              if (state is ClientBookingsLoading || state is ClientBookingsInitial) {
                return const Center(child: CircularProgressIndicator(color: AppColors.navy, strokeWidth: 2));
              }
              if (state is ClientBookingsError) {
                return _ErrorView(message: state.message, onRetry: () => context.read<ClientBookingsCubit>().load());
              }
              if (state is ClientBookingsLoaded) {
                if (state.bookings.isEmpty) {
                  return _EmptyView(filter: state.filter);
                }
                return RefreshIndicator(
                  color: AppColors.navy,
                  onRefresh: () => context.read<ClientBookingsCubit>().refresh(),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    itemCount: state.bookings.length,
                    separatorBuilder: (_, i) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _BookingCard(booking: state.bookings[i]),
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

// ─── Booking Card ─────────────────────────────────────────────────────────────

class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [AppColors.cardShadow(opacity: 0.04, blur: 14)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              // Lawyer avatar
              Container(
                width: 44, height: 44,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [AppColors.navy, AppColors.navyMid]),
                  shape: BoxShape.circle,
                ),
                child: Center(child: Text(
                  _initials(booking.lawyerName ?? ''),
                  style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                )),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(booking.lawyerName ?? 'Lawyer',
                  style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                Text(booking.category,
                  style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary)),
              ])),
              _StatusBadge(status: booking.status, color: booking.statusColor),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              _InfoPill(icon: Icons.calendar_today_outlined, label: _formatDate(booking.date)),
              const SizedBox(width: 8),
              _InfoPill(icon: Icons.access_time_outlined, label: _formatSlot(booking.timeSlot)),
              const SizedBox(width: 8),
              _InfoPill(
                icon: booking.sessionType == 'video' ? Icons.videocam_outlined : Icons.phone_outlined,
                label: booking.sessionType == 'video' ? 'Video' : 'Phone',
              ),
            ]),
            if (booking.caseBrief.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                booking.caseBrief,
                style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ]),
        ),
        if (booking.status == 'accepted') ...[
          const Divider(height: 1, color: AppColors.divider),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: GestureDetector(
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Video session coming soon.',
                  style: GoogleFonts.outfit(color: Colors.white)),
                backgroundColor: AppColors.navy,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              )),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.videocam_outlined, size: 16, color: Colors.white),
                  const SizedBox(width: 6),
                  Text('Join Session', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                ]),
              ),
            ),
          ),
        ],
      ]),
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts.isNotEmpty && parts[0].isNotEmpty) return parts[0][0].toUpperCase();
    return '?';
  }

  static String _formatDate(String date) {
    final d = DateTime.tryParse(date);
    if (d == null) return date;
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}';
  }

  static String _formatSlot(String slot) {
    final parts = slot.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    return hour < 12 ? '${hour == 0 ? 12 : hour}:00 AM' : '${hour == 12 ? 12 : hour - 12}:00 PM';
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final Color color;
  const _StatusBadge({required this.status, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(status.toUpperCase(),
      style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
  );
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: AppColors.bg,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 12, color: AppColors.textSecondary),
      const SizedBox(width: 4),
      Text(label, style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
    ]),
  );
}

// ─── Empty / Error ────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  final String filter;
  const _EmptyView({required this.filter});

  @override
  Widget build(BuildContext context) => Center(child: Padding(
    padding: const EdgeInsets.all(32),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 72, height: 72,
        decoration: BoxDecoration(color: AppColors.navy.withValues(alpha: 0.06), shape: BoxShape.circle),
        child: const Icon(Icons.calendar_month_outlined, size: 32, color: AppColors.textHint),
      ),
      const SizedBox(height: 16),
      Text(filter == 'all' ? 'No bookings yet' : 'No ${_kFilterLabels[filter]} bookings',
        style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      const SizedBox(height: 6),
      Text('Your consultations will appear here once booked.',
        textAlign: TextAlign.center,
        style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary)),
    ]),
  ));
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

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
