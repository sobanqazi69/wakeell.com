import '../../../../../core/utils/map_utils.dart';

class ChatMessageModel {
  final int id;
  final int bookingId;
  final int senderId;
  final String senderRole;
  final String message;
  final String senderName;
  final DateTime createdAt;

  const ChatMessageModel({
    required this.id,
    required this.bookingId,
    required this.senderId,
    required this.senderRole,
    required this.message,
    required this.senderName,
    required this.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    try {
      final sender = handleNullableMapKey(json, 'sender') ?? {};
      return ChatMessageModel(
        id:         handleNullableIntKey(json, 'id') ?? 0,
        bookingId:  handleNullableIntKey(json, 'bookingId') ?? 0,
        senderId:   handleNullableIntKey(json, 'senderId') ?? 0,
        senderRole: handleNullableStringKey(json, 'senderRole') ?? '',
        message:    handleNullableStringKey(json, 'message') ?? '',
        senderName: handleNullableStringKey(sender, 'name') ?? 'Unknown',
        createdAt:  DateTime.tryParse(handleNullableStringKey(json, 'createdAt') ?? '') ?? DateTime.now(),
      );
    } catch (_) {
      return ChatMessageModel(
        id: 0, bookingId: 0, senderId: 0, senderRole: '', message: '',
        senderName: 'Unknown', createdAt: DateTime.now(),
      );
    }
  }
}
