import 'package:equatable/equatable.dart';
import '../../data/models/review_model.dart';

abstract class ReviewState extends Equatable {
  const ReviewState();
  @override
  List<Object?> get props => [];
}

class ReviewInitial extends ReviewState {
  const ReviewInitial();
}

class ReviewLoading extends ReviewState {
  const ReviewLoading();
}

class ReviewAlreadySubmitted extends ReviewState {
  final ReviewModel review;
  const ReviewAlreadySubmitted(this.review);
  @override
  List<Object?> get props => [review];
}

class ReviewReady extends ReviewState {
  final int selectedRating;
  const ReviewReady({this.selectedRating = 0});
  @override
  List<Object?> get props => [selectedRating];

  ReviewReady copyWith({int? selectedRating}) =>
      ReviewReady(selectedRating: selectedRating ?? this.selectedRating);
}

class ReviewSubmitting extends ReviewState {
  const ReviewSubmitting();
}

class ReviewSuccess extends ReviewState {
  const ReviewSuccess();
}

class ReviewError extends ReviewState {
  final String message;
  const ReviewError(this.message);
  @override
  List<Object?> get props => [message];
}
