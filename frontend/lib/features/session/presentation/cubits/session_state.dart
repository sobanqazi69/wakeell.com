import 'package:equatable/equatable.dart';
import 'package:livekit_client/livekit_client.dart';

abstract class SessionState extends Equatable {
  const SessionState();
  @override
  List<Object?> get props => [];
}

class SessionInitial extends SessionState {
  const SessionInitial();
}

class SessionConnecting extends SessionState {
  const SessionConnecting();
}

class SessionConnected extends SessionState {
  final Room room;
  final bool isMicEnabled;
  final bool isCameraEnabled;
  final int secondsElapsed;

  const SessionConnected({
    required this.room,
    required this.isMicEnabled,
    required this.isCameraEnabled,
    required this.secondsElapsed,
  });

  SessionConnected copyWith({
    bool? isMicEnabled,
    bool? isCameraEnabled,
    int? secondsElapsed,
  }) =>
      SessionConnected(
        room: room,
        isMicEnabled: isMicEnabled ?? this.isMicEnabled,
        isCameraEnabled: isCameraEnabled ?? this.isCameraEnabled,
        secondsElapsed: secondsElapsed ?? this.secondsElapsed,
      );

  @override
  List<Object?> get props => [isMicEnabled, isCameraEnabled, secondsElapsed];
}

class SessionFailed extends SessionState {
  final String message;
  const SessionFailed(this.message);
  @override
  List<Object?> get props => [message];
}

class SessionEnded extends SessionState {
  const SessionEnded();
}
