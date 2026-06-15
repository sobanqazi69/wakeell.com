import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../booking/data/models/booking_model.dart';
import '../../../booking/presentation/cubits/client_bookings_cubit.dart';
import '../../../booking/presentation/cubits/client_bookings_state.dart';
import '../../../chat/presentation/cubits/chat_unread_cubit.dart';

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

              // Join all chat rooms so we receive real-time unread events.
              context.read<ChatUnreadCubit>().joinBookings(chats.map((b) => b.id).toList());

              if (chats.isEmpty) return const _EmptyState();

              return RefreshIndicator(
                color: AppColors.navy,
                onRefresh: () => context.read<ClientBookingsCubit>().refresh(),
                child: BlocBuilder<ChatUnreadCubit, ChatUnreadState>(
                  builder: (ctx, unreadState) => ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: chats.length,
                    separatorBuilder: (context2, i) => const SizedBox(height: 2),
                    itemBuilder: (ctx2, i) => _ConversationTile(
                      booking: chats[i],
                      unread: unreadState.forBooking(chats[i].id),
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

class _ConversationTile extends StatelessWidget {
  final BookingModel booking;
  final int unread;
  const _ConversationTile({required this.booking, required this.unread});

  static const _base = 'https://wakeell.microdesk.tech';

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
        onTap: () {
          context.read<ChatUnreadCubit>().markRead(booking.id);
          Navigator.pushNamed(context, AppRoutes.chat, arguments: {
            'bookingId': booking.id,
            'otherPartyName': name,
            'otherPartyAvatar': booking.lawyerAvatar,
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.fieldBorder),
          ),
          child: Row(children: [
            Stack(clipBehavior: Clip.none, children: [
              _buildAvatar(booking.lawyerAvatar, initials),
              if (unread > 0)
                Positioned(
                  top: -4, right: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.cyan,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Center(
                      child: Text(
                        unread > 99 ? '99+' : '$unread',
                        style: GoogleFonts.outfit(
                            fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.navy),
                      ),
                    ),
                  ),
                ),
            ]),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name,
                  style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: unread > 0 ? FontWeight.w800 : FontWeight.w700,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text(booking.category.isNotEmpty ? booking.category : 'Legal Consultation',
                  style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary)),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(_formatDate(booking.date),
                  style: GoogleFonts.outfit(
                      fontSize: 11,
                      color: unread > 0 ? AppColors.navy : AppColors.textSecondary,
                      fontWeight: unread > 0 ? FontWeight.w700 : FontWeight.w400)),
              const SizedBox(height: 6),
              const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textHint),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _buildAvatar(String? avatarPath, String initials) {
    final fallback = Container(
      width: 48, height: 48,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.purple, AppColors.navy],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(initials,
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
      ),
    );

    if (avatarPath == null || avatarPath.isEmpty) return fallback;
    final url = avatarPath.startsWith('http') ? avatarPath : '$_base$avatarPath';

    return ClipOval(
      child: SizedBox(
        width: 48, height: 48,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          loadingBuilder: (ctx, child, progress) => progress == null ? child : fallback,
          errorBuilder: (ctx, err, stack) => fallback,
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
