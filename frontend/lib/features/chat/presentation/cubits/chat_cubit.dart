import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/socket_service.dart';
import '../../../../core/utils/debug_logger.dart';
import '../../data/models/chat_message_model.dart';
import '../../data/repositories/chat_repository.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  static const _tag = 'ChatCubit';

  final ChatRepository _repo;
  final SocketService _socket;
  final int bookingId;
  final int currentUserId;
  final String currentUserName;

  ChatCubit({
    required ChatRepository repo,
    required SocketService socket,
    required this.bookingId,
    required this.currentUserId,
    this.currentUserName = 'Me',
  })  : _repo = repo,
        _socket = socket,
        super(const ChatInitial());

  Future<void> init() async {
    try {
      if (!isClosed) emit(const ChatLoading());
      final history = await _repo.getHistory(bookingId);
      if (!isClosed) emit(ChatLoaded(history));

      _socket.emit('chat:join', {'bookingId': bookingId});

      _socket.on('chat:message', (data) {
        try {
          final msg = ChatMessageModel.fromJson(
            Map<String, dynamic>.from(data as Map),
          );
          final s = state;
          if (s is! ChatLoaded || isClosed) return;

          // Already in state (HTTP confirm arrived first) → skip.
          if (s.messages.any((m) => m.id == msg.id && msg.id != 0)) return;

          // Our own optimistic placeholder is waiting → replace it.
          final hasOptimistic = msg.senderId == currentUserId &&
              s.messages.any((m) => m.id == 0 && m.message == msg.message);
          if (hasOptimistic) {
            final updated = s.messages.map((m) =>
              (m.id == 0 && m.message == msg.message && m.senderId == currentUserId)
                  ? msg
                  : m,
            ).toList();
            emit(ChatLoaded(updated));
          } else {
            emit(s.withMessage(msg));
          }
        } catch (e) {
          DebugLogger.error(_tag, 'chat:message parse error: $e');
        }
      });
    } catch (e) {
      DebugLogger.error(_tag, 'init: $e');
      if (!isClosed) emit(ChatError(e.toString()));
    }
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    // Add optimistic placeholder immediately.
    final optimistic = ChatMessageModel(
      id: 0,
      bookingId: bookingId,
      senderId: currentUserId,
      senderRole: '',
      message: trimmed,
      senderName: currentUserName,
      createdAt: DateTime.now(),
    );
    final s = state;
    if (s is ChatLoaded && !isClosed) emit(s.withMessage(optimistic));

    try {
      final confirmed = await _repo.sendMessage(bookingId, trimmed);

      // If socket already replaced the optimistic, the confirmed ID is present —
      // nothing to do. Otherwise swap the placeholder with the confirmed message.
      final current = state;
      if (current is ChatLoaded && !isClosed) {
        if (current.messages.any((m) => m.id == confirmed.id)) return;
        final updated = current.messages.map((m) =>
          (m.id == 0 && m.message == trimmed && m.senderId == currentUserId)
              ? confirmed
              : m,
        ).toList();
        emit(ChatLoaded(updated));
      }
    } catch (e) {
      DebugLogger.error(_tag, 'sendMessage: $e');
    }
  }

  @override
  Future<void> close() {
    _socket.off('chat:message');
    return super.close();
  }
}
