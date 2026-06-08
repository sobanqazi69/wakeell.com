import '../../../../../core/utils/map_utils.dart';

class ReviewModel {
  final int id;
  final int bookingId;
  final int rating;
  final String comment;

  const ReviewModel({
    required this.id,
    required this.bookingId,
    required this.rating,
    required this.comment,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    try {
      return ReviewModel(
        id:        handleNullableIntKey(json, 'id') ?? 0,
        bookingId: handleNullableIntKey(json, 'bookingId') ?? 0,
        rating:    handleNullableIntKey(json, 'rating') ?? 0,
        comment:   handleNullableStringKey(json, 'comment') ?? '',
      );
    } catch (_) {
      return const ReviewModel(id: 0, bookingId: 0, rating: 0, comment: '');
    }
  }
}
