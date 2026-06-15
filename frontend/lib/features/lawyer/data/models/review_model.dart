import 'package:equatable/equatable.dart';
import '../../../../../core/utils/map_utils.dart';

class ReviewModel extends Equatable {
  final int id;
  final int rating;
  final String comment;
  final String clientName;
  final String? clientAvatar;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.rating,
    required this.comment,
    required this.clientName,
    this.clientAvatar,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    try {
      final client = handleNullableMapKey(json, 'client') ?? {};
      return ReviewModel(
        id:           handleNullableIntKey(json, 'id') ?? 0,
        rating:       handleNullableIntKey(json, 'rating') ?? 0,
        comment:      handleNullableStringKey(json, 'comment') ?? '',
        clientName:   handleNullableStringKey(client, 'name') ?? 'Client',
        clientAvatar: handleNullableStringKey(client, 'avatar'),
        createdAt:    DateTime.tryParse(handleNullableStringKey(json, 'createdAt') ?? '') ?? DateTime.now(),
      );
    } catch (_) {
      return ReviewModel(id: 0, rating: 0, comment: '', clientName: 'Client', createdAt: DateTime.now());
    }
  }

  String get initials {
    final parts = clientName.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts.isNotEmpty && parts[0].isNotEmpty) return parts[0][0].toUpperCase();
    return '?';
  }

  @override
  List<Object?> get props => [id, rating, comment, clientName, createdAt];
}
