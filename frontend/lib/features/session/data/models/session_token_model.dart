import '../../../../../core/utils/map_utils.dart';

class SessionTokenModel {
  final String token;
  final String wsUrl;
  final String roomId;
  final int sessionId;

  const SessionTokenModel({
    required this.token,
    required this.wsUrl,
    required this.roomId,
    required this.sessionId,
  });

  factory SessionTokenModel.fromJson(Map<String, dynamic> json) {
    return SessionTokenModel(
      token:     handleNullableStringKey(json, 'token') ?? '',
      wsUrl:     handleNullableStringKey(json, 'wsUrl') ?? '',
      roomId:    handleNullableStringKey(json, 'roomId') ?? '',
      sessionId: handleNullableIntKey(json, 'sessionId') ?? 0,
    );
  }
}
