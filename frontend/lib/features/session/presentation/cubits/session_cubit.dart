import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/utils/debug_logger.dart';
import '../../data/repositories/session_repository.dart';
import 'session_state.dart';

class SessionCubit extends Cubit<SessionState> {
  static const _tag = 'SessionCubit';

  final SessionRepository _repo;
  Room? _room;
  Timer? _timer;
  int? _bookingId;
  bool _hasLeft = false;

  SessionCubit(this._repo) : super(const SessionInitial());

  Future<void> join(int bookingId) async {
    _bookingId = bookingId;
    try {
      if (!isClosed) emit(const SessionConnecting());

      final tokenData = await _repo.joinToken(bookingId);
      DebugLogger.log(_tag, 'token fetched for room ${tokenData.roomId}');

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
      DebugLogger.log(_tag, 'permissions: mic=${micStatus.isGranted} cam=${camStatus.isGranted}');

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
    try {
      await _room?.disconnect();
    } catch (e) {
      DebugLogger.error(_tag, 'leave: $e');
    }
    if (_bookingId != null) {
      await _repo.endSession(_bookingId!);
    }
    if (!isClosed) emit(SessionEnded(bookingId: _bookingId ?? 0));
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
