import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livekit_client/livekit_client.dart';
import '../../../../core/utils/debug_logger.dart';
import '../../data/repositories/session_repository.dart';
import 'session_state.dart';

class SessionCubit extends Cubit<SessionState> {
  static const _tag = 'SessionCubit';

  final SessionRepository _repo;
  Room? _room;
  Timer? _timer;

  SessionCubit(this._repo) : super(const SessionInitial());

  Future<void> join(int bookingId) async {
    try {
      if (!isClosed) emit(const SessionConnecting());

      // 1. Fetch LiveKit token from backend
      final tokenData = await _repo.joinToken(bookingId);
      DebugLogger.log(_tag, 'token fetched for room ${tokenData.roomId}');

      // 2. Create and connect room
      _room = Room();
      await _room!.connect(
        tokenData.wsUrl,
        tokenData.token,
        roomOptions: const RoomOptions(
          adaptiveStream: true,
          dynacast: true,
          defaultVideoPublishOptions: VideoPublishOptions(
            simulcast: true,
          ),
        ),
      );
      DebugLogger.log(_tag, 'connected to room ${tokenData.roomId}');

      // 3. Enable camera and mic
      await _room!.localParticipant?.setCameraEnabled(true);
      await _room!.localParticipant?.setMicrophoneEnabled(true);

      // 4. Start elapsed-time ticker
      _startTimer();

      if (!isClosed) {
        emit(SessionConnected(
          room: _room!,
          isMicEnabled: true,
          isCameraEnabled: true,
          secondsElapsed: 0,
        ));
      }
    } catch (e) {
      DebugLogger.error(_tag, 'join failed: $e');
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
    _timer?.cancel();
    try {
      await _room?.disconnect();
    } catch (e) {
      DebugLogger.error(_tag, 'leave: $e');
    }
    if (!isClosed) emit(const SessionEnded());
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
    await _room?.disconnect();
    _room = null;
    return super.close();
  }
}
