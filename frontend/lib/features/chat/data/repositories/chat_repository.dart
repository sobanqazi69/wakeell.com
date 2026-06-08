import 'package:dio/dio.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/utils/debug_logger.dart';
import '../models/chat_message_model.dart';

class ChatRepository {
  static const _tag = 'ChatRepository';
  final ApiClient _api;

  const ChatRepository(this._api);

  Future<List<ChatMessageModel>> getHistory(int bookingId) async {
    try {
      final res = await _api.get('/chats/$bookingId');
      final data = res.data as Map<String, dynamic>;
      final list = (data['messages'] as List? ?? []);
      return list
          .map((m) => ChatMessageModel.fromJson(m as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      DebugLogger.error(_tag, 'getHistory: ${e.message}');
      return [];
    } catch (e) {
      DebugLogger.error(_tag, 'getHistory unexpected: $e');
      return [];
    }
  }
}
