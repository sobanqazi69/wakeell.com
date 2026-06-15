import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../booking/data/models/booking_model.dart';
import '../../../booking/presentation/cubits/client_bookings_cubit.dart';
import '../../../booking/presentation/cubits/client_bookings_state.dart';

class ClientChatTab extends StatelessWidget {
  const ClientChatTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Messages',
                style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            Text('Your post-session conversations',
                style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary)),
          ]),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: BlocBuilder<ClientBookingsCubit, ClientBookingsState>(
            builder: (context, state) {
              if (state is ClientBookingsLoading) {
                return const Center(child: CircularProgressIndicator(color: AppColors.navy, strokeWidth: 2));
              }

              final chats = context.read<ClientBookingsCubit>().completedBookings;

              if (chats.isEmpty) {
                return const _EmptyState();
              }

              return RefreshIndicator(
                color: AppColors.navy,
                onRefresh: () => context.read<ClientBookingsCubit>().refresh(),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: chats.length,
                  separatorBuilder: (context2, i) => const SizedBox(height: 2),
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
    final name = booking.lawyerName ?? 'Lawyer';
    final initials = name
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
          'otherPartyName': name,
          'otherPartyAvatar': booking.lawyerAvatar,
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.fieldBorder),
          ),
          child: Row(children: [
            Container(
              width: 48, height: 48,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.purple, AppColors.navy],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(child: Text(initials,
                  style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white))),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name,
                  style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text(booking.category.isNotEmpty ? booking.category : 'Legal Consultation',
                  style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary)),
            ])),
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
      const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${months[d.month - 1]} ${d.day}';
    } catch (_) {
      return date;
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

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
          'Once a session is completed, you can follow up with your lawyer here.',
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
        ),
      ]),
    ));
  }
}
