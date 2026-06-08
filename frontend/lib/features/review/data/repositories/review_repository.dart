import 'package:dio/dio.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/utils/debug_logger.dart';
import '../models/review_model.dart';

class ReviewException implements Exception {
  final String message;
  const ReviewException(this.message);
}

class ReviewRepository {
  static const _tag = 'ReviewRepository';
  final ApiClient _api;

  const ReviewRepository(this._api);

  Future<ReviewModel?> getBookingReview(int bookingId) async {
    try {
      final res = await _api.get('/reviews/booking/$bookingId');
      final data = res.data as Map<String, dynamic>;
      final reviewJson = data['review'];
      if (reviewJson == null) return null;
      return ReviewModel.fromJson(reviewJson as Map<String, dynamic>);
    } on DioException catch (e) {
      DebugLogger.error(_tag, 'getBookingReview: ${e.message}');
      return null;
    } catch (e) {
      DebugLogger.error(_tag, 'getBookingReview unexpected: $e');
      return null;
    }
  }

  Future<ReviewModel> submitReview({
    required int bookingId,
    required int rating,
    required String comment,
  }) async {
    try {
      final res = await _api.post('/reviews', data: {
        'bookingId': bookingId,
        'rating': rating,
        'comment': comment,
      });
      final data = res.data as Map<String, dynamic>;
      return ReviewModel.fromJson(data['review'] as Map<String, dynamic>);
    } on DioException catch (e) {
      DebugLogger.error(_tag, 'submitReview: ${e.message}');
      final msg = (e.response?.data is Map) ? e.response?.data['message'] : null;
      throw ReviewException(msg ?? 'Failed to submit review');
    } catch (e) {
      DebugLogger.error(_tag, 'submitReview unexpected: $e');
      throw const ReviewException('Failed to submit review');
    }
  }
}
