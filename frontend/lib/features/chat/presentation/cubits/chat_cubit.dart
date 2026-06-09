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

  // Tracks optimistically-added message texts to avoid showing duplicates
  // when the server echoes the same message back via chat:message.
  final Set<String> _pendingMessages = {};

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
          // Skip echo of a message we already added optimistically.
          if (_pendingMessages.remove(msg.message)) return;
          final s = state;
          if (s is ChatLoaded && !isClosed) {
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

  void sendMessage(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    // Optimistically show the message immediately.
    final optimistic = ChatMessageModel(
      id: 0,
      bookingId: bookingId,
      senderId: currentUserId,
      senderRole: '',
      message: trimmed,
      senderName: currentUserName,
      createdAt: DateTime.now(),
    );
    _pendingMessages.add(trimmed);
    final s = state;
    if (s is ChatLoaded && !isClosed) emit(s.withMessage(optimistic));

    _socket.emit('chat:send', {'bookingId': bookingId, 'message': trimmed});
  }

  @override
  Future<void> close() {
    _socket.off('chat:message');
    return super.close();
  }
}
