import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/socket_service.dart';

class ChatUnreadState {
  final Map<int, int> counts;
  const ChatUnreadState([this.counts = const {}]);

  int forBooking(int id) => counts[id] ?? 0;

  ChatUnreadState withIncrement(int bookingId) {
    final m = Map<int, int>.from(counts);
    m[bookingId] = (m[bookingId] ?? 0) + 1;
    return ChatUnreadState(Map.unmodifiable(m));
  }

  ChatUnreadState withReset(int bookingId) {
    final m = Map<int, int>.from(counts);
    m.remove(bookingId);
    return ChatUnreadState(Map.unmodifiable(m));
  }
}

class ChatUnreadCubit extends Cubit<ChatUnreadState> {
  final SocketService _socket;
  final int _currentUserId;
  final _joined = <int>{};
  late final Function(dynamic) _handler;

  ChatUnreadCubit(this._socket, this._currentUserId)
      : super(const ChatUnreadState()) {
    _handler = (data) {
      if (isClosed) return;
      try {
        final map = Map<String, dynamic>.from(data as Map);
        final senderIdRaw = map['senderId'];
        final senderId =
            senderIdRaw is int ? senderIdRaw : int.tryParse('$senderIdRaw') ?? -1;
        if (senderId == _currentUserId) return;

        final bookingIdRaw = map['bookingId'];
        final bookingId =
            bookingIdRaw is int ? bookingIdRaw : int.tryParse('$bookingIdRaw') ?? 0;
        if (bookingId == 0) return;

        emit(state.withIncrement(bookingId));
      } catch (_) {}
    };
    _socket.on('chat:message', _handler);
  }

  void joinBookings(List<int> bookingIds) {
    for (final id in bookingIds) {
      if (_joined.contains(id)) continue;
      _joined.add(id);
      _socket.emit('chat:join', {'bookingId': id});
    }
  }

  void markRead(int bookingId) {
    if (!isClosed) emit(state.withReset(bookingId));
  }

  @override
  Future<void> close() {
    _socket.offHandler('chat:message', _handler);
    return super.close();
  }
}
