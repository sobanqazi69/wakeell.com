import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/debug_logger.dart';
import '../../data/repositories/notification_repository.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  static const _tag = 'NotificationsCubit';

  final NotificationRepository _repo;
  NotificationsCubit(this._repo) : super(const NotificationsInitial());

  Future<void> load() async {
    try {
      if (!isClosed) emit(const NotificationsLoading());
      final result = await _repo.getMyNotifications();
      if (!isClosed) {
        emit(NotificationsLoaded(
          notifications: result.notifications,
          unreadCount:   result.unreadCount,
        ));
      }
    } catch (e) {
      DebugLogger.error(_tag, 'load: $e');
      if (!isClosed) emit(NotificationsError(e.toString()));
    }
  }

  Future<void> markRead(int id) async {
    try {
      await _repo.markRead(id);
      final s = state;
      if (s is! NotificationsLoaded) return;
      final updated = s.notifications.map((n) =>
        n.id == id ? n.copyWith(isRead: true) : n
      ).toList();
      final newUnread = updated.where((n) => !n.isRead).length;
      if (!isClosed) emit(s.copyWith(notifications: updated, unreadCount: newUnread));
    } catch (e) {
      DebugLogger.error(_tag, 'markRead: $e');
    }
  }

  Future<void> markAllRead() async {
    try {
      await _repo.markAllRead();
      final s = state;
      if (s is! NotificationsLoaded) return;
      final updated = s.notifications.map((n) => n.copyWith(isRead: true)).toList();
      if (!isClosed) emit(s.copyWith(notifications: updated, unreadCount: 0));
    } catch (e) {
      DebugLogger.error(_tag, 'markAllRead: $e');
    }
  }

  int get unreadCount {
    final s = state;
    return s is NotificationsLoaded ? s.unreadCount : 0;
  }
}
