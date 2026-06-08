import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../config/theme/app_colors.dart';
import '../cubits/notifications_cubit.dart';
import '../cubits/notifications_state.dart';
import '../../data/models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationsCubit>().load();
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
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Notifications',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
              Text('Booking updates and reminders',
                style: GoogleFonts.outfit(fontSize: 12, color: Colors.white60)),
            ])),
            BlocBuilder<NotificationsCubit, NotificationsState>(
              builder: (ctx, state) {
                if (state is! NotificationsLoaded || state.unreadCount == 0) {
                  return const SizedBox.shrink();
                }
                return TextButton(
                  onPressed: () => ctx.read<NotificationsCubit>().markAllRead(),
                  child: Text('Mark all read',
                    style: GoogleFonts.outfit(fontSize: 12, color: Colors.white70)),
                );
              },
            ),
          ]),
        ),

        Expanded(
          child: BlocBuilder<NotificationsCubit, NotificationsState>(
            builder: (context, state) {
              if (state is NotificationsLoading || state is NotificationsInitial) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.navy, strokeWidth: 2));
              }
              if (state is NotificationsError) {
                return _buildEmpty(icon: Icons.error_outline_rounded,
                  title: 'Failed to load',
                  subtitle: state.message,
                  showRetry: true,
                  context: context);
              }
              if (state is NotificationsLoaded) {
                if (state.notifications.isEmpty) {
                  return _buildEmpty(
                    icon: Icons.notifications_none_rounded,
                    title: 'All caught up!',
                    subtitle: 'Booking updates and session reminders will appear here.',
                    context: context,
                  );
                }
                return RefreshIndicator(
                  color: AppColors.navy,
                  onRefresh: () => context.read<NotificationsCubit>().load(),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    itemCount: state.notifications.length,
                    separatorBuilder: (_, i) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _NotifCard(
                      notif: state.notifications[i],
                      onTap: () => context.read<NotificationsCubit>().markRead(state.notifications[i].id),
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

  Widget _buildEmpty({
    required IconData icon,
    required String title,
    required String subtitle,
    bool showRetry = false,
    required BuildContext context,
  }) {
    return Center(child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
            color: AppColors.navy.withValues(alpha: 0.06), shape: BoxShape.circle),
          child: Icon(icon, size: 32, color: AppColors.navy),
        ),
        const SizedBox(height: 16),
        Text(title,
          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        Text(subtitle, textAlign: TextAlign.center,
          style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
        if (showRetry) ...[
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => context.read<NotificationsCubit>().load(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(8)),
              child: Text('Retry',
                style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),
        ],
      ]),
    ));
  }
}

class _NotifCard extends StatelessWidget {
  final NotificationModel notif;
  final VoidCallback onTap;
  const _NotifCard({required this.notif, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notif.isRead ? AppColors.surface : AppColors.navy.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: notif.isRead ? AppColors.divider : AppColors.navy.withValues(alpha: 0.2),
          ),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: notif.iconColor.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(notif.icon, size: 20, color: notif.iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(notif.title,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: notif.isRead ? FontWeight.w500 : FontWeight.w700,
                  color: AppColors.textPrimary,
                ))),
              if (!notif.isRead)
                Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(color: AppColors.navy, shape: BoxShape.circle),
                ),
            ]),
            const SizedBox(height: 3),
            Text(notif.body,
              style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
              maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Text(_formatTime(notif.createdAt),
              style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textHint)),
          ])),
        ]),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1)  return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24)   return '${diff.inHours}h ago';
    if (diff.inDays < 7)     return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(dt);
  }
}
