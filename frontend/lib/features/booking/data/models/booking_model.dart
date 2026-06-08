import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../../../core/utils/map_utils.dart';

class BookingModel extends Equatable {
  final int id;
  final int clientId;
  final int lawyerId;
  final String date;
  final String timeSlot;
  final int duration;
  final String sessionType;
  final String category;
  final String caseBrief;
  final String status;
  final String? clientName;
  final String? lawyerName;

  const BookingModel({
    required this.id,
    required this.clientId,
    required this.lawyerId,
    required this.date,
    required this.timeSlot,
    required this.duration,
    required this.sessionType,
    required this.category,
    required this.caseBrief,
    required this.status,
    this.clientName,
    this.lawyerName,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    try {
      final client = handleNullableMapKey(json, 'client') ?? {};
      final lawyerUser = handleNullableMapKey(json, 'lawyerUser') ?? {};
      return BookingModel(
        id:          handleNullableIntKey(json, 'id') ?? 0,
        clientId:    handleNullableIntKey(json, 'clientId') ?? 0,
        lawyerId:    handleNullableIntKey(json, 'lawyerId') ?? 0,
        date:        handleNullableStringKey(json, 'date') ?? '',
        timeSlot:    handleNullableStringKey(json, 'timeSlot') ?? '',
        duration:    handleNullableIntKey(json, 'duration') ?? 60,
        sessionType: handleNullableStringKey(json, 'sessionType') ?? 'video',
        category:    handleNullableStringKey(json, 'category') ?? '',
        caseBrief:   handleNullableStringKey(json, 'caseBrief') ?? '',
        status:      handleNullableStringKey(json, 'status') ?? 'pending',
        clientName:  handleNullableStringKey(client, 'name'),
        lawyerName:  handleNullableStringKey(lawyerUser, 'name'),
      );
    } catch (_) {
      return const BookingModel(
        id: 0, clientId: 0, lawyerId: 0, date: '', timeSlot: '',
        duration: 60, sessionType: 'video', category: '', caseBrief: '', status: 'pending',
      );
    }
  }

  Color get statusColor {
    switch (status) {
      case 'confirmed': return const Color(0xFF16A34A);
      case 'cancelled': return const Color(0xFFDC2626);
      default:          return const Color(0xFFD97706);
    }
  }

  @override
  List<Object?> get props => [id, status, date];
}
