import '../../../../core/network/api_client.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final ApiClient _api;
  NotificationRepository(this._api);

  Future<({List<NotificationModel> notifications, int unreadCount})> getMyNotifications() async {
    final res = await _api.get('/notifications');
    final list = (res.data['notifications'] as List? ?? [])
        .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final unread = res.data['unreadCount'] as int? ?? 0;
    return (notifications: list, unreadCount: unread);
  }

  Future<void> markRead(int id) => _api.patch('/notifications/$id/read', data: {});

  Future<void> markAllRead() => _api.patch('/notifications/read-all', data: {});
}
