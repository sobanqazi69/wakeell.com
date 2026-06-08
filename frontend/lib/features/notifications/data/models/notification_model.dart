import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../../../core/utils/map_utils.dart';

class NotificationModel extends Equatable {
  final int id;
  final String title;
  final String body;
  final String type;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.data,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    try {
      return NotificationModel(
        id:        handleNullableIntKey(json, 'id') ?? 0,
        title:     handleNullableStringKey(json, 'title') ?? '',
        body:      handleNullableStringKey(json, 'body') ?? '',
        type:      handleNullableStringKey(json, 'type') ?? 'booking_new',
        data:      handleNullableMapKey(json, 'data') ?? {},
        isRead:    handleNullableBoolKey(json, 'isRead') ?? false,
        createdAt: DateTime.tryParse(handleNullableStringKey(json, 'createdAt') ?? '') ?? DateTime.now(),
      );
    } catch (_) {
      return NotificationModel(
        id: 0, title: '', body: '', type: 'booking_new',
        data: {}, isRead: false, createdAt: DateTime.now(),
      );
    }
  }

  NotificationModel copyWith({bool? isRead}) => NotificationModel(
    id: id, title: title, body: body, type: type,
    data: data, isRead: isRead ?? this.isRead, createdAt: createdAt,
  );

  IconData get icon {
    switch (type) {
      case 'booking_accepted': return Icons.check_circle_outline;
      case 'booking_declined': return Icons.cancel_outlined;
      case 'reminder':         return Icons.alarm;
      default:                 return Icons.calendar_today_outlined;
    }
  }

  Color get iconColor {
    switch (type) {
      case 'booking_accepted': return const Color(0xFF16A34A);
      case 'booking_declined': return const Color(0xFFDC2626);
      case 'reminder':         return const Color(0xFFD97706);
      default:                 return const Color(0xFF1B2E6B);
    }
  }

  @override
  List<Object?> get props => [id, isRead];
}
