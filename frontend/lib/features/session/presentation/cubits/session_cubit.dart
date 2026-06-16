import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/network/socket_service.dart';
import '../../../../core/utils/debug_logger.dart';
import '../../data/repositories/session_repository.dart';
import 'session_state.dart';

class SessionCubit extends Cubit<SessionState> {
  static const _tag = 'SessionCubit';

  final SessionRepository _repo;
  final SocketService _socket;
  Room? _room;
  Timer? _timer;
  int? _bookingId;
  bool _hasLeft = false;
  // Set to true when the remote participant connects — gate for endSession
  bool _remoteEverJoined = false;

  SessionCubit(this._repo, this._socket) : super(const SessionInitial());

  /// Called by the screen when LiveKit fires ParticipantConnectedEvent.
  /// Marks that the other party joined (unlocks endSession) and starts the
  /// recording indicator — recording begins on the backend at this moment.
  void notifyRemoteJoined() {
    _remoteEverJoined = true;
  }

  Future<void> join(int bookingId) async {
    _bookingId = bookingId;
    try {
      if (!isClosed) emit(const SessionConnecting());

      final tokenData = await _repo.joinToken(bookingId);
      DebugLogger.log(_tag, 'token fetched for room ${tokenData.roomId}');

      // Join the socket.io room so we receive server-pushed events (e.g. auto-cancel)
      _socket.emit('join_room', {'roomId': tokenData.roomId});
      _socket.on('session_auto_cancelled', _onAutoCancelled);

      _room = Room();
      await _room!.connect(
        tokenData.wsUrl,
        tokenData.token,
        roomOptions: const RoomOptions(
          adaptiveStream: true,
          dynacast: true,
          defaultVideoPublishOptions: VideoPublishOptions(simulcast: true),
        ),
      );
      DebugLogger.log(_tag, 'connected to room ${tokenData.roomId}');

      bool isMicEnabled = false;
      bool isCameraEnabled = false;

      final micStatus = await Permission.microphone.status;
      final camStatus = await Permission.camera.status;

      if (micStatus.isGranted) {
        try {
          await _room!.localParticipant?.setMicrophoneEnabled(true);
          isMicEnabled = true;
        } catch (e) {
          DebugLogger.error(_tag, 'mic enable failed: $e');
        }
      }

      if (camStatus.isGranted) {
        try {
          await _room!.localParticipant?.setCameraEnabled(true);
          isCameraEnabled = true;
        } catch (e) {
          DebugLogger.error(_tag, 'camera enable failed: $e');
        }
      }

      _startTimer();

      if (!isClosed) {
        emit(SessionConnected(
          room: _room!,
          isMicEnabled: isMicEnabled,
          isCameraEnabled: isCameraEnabled,
          secondsElapsed: 0,
        ));
      }
    } catch (e) {
      DebugLogger.error(_tag, 'join failed: $e');
      _socket.offHandler('session_auto_cancelled', _onAutoCancelled);
      if (!isClosed) emit(SessionFailed(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> toggleMic() async {
    final s = state;
    if (s is! SessionConnected) return;
    try {
      final next = !s.isMicEnabled;
      await _room?.localParticipant?.setMicrophoneEnabled(next);
      if (!isClosed) emit(s.copyWith(isMicEnabled: next));
    } catch (e) {
      DebugLogger.error(_tag, 'toggleMic: $e');
    }
  }

  Future<void> toggleCamera() async {
    final s = state;
    if (s is! SessionConnected) return;
    try {
      final next = !s.isCameraEnabled;
      await _room?.localParticipant?.setCameraEnabled(next);
      if (!isClosed) emit(s.copyWith(isCameraEnabled: next));
    } catch (e) {
      DebugLogger.error(_tag, 'toggleCamera: $e');
    }
  }

  Future<void> leave() async {
    if (_hasLeft) return;
    _hasLeft = true;
    _timer?.cancel();
    _socket.offHandler('session_auto_cancelled', _onAutoCancelled);

    try {
      await _room?.disconnect();
    } catch (e) {
      DebugLogger.error(_tag, 'leave: $e');
    }

    // Only call endSession if the other party actually joined at some point.
    // If the user left before the session started (early join + early leave),
    // we do nothing — they can rejoin when the time comes.
    if (_remoteEverJoined && _bookingId != null) {
      await _repo.endSession(_bookingId!);
    }

    if (!isClosed) emit(SessionEnded(bookingId: _bookingId ?? 0));
  }

  void _onAutoCancelled(dynamic data) {
    DebugLogger.log(_tag, 'session_auto_cancelled: $data');
    final reason = (data is Map ? data['reason'] as String? : null) ?? 'Session was cancelled';
    _timer?.cancel();
    _socket.offHandler('session_auto_cancelled', _onAutoCancelled);
    _room?.disconnect();
    if (!isClosed) emit(SessionAutoCancelled(reason: reason));
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final s = state;
      if (s is SessionConnected && !isClosed) {
        emit(s.copyWith(secondsElapsed: s.secondsElapsed + 1));
      }
    });
  }

  @override
  Future<void> close() async {
    _timer?.cancel();
    _socket.offHandler('session_auto_cancelled', _onAutoCancelled);
    await _room?.disconnect();
    _room = null;
    return super.close();
  }
}
