import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/debug_logger.dart';
import '../../data/repositories/review_repository.dart';
import 'review_state.dart';

class ReviewCubit extends Cubit<ReviewState> {
  static const _tag = 'ReviewCubit';
  final ReviewRepository _repo;

  ReviewCubit(this._repo) : super(const ReviewInitial());

  Future<void> load(int bookingId) async {
    try {
      if (!isClosed) emit(const ReviewLoading());
      final existing = await _repo.getBookingReview(bookingId);
      if (!isClosed) {
        if (existing != null) {
          emit(ReviewAlreadySubmitted(existing));
        } else {
          emit(const ReviewReady());
        }
      }
    } catch (e) {
      DebugLogger.error(_tag, 'load: $e');
      if (!isClosed) emit(const ReviewReady());
    }
  }

  void setRating(int rating) {
    final s = state;
    if (s is ReviewReady && !isClosed) {
      emit(s.copyWith(selectedRating: rating));
    }
  }

  Future<void> submit({
    required int bookingId,
    required int rating,
    required String comment,
  }) async {
    if (rating < 1) return;
    try {
      if (!isClosed) emit(const ReviewSubmitting());
      await _repo.submitReview(bookingId: bookingId, rating: rating, comment: comment);
      if (!isClosed) emit(const ReviewSuccess());
    } catch (e) {
      DebugLogger.error(_tag, 'submit: $e');
      final msg = e is ReviewException ? e.message : 'Failed to submit review';
      if (!isClosed) emit(ReviewError(msg));
    }
  }
}
