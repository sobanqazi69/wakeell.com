import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../booking/data/models/booking_model.dart';
import '../../../booking/presentation/cubits/lawyer_bookings_cubit.dart';
import '../../../booking/presentation/cubits/lawyer_bookings_state.dart';

class LawyerChatTab extends StatelessWidget {
  const LawyerChatTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Messages',
                  style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              Text('Chat with your clients',
                  style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary)),
            ])),
          ]),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: BlocBuilder<LawyerBookingsCubit, LawyerBookingsState>(
            builder: (context, state) {
              if (state is LawyerBookingsLoading) {
                return const Center(child: CircularProgressIndicator(color: AppColors.navy));
              }

              final chats = context.read<LawyerBookingsCubit>().completedBookings;

              if (chats.isEmpty) {
                return _EmptyState();
              }

              return RefreshIndicator(
                color: AppColors.navy,
                onRefresh: () => context.read<LawyerBookingsCubit>().refresh(),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: chats.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 2),
                  itemBuilder: (ctx, i) => _ConversationTile(booking: chats[i]),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final BookingModel booking;
  const _ConversationTile({required this.booking});

  @override
  Widget build(BuildContext context) {
    final initials = (booking.clientName ?? 'C')
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.pushNamed(context, AppRoutes.chat, arguments: {
          'bookingId': booking.id,
          'otherPartyName': booking.clientName ?? 'Client',
          'otherPartyAvatar': booking.clientAvatar,
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.fieldBorder),
          ),
          child: Row(children: [
            // Avatar
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.purple, AppColors.navy],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(initials,
                    style: GoogleFonts.outfit(
                        fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
            const SizedBox(width: 14),
            // Name + category
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(booking.clientName ?? 'Client',
                  style: GoogleFonts.outfit(
                      fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text(booking.category.isNotEmpty ? booking.category : 'Legal Consultation',
                  style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary)),
            ])),
            // Date + chevron
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(_formatDate(booking.date),
                  style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textHint),
            ]),
          ]),
        ),
      ),
    );
  }

  String _formatDate(String date) {
    try {
      final d = DateTime.parse(date);
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[d.month - 1]} ${d.day}';
    } catch (_) {
      return date;
    }
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: AppColors.navy.withValues(alpha: 0.06),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.chat_bubble_outline_rounded, size: 36, color: AppColors.navy),
        ),
        const SizedBox(height: 20),
        Text('No conversations yet',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        Text(
          'Completed sessions will appear here so you can follow up with clients.',
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
        ),
      ]),
    ));
  }
}
